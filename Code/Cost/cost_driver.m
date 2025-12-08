% clear; close all; clc;

% ac = aircraft();
% 
% Wfrac_reg.A = 2.3400 .* 0.224809.^-0.1300;
% Wfrac_reg.C = -0.1300;
% [ac] = iterate_W0(ac, Wfrac_reg, @a2a_Ffrac);
[cst] = cost(ac);

fprintf("AEP: $%g Million\n", cst.unit.AEP / 1e6);
fprintf("COC: $%g Million\n", cst.MO.C_OPS / (cst.MO.N_yr * cst.MO.N_serv * 1e6));
fprintf("DOC per unit per year: $%g Million\n", cst.MO.C_OPS ./ (cst.MO.N_yr .* cst.MO.N_serv .* 1e6));
fprintf("Total life-cycle cost: $%g Billion\n", (cst.unit.C_MAN + cst.unit.C_PRO + cst.MO.C_OPS + cst.unit.C_RDTE) ./ 1e9);

cost_column = [
    cst.MO.C_crewpr / (cst.MO.N_yr * cst.MO.N_serv)
    cst.COC.a2a_weapons
    cst.COC.strike_weapons
    cst.MO.W_F_used * (cst.MO.FP / cst.MO.FD) * cst.MO.N_mission
    (cst.MO.F_OL - 1) * (cst.MO.W_F_used * (cst.MO.FP / cst.MO.FD)) * cst.MO.N_mission
    0
    0
    cst.MO.airframe_total / (cst.MO.N_yr * cst.MO.N_serv)
    cst.MO.engine_total / (cst.MO.N_yr * cst.MO.N_serv)
    NaN
    cst.MO.C_OPS / (cst.MO.N_yr * cst.MO.N_serv)
    (cst.MO.C_OPS_HR * cst.MO.t_mis) / ((cst.aux.mission_mix_a2a * N2lbs(ac.a2a.W_pay) * m2nmi(ac.a2a.R) * 2) + ((1 - cst.aux.mission_mix_a2a) * N2lbs(ac.strike.W_pay) * m2nmi(ac.strike.R) * 2))
    ];

aux_column = [
    cst.aux.block_time_a2a
    cst.aux.block_time_strike
    cst.aux.fuel_density
    cst.aux.fuel_price
    cst.aux.oil_density
    cst.aux.oil_price
    cst.unit.R_e_r
    cst.unit.R_m_m
    cst.MO.R_m_ml
    cst.unit.AEP
    cst.aux.price_engine
    N2lbs(ac.strike.W_pay)
    N2lbs(ac.a2a.W_pay)
    2*m2nmi(ac.strike.R)
    2*m2nmi(ac.a2a.R)
    ac.strike.num_9x
    (ac.a2a.num_120 + ac.a2a.num_9x)
    ];

EFCW_column = [
    cst.EFCW.JDAM_price
    cst.EFCW.AIM120_price
    cst.EFCW.AIM9X_price
    cst.EFCW.life_support
    cst.EFCW.C_avionics
    cst.EFCW.surface_treat_per_FH * cst.MO.t_mis * cst.MO.N_mission
    cst.EFCW.sub_tech
    ];

DOC_components = [
    cst.MO.W_F_used * (cst.MO.FP / cst.MO.FD) * cst.MO.N_mission % Fuel cost
    (cst.MO.F_OL - 1) * (cst.MO.W_F_used * (cst.MO.FP / cst.MO.FD)) * cst.MO.N_mission % Oil Cost
    cst.MO.C_POL / (cst.MO.N_yr * cst.MO.N_serv) % Fuel oil lube cost double check it adds up
    cst.MO.airframe_total / (cst.MO.N_yr * cst.MO.N_serv) % Aircraft
    cst.MO.engine_total / (cst.MO.N_yr * cst.MO.N_serv) % Engine
    cst.MO.C_crewpr / (cst.MO.N_yr * cst.MO.N_serv) % Crew cost
    cst.EFCW.surface_treat_per_FH * cst.MO.t_mis * cst.MO.N_mission % Surface treatment
    cst.MO.C_OPS / (cst.MO.N_yr * cst.MO.N_serv) % DOC per aircraft per year
];

fprintf("Misc cost per aircraft per year, %f", DOC_components(8) - DOC_components(1) - DOC_components(2) ...
     - DOC_components(4) - DOC_components(5) - DOC_components(6) - DOC_components(7)); 