import numpy as np

airfoil = np.loadtxt("opt_5pt.dat")
npts = airfoil.shape[0]
nmid = (npts + 1) // 2

def getupper(xtemp):
    myairfoil = np.ones(npts)
    for i in range(nmid):
        myairfoil[i] = abs(airfoil[i, 0] - xtemp)
    myi = np.argmin(myairfoil)
    return airfoil[myi, 1]


def getlower(xtemp):
    myairfoil = np.ones(npts)
    for i in range(nmid, npts):
        myairfoil[i] = abs(airfoil[i, 0] - xtemp)
    myi = np.argmin(myairfoil)
    return airfoil[myi, 1]

nffd = 10

FFDbox = np.zeros((nffd, 2, 2, 3))

xslice = np.zeros(nffd)
yupper = np.zeros(nffd)
ylower = np.zeros(nffd)

xmargin = 0.001
ymargin1 = 0.02
ymargin2 = 0.005

for i in range(nffd):
    xtemp = i * 1.0 / (nffd - 1.0)
    xslice[i] = -1.0 * xmargin + (1 + 2.0 * xmargin) * xtemp
    ymargin = ymargin1 + (ymargin2 - ymargin1) * xslice[i]
    yupper[i] = getupper(xslice[i]) + ymargin
    ylower[i] = getlower(xslice[i]) - ymargin

MAC = 4.70868 # Mean aerodynamic chord, meters

# X
FFDbox[:, 0, 0, 0] = xslice[:].copy() * MAC
FFDbox[:, 1, 0, 0] = xslice[:].copy() * MAC
# Y
# lower
FFDbox[:, 0, 0, 1] = ylower[:].copy() * MAC
# upper
FFDbox[:, 1, 0, 1] = yupper[:].copy() * MAC
# copy
FFDbox[:, :, 1, :] = FFDbox[:, :, 0, :].copy()
# Z
FFDbox[:, :, 0, 2] = 0.0
# Z
FFDbox[:, :, 1, 2] = 1.0

filename = f"opt_5pt_{MAC}_ffd.xyz"
with open(filename, "w") as f:
    f.write("1\n")
    f.write(str(nffd) + " 2 2\n")
    for ell in range(3):
        for k in range(2):
            for j in range(2):
                for i in range(nffd):
                    f.write("%.15f " % (FFDbox[i, j, k, ell]))
                f.write("\n")