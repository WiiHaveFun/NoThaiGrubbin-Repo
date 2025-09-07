function LDmax = sub_LDmax_est(AR, M)
% SUB_LDMAX_EST  Estimates L/D max for a given aspect ratio and mach
% number.
%   LDmax = SUB_LDMAX_EST(AR, M) estimates L/D max.

load("sub_LD_coeffs.mat", sub_LD_coeffs);
p = sub_LD_coeffs * [AR, 1];
LDmax = polyval(p, M);