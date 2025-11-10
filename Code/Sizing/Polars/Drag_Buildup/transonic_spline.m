function [pp, Mcrit, MDD] = transonic_spline(S, Amax, l, Ewd, lambda_le, tc, lambda_c4, CL)


% Wave drag and slope at Mach 1.2
[CDw_A, e2] = wave_cd(S, Amax, l, Ewd, 1.2, lambda_le);
CDw_B = CDw_A; % At Mach 1.05
CDw_C = CDw_B ./ 2; % At Mach 1.0

kappa = 0.95;
MDD = kappa ./ cos(lambda_c4) - tc ./ cos(lambda_c4).^2 - CL ./ (10.*cos(lambda_c4).^3);
Mcrit = MDD - (0.1./80).^(1./3);

CDw_D = 20 .* (MDD - Mcrit).^4; % At Mach drag divergence

e1 = 80 .* (MDD - Mcrit).^3;
pp = spline([MDD, 1.0, 1.05, 1.2], [e1, CDw_D, CDw_C, CDw_B, CDw_A, e2]);

pp.coefs = [zeros(3, 1), pp.coefs];
pp.coefs = [20, 0, 0, 0, 0; pp.coefs];

pp.breaks = [Mcrit, pp.breaks];
pp.pieces = 4;

pp.order = 5;

% pp1 = csape([Mcrit, MDD, 1.0], [0, CDw_E, CDw_D, CDw_C, e1], [1, 1]);
% pp2 = csape([1, 1.05], [CDw_C, CDw_B]);
% pp3 = csape([1.05, 1.2], [e1, CDw_B, CDw_A, e2], "complete");
% 
% pp.form = 'pp';
% pp.breaks = [Mcrit, MDD, 1, 1.05, 1.2];
% pp.coefs = [pp1.coefs; pp2.coefs; pp3.coefs]; 
% pp.pieces = 4;
% pp.order = 4;
% pp.dim = 1;

pp = mkpp(pp.breaks, pp.coefs);

end