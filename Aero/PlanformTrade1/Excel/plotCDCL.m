polarFile = "C:\Users\Thomas\Documents\Aircraft_Design\Excel\MX-11\4412_T1_Re0.208_M0.00_N5.0_XtrTop10.csv";

polar = readtable(polarFile, "Delimiter", ",");
Cl = polar.CL;
Cd = polar.CD;
alpha = polar.alpha;
[Cdmin, idx] = min(Cd);
ClCdmin = Cl(idx);

% Parabolic Middle Regions
k1 = 60;
Cl1 = Cl(k1);
Cd1 = Cd(k1);
% Cl1 = 0.7863;
% Cd1 = 0.0196;
a1 = (Cd1 - Cdmin) ./ (Cl1 - ClCdmin).^2;

k3 = 240;
Cl3 = Cl(k3);
Cd3 = Cd(k3);
% Cl3 = 1.8087;
% Cd3 = 0.02693;
a3 = (Cd3 - Cdmin) ./ (Cl3 - ClCdmin).^2;

Cl12 = linspace(Cl1, ClCdmin, 100);
Cd12 = a1.*(Cl12 - ClCdmin).^2 + Cdmin;

Cl23 = linspace(ClCdmin, Cl3, 100);
Cd23 = a3.*(Cl23 - ClCdmin).^2 + Cdmin;

% Parabolic Stall regions
% AVL Parameters in cdcl.f
Clinc = 0.2;
Cdinc = 0.05;

% Matching parameters
CdX1 = 2 .* (Cd1 - Cdmin) .* (Cl1 - ClCdmin) ./ (Cl1 - ClCdmin).^2;
CdX3 = 2 .* (Cd3 - Cdmin) .* (Cl3 - ClCdmin) ./ (Cl3 - ClCdmin).^2;
ClFac = 1 ./ Clinc;

ClNeg = linspace(min(Cl), Cl1, 100);
CdNeg = Cd1 + Cdinc .* (ClFac .* (ClNeg - Cl1)).^2 + CdX1 .* (1 - (ClNeg - ClCdmin) ./ (Cl1 - ClCdmin));

ClPos = linspace(Cl3, max(Cl), 100);
CdPos = Cd3 + Cdinc .* (ClFac .* (ClPos - Cl3)).^2 - CdX3 .* (1 - (ClPos - ClCdmin) ./ (Cl3 - ClCdmin));

close all
figure();
hold on;
scatter(Cd, Cl, 100);
plot(CdNeg, ClNeg, "b", "LineWidth", 3);
plot(Cd12, Cl12, "g", "LineWidth", 3);
plot(Cd23, Cl23, "b", "LineWidth", 3);
plot(CdPos, ClPos, "g", "LineWidth", 3);
scatter(Cd1, Cl1, "r", "filled");
scatter(Cdmin, ClCdmin, "red", "filled");
scatter(Cd3, Cl3, "r", "filled");

format long
disp([Cl1, Cd1, ClCdmin, Cdmin, Cl3, Cd3]);
format short

figure()
scatter(alpha, Cl)