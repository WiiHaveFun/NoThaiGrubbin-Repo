ac = aircraft();

Wfrac_reg.A = 0.8570 .* 0.224809.^-0.0557;
Wfrac_reg.C = -0.0557;
[ac] = iterate_W0(ac, Wfrac_reg, @a2a_Ffrac);

disp(ac.initial.W0 ./ 4.44822);