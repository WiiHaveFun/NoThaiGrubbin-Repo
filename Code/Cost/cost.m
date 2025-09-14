function cst = cost(ac)
% COST  Creates a cost struct containing cost parameters.
%    cst = COST()  returns the cost struct.

% All units are imperial (ft-lb-s)

%% Aircraft struct TODO put in aircraft.m
ac_num_crew = 1;
ac_num_engines = 2;

ac_num_AIM120C_a2a = 6;
ac_num_AIM9X_a2a = 2;

ac_num_JDAM_strike = 4;
ac_num_AIM9X_strike = 2;

%% Auxillary
[cst.aux.block_time_a2a, cst.aux.block_time_strike] = get_block_time(ac);  % Block time for each mission (hours)
cst.aux.block_time_avg = mean([cst.aux.block_time_a2a, cst.aux.block_time_strike]);  % Average block time assuming 50-50 mix (hours)

cst.aux.fuel_density = 6.739;  % Fuel density (lb/gal)
cst.aux.fuel_price = 4.05;  % Fuel price (USD/gal)
cst.aux.oil_density = 7.15;  % Lubricating oil density (lb/gal)
cst.aux.oil_price = 14.58;  % Lubricating oil price (USD/gal)
cst.aux.price_engine = ac_num_engines * inflation(2010, 4860000);  % F414-GE-400 total price (USD)

%% Environmental, Fleet, Compatibility, Weapons
cst.EFCW.AIM120_price = inflation(1991, 386000);  % Cost per AIM-120 (USD)
cst.EFCW.AIM9X_price = inflation(2023, 430000);  % Cost per AIM-9X (USD)
cst.EFCW.JDAM_price = inflation(2007, 22000) + inflation(2001, 3026);  % Cost per JDAM (USD)
cst.EFCW.life_support = inflation(1999, 195000);  % Life support cost (USD), Ejection seat only

cst.EFCW.mass_avionics = 2500;  % Avionics weight (lb), RFP
cst.EFCW.C_lb_avionics = inflation(2012, mean([4000, 8000]));  % Avionics price per pound (USD/lb), Raymer 18.4.2
cst.EFCW.C_avionics = cst.EFCW.mass_avionics * cst.EFCW.C_lb_avionics;  % Avionics cost (USD)

cst.EFCW.surface_treat_per_FH = mean([500000, 1000000000]) / 1200;  % Surface treatment cost (USD/FH)
cst.EFCW.sub_tech = 0;  % Subsystem technologies cost (USD) TODO

%% COC
cst.COC.crew_ratio = 1.1 * ac_num_crew;  % Number of pilots per aircraft, Raymer 18.5.1
cst.COC.pilot_rate = inflation(2012, 115);  % Pilot hourly rate (USD), Raymer 18.4.2
cst.COC.pilot_hours = 2080;  % Pilot hours per year
cst.COC.crew = cst.COC.crew_ratio * cst.COC.pilot_rate * cst.COC.pilot_hours;  % Crew yearly cost (USD)

cst.COC.a2a_weapons = ac_num_AIM120C_a2a * cst.EFCW.AIM120_price + ...
                      ac_num_AIM9X_a2a * cst.EFCW.AIM9X_price;  % Single A2A mission weapons cost, assumes all are used (USD)

cst.COC.strike_weapons = ac_num_JDAM_strike * cst.EFCW.JDAM_price + ...
                         ac_num_AIM9X_strike * cst.EFCW.AIM9X_price;  % Single strike mission weapons cost, assumes all are used (USD)

cst.COC.avg_weapons = (0.5 * cst.COC.a2a_weapons) + (0.5 * ac_num_AIM9X_strike);  % Average mission cost, assumes 50-50 mission mix

cst.COC.FH_YR_AC = mean([300, 500]);  % Flight hours per year per aircraft, Raymer 18.5.1
cst.COC.fuel_cost = 1.02 * N2lbs(ac.initial.Wf) * (cst.aux.fuel_price / cst.aux.fuel_density);  % Fuel cost per mission (USD)
cst.COC.fuel_cost_yr = (cst.COC.FH_YR_AC / cst.aux.block_time_avg) * cst.COC.fuel_cost;  % Fuel cost per year (USD)

cst.COC.MMH_FH = mean([10, 15]);  % Maintainance hours per flight hour, Raymer 18.5.1
cst.COC.W_oil = 0.0125 * N2lbs(ac.initial.Wf) * (cst.aux.block_time_avg / 100);  % Oil weight per mission (lb)
cst.COC.oil_cost = 1.02 * cst.COC.W_oil * (cst.aux.oil_price / cst.aux.oil_density);  % Oil cost per mission (USD)
cst.COC.oil_cost_yr = (cst.COC.FH_YR_AC / cst.aux.block_time_avg) * cst.COC.oil_cost;  % Oil cost per year (USD)

%% Airplane Unit Cost
% Labor Cost
cst.unit.W_ampr = 10^(0.1936 + 0.8645*log10(N2lbs(ac.initial.W0)));  % Aeronautical Manufacturers Planning Report weight, Roskam VIII Eq. 3.5
cst.unit.V_max = ms2knots(ac.strike.V_dash);  % Maximium speed (knots), Roskam V Page 38
cst.unit.N_rdte = mean([6, 20]);  % Number of airplanes in the RDTE phase, Roskam VIII Page 26
cst.unit.F_diff = 1.5;  % Judgement factor for new technology, Roskam VIII Page 26

cst.unit.N_m = 500;  % Production run number of units, AIAA RFP
cst.unit.N_program = cst.unit.N_m + cst.unit.N_rdte;  % Number of units produced. Added RDTE airplanes via Roskam VIII Eq. 4.1

cst.unit.MHR_man_program = 28.984 * cst.unit.W_ampr^0.740 * cst.unit.V_max^0.543 * cst.unit.N_program^0.524 * cst.unit.F_diff;  % Roskam VIII Eq. 4.11
cst.unit.MHR_man_r = 28.984 * cst.unit.W_ampr^0.740 * cst.unit.V_max^0.543 * cst.unit.N_rdte^0.524 * cst.unit.F_diff;  % Roskam VIII Eq. 3.11

cst.unit.R_m_m = inflation(2012, 98);  % Manufacturing labor rate (USD/hour), Raymer 18.4.2
cst.unit.R_m_r = cst.unit.R_m_m;  % RDTE manufacturing labor rate, assumed same as R_m_m via Roskman VIII Fig. 3.4, Eqn. 3.6

cst.unit.C_man_r = cst.unit.MHR_man_r * cst.unit.R_m_r;  % RDTE manufacturing labor cost (USD), Roskam VIII Eq. 3.1
cst.unit.C_man_m = cst.unit.MHR_man_program * cst.unit.R_m_m - cst.unit.C_man_r;  % Manufacturing labor cost (USD), Roskam VIII Eq. 4.10b

% Materials Cost
cst.unit.F_mat = 3;  % Material correcton factor (carbon composite), Roskam Part VIII Page 31
cst.unit.b_year = 1989;  % Roskam year published
% cst.unit.t_year = 2025;  % Year now
% cst.unit.b_CEF = 5.17053 + 0.104981 * (cst.unit.b_year - 2006);  % Base CEF, Metabook 3.2
% cst.unit.t_CEF = 5.17053 + 0.104981 * (cst.unit.t_year - 2006);  % Then CEF, Metabook 3.2
% cst.unit.CEF = cst.unit.t_CEF / cst.unit.b_CEF;  % CEF, Metabook 3.4
cst.unit.CEF = inflation(cst.unit.b_year, 1);

cst.unit.C_mat_program = 37.632 * cst.unit.F_mat * cst.unit.W_ampr^0.689 * cst.unit.V_max^0.624 * cst.unit.N_program^0.792 * cst.unit.CEF;  % Program materials cost (USD) Roskam VIII Eq. 4.13

cst.unit.C_mat_r = 37.632 * cst.unit.F_mat * cst.unit.W_ampr^0.689 * cst.unit.V_max^0.624 * cst.unit.N_rdte^0.792 * cst.unit.CEF;  % RDTE materials cost (USD) Roskam VIII Eq. 3.12

cst.unit.C_mat_m = cst.unit.C_mat_program - cst.unit.C_mat_r;  % Manufacturing material cost (USD), VIII Roskam Eq. 4.12

% Tooling Cost
cst.unit.N_r_m = 15;  % 15 Production rate (units/month), source progress report from F-18A
cst.unit.MHR_tool_program = 4.0127 * cst.unit.W_ampr^0.764 * cst.unit.V_max^0.899 * cst.unit.N_program^0.178 * cst.unit.N_r_m^0.066 * cst.unit.F_diff;  % Program tooling man-hours, Roskam VIII Eq. 4.15
cst.unit.R_t_m = inflation(2012, 118);  % Tooling labor wrap-rate (USD), Raymer 18.4.2

cst.unit.N_r_r = 0.33;  % RDTE production rate (units/month), Roskam VIII Page 33
cst.unit.MHR_tool_r = 4.0127 * cst.unit.W_ampr^0.764 * cst.unit.V_max^0.899 * cst.unit.N_rdte^0.178 * cst.unit.N_r_r^0.066 * cst.unit.F_diff;  % RDTE tooling man-hours, Roskam VIII Eq. 3.14
cst.unit.R_t_r = cst.unit.R_t_m;  % RDTE manufacturing labor rate, assumed same as R_t_m via Roskman VIII Fig. 3.4, Eqn. 3.6

cst.unit.C_tool_r = cst.unit.MHR_tool_r * cst.unit.R_t_r;  % RDTE tooling cost (USD), Roskam VIII Eq. 3.13
cst.unit.C_tool_m = cst.unit.MHR_tool_program * cst.unit.R_t_m - cst.unit.C_tool_r;  % Tooling cost (USD), Roskam VIII Eq. 4.14b

% Quality Control Cost
cst.unit.C_qc_m = 0.13 * cst.unit.C_man_m;  % Quality control cost (USD), Roskam VIII Eq. 4.16
cst.unit.C_qc_r = 0.13 * cst.unit.C_man_r;  % Quality control cost (USD), Roskam VIII Eq. 3.15

% Avionics and Engine Cost
cst.unit.N_st = 2;  % Number of static test airplanes, F-18 program;
cst.unit.C_ea_r = (cst.aux.price_engine + cst.EFCW.C_avionics) * (cst.unit.N_rdte - cst.unit.N_st);  % RDTE engine and avionics cost per unit, Roskam VIII Eq. 3.9
cst.unit.C_ea_m = (cst.aux.price_engine + cst.EFCW.C_avionics) * (cst.unit.N_m);  % Program production engine and avionics cost per unit, Roskam VIII Eq. 4.8

% RDTE Cost
cst.unit.F_cad = 0.8;  % CAD judgement factor, Roskam VIII Page 27
cst.unit.MHR_aed_r = 0.0396 * cst.unit.W_ampr^0.791 * cst.unit.V_max^1.526 * cst.unit.N_rdte^0.183 * cst.unit.F_diff * cst.unit.F_cad;  % RDTE engineering man-hours, Roskam VIII Eq. 3.2
cst.unit.R_e_r = inflation(2012, 115);  % Engineering labor wrap-rate (USD/hour), Raymer 18.4.2
cst.unit.C_aed_r = cst.unit.MHR_aed_r * cst.unit.R_e_r;  % Engineering and design cost, Roskam VIII Eq. 3.3

cst.unit.C_dst_r = 0.008325 * cst.unit.W_ampr^0.873 * cst.unit.V_max^1.89 * cst.unit.N_rdte^0.346 * cst.unit.CEF * cst.unit.F_diff;  % Development support and testing cost, Roskam VIII Eq. 3.7

cst.unit.C_fta_r = cst.unit.C_ea_r + cst.unit.C_man_r + cst.unit.C_mat_r + cst.unit.C_tool_r + cst.unit.C_qc_r;  % Flight test airplanes cost, Roskam VIII Eq. 3.8

cst.unit.F_obs = mean([1, 3]);  % Low observable factor, Roskam VIII Page 34;
cst.unit.C_fto_r = 0.001244 * cst.unit.W_ampr^1.16 * cst.unit.V_max^1.371 * (cst.unit.N_rdte - cst.unit.N_st)^1.281 * cst.unit.CEF * cst.unit.F_diff * cst.unit.F_obs;  % Flight test operations cost, Roskam VIII Eq. 3.16

cst.unit.C_RDTE = cst.unit.C_aed_r + cst.unit.C_dst_r + cst.unit.C_fta_r + cst.unit.C_fto_r;  % RDTE cost before profit and financing (USD), Roskam VIII Eq. 3.1

cst.unit.F_pro_r = 0.1;  % Profit factor, Roskam VIII Eq. 3.17
cst.unit.F_fin_r = mean([0.1, 0.2]);  % Financing factor, Roskam VIII Eq. 3.19
cst.unit.C_RDTE = cst.unit.C_RDTE * (1 + cst.unit.F_pro_r + cst.unit.F_fin_r);  % Total RDTE cost, Roskam VIII Eq. 3.1

% Totals
cst.unit.C_apc_m = cst.unit.C_ea_m + cst.unit.C_man_m + cst.unit.C_mat_m + cst.unit.C_tool_m + cst.unit.C_qc_m;  % Total program production cost (USD), Roskam VIII Eq. 4.7

cst.unit.R_e_m = cst.unit.R_e_r;  % Engineering labor rate (USD/hour), assumed same as R_t_m via Roskman VIII Fig. 3.4, Eqn. 3.6
cst.unit.MHR_aed_program = 0.0396 * cst.unit.W_ampr^0.791 * cst.unit.V_max^1.526 * cst.unit.N_program^0.183 * cst.unit.F_diff * cst.unit.F_cad;  % Program engineering man-hours, Roskam VIII Eq. 4.6
cst.unit.C_aed_m = cst.unit.MHR_aed_program * cst.unit.R_e_m - cst.unit.C_aed_r;  % Total airframe engineering and design cost, Roskam 4.5b

cst.unit.C_ops_hr = 100; % TODO
cst.unit.t_pft = 20;  % Test flight hours per unit, Roskam Page 55
cst.unit.F_ftoh = 4;  % Flight test ovehear factor, Roskam Page 55
cst.unit.C_fto_m = cst.unit.N_m * cst.unit.C_ops_hr * cst.unit.t_pft * cst.unit.F_ftoh;  % Production flight test operations cost, Roskam VIII Eq. 4.17

cst.unit.C_MAN = cst.unit.C_aed_m + cst.unit.C_apc_m + cst.unit.C_fto_m;  % Total manufacturing cost, Roskam 4.4

cst.unit.F_fin_m = cst.unit.F_fin_r;  % Production finance rate, assumed same as RDTE, Roskam 4.18
cst.unit.F_pro_m = 0.1;  % Profit, Roskam Eq. 4.19
cst.unit.C_ACQ = cst.unit.C_MAN * (1 + cst.unit.F_fin_m + cst.unit.F_pro_m);  % Total manufacturing cost after financing and profit, Roskam 4.18, 4.19, and 4.2

cst.unit.AEP = (cst.unit.C_ACQ + cst.unit.C_RDTE) / cst.unit.N_m;  % Unit price per airplane, including profit and RDTE, Roskam 4.3 TODO look into learning curve

%% Auxillary
cst.aux.labor_rate = mean([cst.unit.R_m_m, cst.unit.R_t_m]);  % Labor rate (USD/hr)
cst.aux.price_aircraft = cst.unit.AEP;  % Aircraft price (USD)

%% EFCW
%cst.EFCW.surface_treat = 

end