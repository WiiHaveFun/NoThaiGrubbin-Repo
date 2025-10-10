import os
import numpy as np
import argparse
import ast
from mpi4py import MPI
from baseclasses import AeroProblem
from adflow import ADFLOW
from pygeo import DVGeometry, DVConstraints
from pyoptsparse import Optimization, OPT
from idwarp import USMesh
from multipoint import multiPointSparse

# Use Python's built-in Argument parser to get commandline options
parser = argparse.ArgumentParser()
parser.add_argument("--output", type=str, default="output")
parser.add_argument("--opt", type=str, default="SLSQP", choices=["SLSQP", "SNOPT"])
parser.add_argument("--gridFile", type=str, default="naca65-206-299_sm_4.70868.cgns")
parser.add_argument("--optOptions", type=ast.literal_eval, default={}, help="additional optimizer options to be added")
args = parser.parse_args()

# specify flight conditions and constraints
mach = [0.84, 1.7, 0.84, 0.84, 0.83, 0.85]
alt = [40000, 30000, 40000, 40000, 40000, 40000]
alpha = [0, 0, 0, 0, 0, 0]
# mycl = [0.3208, 0.0471, 0.3208+0.1, 0.3208-0.1, 0.3208, 0.3208]
mycl = [0.5547, 0.0759, 0.5547+0.1, 0.5547-0.1, 0.5547, 0.5547]
MAC = 4.70868 # Mean aerodynamic chord, meters
# number of points in multipoint optimization
nFlowCases = len(mach)

# weighted average parameter (1.0 is only cruise, 0.0 is only dash)
# a = 0.5
weights = [1/10, 5/10, 1/10, 1/10, 1/10, 1/10]

# assign number of processors
nGroup = 1
nProcPerGroup = MPI.COMM_WORLD.size
MP = multiPointSparse(MPI.COMM_WORLD)
MP.addProcessorSet("cruise", nMembers=nGroup, memberSizes=nProcPerGroup)
comm, setComm, setFlags, groupFlags, ptID = MP.createCommunicators()
if not os.path.exists(args.output):
    if comm.rank == 0:
        os.mkdir(args.output)


aeroOptions = {
    # Common Parameters
    "gridFile": args.gridFile,
    "outputDirectory": args.output,
    # Physics Parameters
    "equationType": "RANS",
    "smoother": "DADI",
    "MGCycle": "sg",
    "nCycles": 20000,
    "monitorvariables": ["resrho", "cl", "cd"],
    "useNKSolver": True,
    "useanksolver": True,
    "nsubiterturb": 10,
    "liftIndex": 2,
    "infchangecorrection": True,
    # Convergence Parameters
    "L2Convergence": 1e-15,
    "L2ConvergenceCoarse": 1e-4,
    # Adjoint Parameters
    "adjointSolver": "GMRES",
    "adjointL2Convergence": 1e-12,
    "ADPC": True,
    "adjointMaxIter": 5000,
    "adjointSubspaceSize": 400,
    "ILUFill": 3,
    "ASMOverlap": 3,
    "outerPreconIts": 3,
    "NKSubSpaceSize": 400,
    "NKASMOverlap": 4,
    "NKPCILUFill": 4,
    "NKJacobianLag": 5,
    "nkswitchtol": 1e-6,
    "nkouterpreconits": 3,
    "NKInnerPreConIts": 3,
    "writeSurfaceSolution": False,
    "writeVolumeSolution": False,
    "frozenTurbulence": False,
    "restartADjoint": False,
}

# Create solver
CFDSolver = ADFLOW(options=aeroOptions, comm=comm)


aeroProblems = []
for i in range(nFlowCases):
    ap = AeroProblem(
        name="fc%d" % i,
        alpha=alpha[i],
        mach=mach[i],
        altitude=alt[i] * 0.3048,
        areaRef=MAC,
        chordRef=MAC,
        evalFuncs=["cl", "cd"],
    )
    # Add angle of attack variable
    ap.addDV("alpha", value=alpha[i], lower=-1.0, upper=3.0, scale=1.0)
    aeroProblems.append(ap)


# Create DVGeometry object
FFDFile = "naca65-206-299_sm_4.70868_ffd.xyz"

DVGeo = DVGeometry(FFDFile)
DVGeo.addLocalDV("shape", lower=-0.03 * MAC, upper=0.03 * MAC, axis="y", scale=1.0 / (0.06 * MAC))

span = 1.0
pos = np.array([0.5]) * span
CFDSolver.addSlices("z", pos, sliceType="absolute")

# Add DVGeo object to CFD solver
CFDSolver.setDVGeo(DVGeo)


DVCon = DVConstraints()
DVCon.setDVGeo(DVGeo)

# Only ADflow has the getTriangulatedSurface Function
DVCon.setSurface(CFDSolver.getTriangulatedMeshSurface())

# Le/Te constraints
lIndex = DVGeo.getLocalIndex(0)
indSetA = []
indSetB = []
for k in range(0, 1):
    indSetA.append(lIndex[0, 0, k])  # all DV for upper and lower should be same but different sign
    indSetB.append(lIndex[0, 1, k])
for k in range(0, 1):
    indSetA.append(lIndex[-1, 0, k])
    indSetB.append(lIndex[-1, 1, k])
DVCon.addLeTeConstraints(0, indSetA=indSetA, indSetB=indSetB)

# DV should be same along spanwise
lIndex = DVGeo.getLocalIndex(0)
indSetA = []
indSetB = []
for i in range(lIndex.shape[0]):
    indSetA.append(lIndex[i, 0, 0])
    indSetB.append(lIndex[i, 0, 1])
for i in range(lIndex.shape[0]):
    indSetA.append(lIndex[i, 1, 0])
    indSetB.append(lIndex[i, 1, 1])
DVCon.addLinearConstraintsShape(indSetA, indSetB, factorA=1.0, factorB=-1.0, lower=0, upper=0)

# le = 0.0001
le = 0.0015
leList = [[le, 0, le], [le, 0, 1.0 - le]]
teList = [[MAC - le, 0, le], [MAC - le, 0, 1.0 - le]]

DVCon.addVolumeConstraint(leList, teList, 2, 100, lower=1, scaled=True)
DVCon.addThicknessConstraints2D(leList, teList, 2, 100, lower=0.2847, upper=3.0, scaled=True)
# DVCon.addThicknessConstraints2D(leList, teList, 2, 100, lower=0.003, upper=0.20 * MAC, scaled=False) # 3 mm min, 20% t/c max

if comm.rank == 0:
    fileName = os.path.join(args.output, "constraints.dat")
    DVCon.writeTecplot(fileName)


meshOptions = {"gridFile": args.gridFile}

mesh = USMesh(options=meshOptions, comm=comm)
CFDSolver.setMesh(mesh)


def cruiseFuncs(x):
    if MPI.COMM_WORLD.rank == 0:
        print(x)
    # Set design vars
    DVGeo.setDesignVars(x)
    # Evaluate functions
    funcs = {}
    DVCon.evalFunctions(funcs)

    for i in range(nFlowCases):
        if i % nGroup == ptID:
            aeroProblems[i].setDesignVars(x)
            CFDSolver(aeroProblems[i])
            CFDSolver.evalFunctions(aeroProblems[i], funcs)
            CFDSolver.checkSolutionFailure(aeroProblems[i], funcs)
    if MPI.COMM_WORLD.rank == 0:
        print(funcs)
    return funcs


def cruiseFuncsSens(x, funcs):
    funcsSens = {}
    DVCon.evalFunctionsSens(funcsSens)
    for i in range(nFlowCases):
        if i % nGroup == ptID:
            CFDSolver.evalFunctionsSens(aeroProblems[i], funcsSens)
            CFDSolver.checkAdjointFailure(aeroProblems[i], funcsSens)
    if MPI.COMM_WORLD.rank == 0:
        print(funcsSens)
    return funcsSens


def objCon(funcs, printOK):
    # Assemble the objective and any additional constraints:
    funcs["obj"] = 0.0
    for i in range(nFlowCases):
        ap = aeroProblems[i]
        funcs["obj"] += funcs[ap["cd"]] * weights[i]
        funcs["cl_con_" + ap.name] = funcs[ap["cl"]] - mycl[i]
    if printOK:
        print("funcs in obj:", funcs)
    return funcs


# Create optimization problem
optProb = Optimization("opt", MP.obj, comm=MPI.COMM_WORLD)

# Add objective
optProb.addObj("obj", scale=1e4)

# Add variables from the AeroProblem
for ap in aeroProblems:
    ap.addVariablesPyOpt(optProb)

# Add DVGeo variables
DVGeo.addVariablesPyOpt(optProb)

# Add constraints
DVCon.addConstraintsPyOpt(optProb)
for ap in aeroProblems:
    optProb.addCon(f"cl_con_{ap.name}", lower=0.0, upper=0.0, scale=1.0, wrt=[f"alpha_{ap.name}", "shape"])

# The MP object needs the 'obj' and 'sens' function for each proc set,
# the optimization problem and what the objcon function is:
MP.setProcSetObjFunc("cruise", cruiseFuncs)
MP.setProcSetSensFunc("cruise", cruiseFuncsSens)
MP.setObjCon(objCon)
MP.setOptProb(optProb)
optProb.printSparsity()


# Set up optimizer
if args.opt == "SLSQP":
    optOptions = {"IFILE": os.path.join(args.output, "SLSQP.out")}
elif args.opt == "SNOPT":
    optOptions = {
        "Major feasibility tolerance": 1e-4,
        "Major optimality tolerance": 1e-4,
        "Hessian full memory": None,
        "Function precision": 1e-8,
        "Print file": os.path.join(args.output, "SNOPT_print.out"),
        "Summary file": os.path.join(args.output, "SNOPT_summary.out"),
    }
optOptions.update(args.optOptions)
opt = OPT(args.opt, options=optOptions)

# Run Optimization
sol = opt(optProb, MP.sens, storeHistory=os.path.join(args.output, "opt.hst"))
if MPI.COMM_WORLD.rank == 0:
    print(sol)