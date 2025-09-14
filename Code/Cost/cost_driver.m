clear; close all; clc;

ac = aircraft();

Wfrac_reg.A = 0.8570 .* 0.224809.^-0.0557;
Wfrac_reg.C = -0.0557;
[ac] = iterate_W0(ac, Wfrac_reg, @a2a_Ffrac);
[cst] = cost(ac);

fprintf("AEP: $%g Million\n", cst.unit.AEP / 1e6);