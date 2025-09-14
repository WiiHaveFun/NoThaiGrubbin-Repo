clear; close all; clc;

ac = aircraft();

Wfrac_reg.A = 0.8570 .* 0.224809.^-0.0557;
Wfrac_reg.C = -0.0557;
[ac] = iterate_W0(ac, Wfrac_reg, @a2a_Ffrac);
[cst] = cost(ac);

disp(cst.unit.C_man_m);
disp(cst.unit.C_mat_m);
disp(cst.unit.C_tool_m);
disp(cst.unit.C_qc_m);