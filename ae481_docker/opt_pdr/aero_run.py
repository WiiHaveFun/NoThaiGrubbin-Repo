import numpy as np
import argparse
import os
from adflow import ADFLOW
from baseclasses import AeroProblem
from mpi4py import MPI
import json
import csv

parser = argparse.ArgumentParser()
parser.add_argument("--output", type=str, default="output")
parser.add_argument("--gridFile", type=str, default="opt_pdr_1.cgns")
parser.add_argument("--task", choices=["analysis", "polar"], default="analysis")
args = parser.parse_args()

comm = MPI.COMM_WORLD
if not os.path.exists(args.output):
    if comm.rank == 0:
        os.mkdir(args.output)

aeroOptions = {
    # I/O Parameters
    "gridFile": args.gridFile,
    "outputDirectory": args.output,
    "monitorvariables": ["resrho", "cl", "cd", "cmz"],
    "writeTecplotSurfaceSolution": True,
    # Physics Parameters
    "equationType": "RANS",
    # Solver Parameters
    "MGCycle": "sg",
    # ANK Solver Parameters
    "useANKSolver": True,
    # NK Solver Parameters
    "useNKSolver": True,
    "NKSwitchTol": 1e-4,
    # Termination Criteria
    "L2Convergence": 1e-15,
    "nCycles": 1000,
}

# Create solver
CFDSolver = ADFLOW(options=aeroOptions)

# Add features
# CFDSolver.addLiftDistribution(150, "z")
CFDSolver.addSlices("z", 0.5)

L = 1.0
ap = AeroProblem(name="airfoil", mach=0.84, reynolds=L*5218609.182, reynoldsLength=1.0, T=216.65, areaRef=1.0, chordRef=1.0, xRef=0.25, alpha=0.0, evalFuncs=["cl", "cd", "cmz"])
# ap = AeroProblem(name="airfoil", mach=1.7, reynolds=74159694, reynoldsLength=1.0, T=216.65, areaRef=1.0, chordRef=1.0, xRef=0.25, alpha=0.9386, evalFuncs=["cl", "cd", "cmz"])
# ap = AeroProblem(name="airfoil", mach=0.84, reynolds=24572761, reynoldsLength=1.0, T=216.65, areaRef=1.0, chordRef=1.0, xRef=0.25, alpha=0.1966, evalFuncs=["cl", "cd", "cmz"])
# ap = AeroProblem(name="airfoil", V=72, reynolds=L*4.453e6, reynoldsLength=1.0, T=305.2611, areaRef=1.0, chordRef=1.0, xRef=0.25, alpha=0.0, evalFuncs=["cl", "cd", "cmz"])

if args.task == "analysis":
    # Solve
    CFDSolver(ap)
    # rst Evaluate and print
    funcs = {}
    CFDSolver.evalFunctions(ap, funcs)
    # Print the evaluated functions
    if comm.rank == 0:
        print(funcs)
        filename = args.output + "/out.json"
        with open(filename, 'w') as f: 
            json.dump(funcs, f)

elif args.task == "polar":
    # Create an array of alpha values.
    # In this case we create 21 evenly spaced values from -10 - 10.
    alphaList = np.linspace(0, 15, 40)

    # Create storage for the evaluated lift and drag coefficients
    CLList = []
    CDList = []
    CMList = []

    # Loop over the alpha values and evaluate the polar
    for alpha in alphaList:
        # Update the name in the AeroProblem. This allows us to modify the
        # output file names with the current alpha.
        ap.name = f"airfoil_{alpha:4.2f}"

        # Update the alpha in aero problem and print it to the screen.
        ap.alpha = alpha
        if comm.rank == 0:
            print(f"current alpha: {ap.alpha}")

        # Solve the flow
        CFDSolver(ap)

        # Evaluate functions
        funcs = {}
        CFDSolver.evalFunctions(ap, funcs)

        # Store the function values in the output list
        CLList.append(funcs[f"{ap.name}_cl"])
        CDList.append(funcs[f"{ap.name}_cd"])
        CMList.append(-funcs[f"{ap.name}_cmz"])

    # Print the evaluated functions in a table
    if comm.rank == 0:
        print("{:>6} {:>8} {:>8} {:>8}".format("Alpha", "CL", "CD", "CM"))
        print("=" * 24)
        for alpha, cl, cd, cm in zip(alphaList, CLList, CDList, CMList):
            print(f"{alpha:6.1f} {cl:8.4f} {cd:8.4f} {cm:8.4f}")

        rows = zip(alphaList, CLList, CDList, CMList)

        filename = args.output + "/polar.csv"
        with open(filename, "w", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(["alpha", "CL", "CD", "CM"])  # Optional header
            writer.writerows(rows)

