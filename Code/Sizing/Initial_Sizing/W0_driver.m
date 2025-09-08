ac = aircraft();

% Wfrac_reg.A = 0.84 .* 0.911 .* 0.224809.^-0.053;
% Wfrac_reg.C = -0.053;
% Wfrac_reg.A = 2.1650 .* 0.224809.^-0.1425;
% Wfrac_reg.C = -0.1425;
Wfrac_reg.A = 0.8902 .* 0.224809.^-0.0528;
Wfrac_reg.C = -0.0528;
[ac] = iterate_W0(ac, Wfrac_reg, @a2a_Ffrac);

disp(ac.initial.W0 ./ 4.44822);