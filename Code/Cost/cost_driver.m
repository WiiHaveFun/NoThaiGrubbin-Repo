clear; close all; clc;

ac = aircraft();

Wfrac_reg.A = 0.8570 .* 0.224809.^-0.0557;
Wfrac_reg.C = -0.0557;
[ac] = iterate_W0(ac, Wfrac_reg, @a2a_Ffrac);
[cst] = cost(ac);

fprintf("AEP: $%g Million\n", cst.unit.AEP / 1e6);
fprintf("COC/hr: $%g\n", cst.MO.C_OPS_HR);

cost_column = [
    cst.MO.C_crewpr / (cst.MO.N_mission * cst.MO.N_yr)
    cst.COC.avg_weapons
    cst.MO.W_F_used * (cst.MO.FP / cst.MO.FD)
    (cst.MO.F_OL - 1) * (cst.MO.W_F_used * (cst.MO.FP / cst.MO.FD))
    0
    0
    cst.MO.airframe_total / (cst.MO.N_mission * cst.MO.N_yr)
    cst.MO.engine_total / (cst.MO.N_mission * cst.MO.N_yr)
    NaN
    cst.MO.C_OPS_HR * cst.MO.t_mis
    ];

aux_column = [
    cst.MO.t_mis
    cst.aux.fuel_density
    cst.aux.fuel_price
    cst.aux.oil_density
    cst.aux.oil_price
    cst.MO.R_m_ml
    cst.unit.AEP
    cst.aux.price_engine
    ac.initial.W_pay
    mean([2*ac.a2a.R, 2*ac.strike.R])
    cst.aux.avg_missiles
    ];

EFCW_column = [
    cst.EFCW.JDAM_price
    cst.EFCW.AIM120_price
    cst.EFCW.AIM9X_price  % Incorrect column compared to sheet, two missiles
    cst.EFCW.life_support
    cst.EFCW.C_avionics
    cst.EFCW.surface_treat_per_FH * cst.MO.t_mis
    cst.EFCW.sub_tech
    ];