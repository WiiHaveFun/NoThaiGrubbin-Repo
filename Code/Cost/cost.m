function cst = cost(ac)
% COST  Creates a cost struct containing cost parameters.
%    cst = COST()  returns the cost struct.

% All units are imperial (ft-lb-s)

%% Aircraft struct TODO put in aircraft.m
ac_num_crew = ac.initial.num_crew;
ac_num_engines = ac.initial.num_eng;

ac_num_AIM120C_a2a = ac.a2a.num_120;
ac_num_AIM9X_a2a = ac.a2a.num_9x;

ac_num_JDAM_strike = ac.strike.num_JDAM;
ac_num_AIM9X_strike = ac.strike.num_9x;

%% Auxillary
[cst.aux.block_time_a2a, cst.aux.block_time_strike] = get_block_time(ac);  % Block time for each mission (hours)
cst.aux.block_time_avg = mean([cst.aux.block_time_a2a, cst.aux.block_time_strike]);  % Average block time assuming 50-50 mix (hours)

cst.aux.fuel_density = 6.739;  % Fuel density (lb/gal)
cst.aux.fuel_price = inflation(2025, 4.05);  % Fuel price (USD/gal)
cst.aux.oil_density = 7.15;  % Lubricating oil density (lb/gal)
cst.aux.oil_price = inflation(2025, 14.58);  % Lubricating oil price (USD/gal)
cst.aux.price_engine = ac_num_engines * inflation(2012, 4000000);  % F414-GE-400 total price (USD)

cst.aux.avg_missiles = mean([ac_num_AIM120C_a2a + ac_num_AIM9X_a2a, ac_num_AIM9X_strike]);  % Average missiles carried

%% Environmental, Fleet, Compatibility, Weapons
cst.EFCW.AIM120_price = inflation(1991, 386000);  % Cost per AIM-120 (USD)
cst.EFCW.AIM9X_price = inflation(2023, 430000);  % Cost per AIM-9X (USD)
cst.EFCW.JDAM_price = inflation(2007, 22000) + inflation(2001, 3026);  % Cost per JDAM (USD)
cst.EFCW.life_support = inflation(1999, 195000);  % Life support cost (USD), Ejection seat only

cst.EFCW.mass_avionics = 2500;  % Avionics weight (lb), RFP
cst.EFCW.C_lb_avionics = inflation(2012, mean([4000, 8000]));  % Avionics price per pound (USD/lb), Raymer 18.4.2
cst.EFCW.C_avionics = 5400 * cst.EFCW.C_lb_avionics;  % Avionics cost (USD), guessed so avionics cost is 0.40(AEP), Roskam VIII Appendix C
% = Before Avionics cost assumed 2500 lbs in cst.EFCW.C_avionics = 
% cst.EFCW.mass_avionics * cst.EFCW.C_lb_avionics;  % Avionics cost (USD)

cst.EFCW.surface_treat_per_FH = mean([500000, 1000000]) / 1200;  % Surface treatment cost (USD/FH)
cst.EFCW.sub_tech = 0;  % Subsystem technologies cost (USD) TODO

%% COC
% Fuel, oil, lubricant
cst.MO.F_OL = 1.005;  % Oil and lubricant cost factor, Roskam VIII Page 146
cst.MO.W_F_used = N2lbs(ac.initial.Wf);  % Fuel used per mission (lbs), TODO calculate for average mission
cst.MO.FP = cst.aux.fuel_price;  % Fuel price (USD/gal)
cst.MO.FD = cst.aux.fuel_density;  % Fuel density (lb/gal)

cst.MO.U_ann_flt = mean([250, 400]);  % Annual flight hours, Roskam Fig. 6.1
cst.MO.t_mis = cst.aux.block_time_avg;  % Average mission time, assuming 50-50 mission mix
cst.MO.N_mission = cst.MO.U_ann_flt / cst.MO.t_mis;  % Number of missions flown per year, Roskam VIII Eq. 6.3

cst.MO.N_acq = 500;  % Production run number of units, AIAA RFP, Roskam VIII Page 149
cst.MO.N_res = 0.1 * cst.MO.N_acq;  % Number of units in reserve, Roskam VIII Eq. 6.7
cst.MO.N_serv = cst.MO.N_acq - cst.MO.N_res ;  % Number of airplanes of type in service w/o lost airplanes, Roskam VIII Eq. 6.4
cst.MO.L_R = mean([2.1, 1.9]);  % Annual loss rate, Roskam VIII Table 6.2, F-18
cst.MO.N_yr = mean([20, 40]);  % Years in active service, Roskam VIII Page 149
cst.MO.N_loss = cst.MO.L_R * 10^-5 * cst.MO.N_serv * cst.MO.U_ann_flt * cst.MO.N_yr;  % Number of airplanes lost due to accidents, Roskam VIII Eq. 6.8. Equation incorrect in Roskam, need to multiply by 10^-5
cst.MO.N_serv = cst.MO.N_serv - 0.5*cst.MO.N_loss; % Average number of airplanes of type in service, Roskam VIII Eq. 6.4

cst.MO.C_POL = cst.MO.F_OL * cst.MO.W_F_used * (cst.MO.FP / cst.MO.FD) * cst.MO.N_mission * cst.MO.N_serv * cst.MO.N_yr;  % Program cost of fuel, oil, and lubricants, Roskam VIII 6.2

% Direct personnel
cst.MO.N_crew = ac_num_crew;  % Number of pilots from ac file
cst.MO.R_cr = 1.1;  % Crew ratio per airplane, Roskam VIII Table 6.1
cst.MO.Pay_crew = inflation(2012, 115);  % Pilot hourly rate (USD), Raymer 18.4.2 for engineering via Raymer 18.5.2
cst.MO.OHR_crew = 3;  % Crew overhead rate factor, Roskam VIII Page 154
cst.MO.C_crewpr = cst.MO.N_serv * cst.MO.N_crew * cst.MO.R_cr * cst.MO.Pay_crew * cst.MO.OHR_crew * cst.MO.N_yr;  % Program cost of aircrews, Roskam VIII Eq. 6.10

cst.MO.MHR_flthr = mean([15, 35]);  % Maintenance man-hours per flight hour, Roskam VIII Table 6.5
cst.MO.R_m_ml = inflation(1989, 45);  % Military maintenance labor rate, Roskam VIII Page 157
cst.MO.C_mpersdir = cst.MO.N_serv * cst.MO.N_yr * cst.MO.U_ann_flt * cst.MO.MHR_flthr * cst.MO.R_m_ml;  % Program cost of direct maintenance personnel, Roskam VIII Eq. 6.11

cst.MO.engine_ratio = 2793/10652.9;  % Ratio of maintenance relating to engines, Gov. Accountability Office
cst.MO.airframe_total = (1 - cst.MO.engine_ratio) * cst.MO.C_mpersdir;  %  Program cost of airframe maintenance
cst.MO.engine_total = cst.MO.engine_ratio * cst.MO.C_mpersdir;  % Program cost of engine maintenance

cst.MO.C_PERSDIR = cst.MO.C_crewpr + cst.MO.C_mpersdir;  % Program cost of direct personnel, Roskam VIII Eq. 6.9

% Consumable materials
cst.MO.R_conmat = inflation(1989, 6.5);  % Average cost for consumable materials, Roskam VIII Eq. 6.15
cst.MO.C_CONMAT = cst.MO.N_serv * cst.MO.N_yr * cst.MO.U_ann_flt * cst.MO.MHR_flthr * cst.MO.R_conmat;  % Cost of consumable materials, Roskam VIII Eq. 6.14

% Indirect personnel, spares, depot, misc
cst.MO.f_persind = mean([0.34, 0.32, 0.28, 0.38, 0.38]);  % Fractional contribution of indirect personnel, Roskam VIII Table 6.6
cst.MO.f_spares = mean([0.13, 0.16, 0.27, 0.12, 0.16]);  % Fractional contribution of spares, Roskam VIII Table 6.6
cst.MO.f_depot = mean([0.2, 0.15, 0.22, 0.13, 0.16]);  % Fractional contribution of depot, Roskam VIII Table 6.6
cst.MO.f_misc = mean([0.03, 0.01, 0.04, 0.07, 0.06]);  % Fractional contribution of misc, Roskam VIII Table 6.6

% Total operating cost
cst.MO.C_OPS = (cst.MO.C_POL + cst.MO.C_PERSDIR + cst.MO.C_CONMAT) / ...
               (1 - cst.MO.f_persind - cst.MO.f_spares - cst.MO.f_depot - cst.MO.f_misc);  % Program operating cost, Roskam VIII Eq. 6.20
cst.MO.C_OPS_HR = cst.MO.C_OPS / (cst.MO.N_serv * cst.MO.N_yr * cst.MO.U_ann_flt);  % Program operating cost per flight hour, Roskam VIII Eq. 6.23

% Weapons
cst.COC.a2a_weapons = ac_num_AIM120C_a2a * cst.EFCW.AIM120_price + ...
                      ac_num_AIM9X_a2a * cst.EFCW.AIM9X_price;  % Single A2A mission weapons cost, assumes all are used (USD)

cst.COC.strike_weapons = ac_num_JDAM_strike * cst.EFCW.JDAM_price + ...
                         ac_num_AIM9X_strike * cst.EFCW.AIM9X_price;  % Single strike mission weapons cost, assumes all are used (USD)

cst.COC.avg_weapons = mean([cst.COC.a2a_weapons, ac_num_AIM9X_strike]);  % Average mission cost, assumes 50-50 mission mix

%% Airplane Unit Cost
% Labor Cost
cst.unit.W_ampr = 10^(0.1936 + 0.8645*log10(N2lbs(ac.initial.W0)));  % Aeronautical Manufacturers Planning Report weight, Roskam VIII Eq. 3.5
cst.unit.V_max = ms2knots(ac.strike.V_dash);  % Maximium speed (knots), Roskam V Page 38
cst.unit.N_rdte = mean([6, 20]);  % Number of airplanes in the RDTE phase, Roskam VIII Page 26
cst.unit.F_diff = 1.25;  % Judgement factor for new technology, Roskam VIII Page 26

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
cst.unit.CEF = inflation(1989, 1);  % CEF for Roskam 1989

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

cst.unit.t_pft = 20;  % Test flight hours per unit, Roskam Page 55
cst.unit.F_ftoh = 4;  % Flight test ovehear factor, Roskam Page 55
cst.unit.C_fto_m = cst.unit.N_m * cst.MO.C_OPS_HR * cst.unit.t_pft * cst.unit.F_ftoh;  % Production flight test operations cost, Roskam VIII Eq. 4.17

cst.unit.C_MAN = cst.unit.C_aed_m + cst.unit.C_apc_m + cst.unit.C_fto_m;  % Total manufacturing cost, Roskam 4.4

cst.unit.F_fin_m = cst.unit.F_fin_r;  % Production finance rate, assumed same as RDTE, Roskam 4.18
cst.unit.F_pro_m = 0.1;  % Profit, Roskam Eq. 4.19
cst.unit.C_ACQ = cst.unit.C_MAN * (1 + cst.unit.F_fin_m + cst.unit.F_pro_m);  % Total manufacturing cost after financing and profit, Roskam 4.18, 4.19, and 4.2

cst.unit.AEP = (cst.unit.C_ACQ + cst.unit.C_RDTE) / cst.unit.N_m;  % Unit price per airplane, including profit and RDTE, Roskam 4.3 TODO look into learning curve

end