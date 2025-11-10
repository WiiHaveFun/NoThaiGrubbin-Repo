S = 670 .* 0.092903;
Amax = 50 .* 0.092903;
l = 50 .* 0.3048;
Ewd = 2.2;
lambda_le = deg2rad(33.21);
tc = 0.06;
lambda_c4 = deg2rad(29);
CL = 0.555;

M1 = linspace(1.2, 2.0, 1000);
CDw = wave_cd(S, Amax, l, Ewd, M1, lambda_le);

pp = transonic_spline(S, Amax, l, Ewd, lambda_le, tc, lambda_c4, CL);

M2 = linspace(pp.breaks(1), 1.2, 100);

figure(1);
clf;
plot(M2, ppval(pp, M2));
hold on;
plot(M1, CDw);
scatter(pp.breaks, ppval(pp, pp.breaks));