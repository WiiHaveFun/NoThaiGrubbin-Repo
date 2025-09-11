function cst = cost(ac)
% COST  Creates a cost struct containing default parameters.
%    cst = COST()  returns the aircraft struct.

% All units are metric (m-kg-s)

% Aircraft struct TODO put in aircraft.m
ac_num_crew = 1;

ac_num_AIM120C_a2a = 6;
ac_num_AIM9X_a2a = 2;

ac_num_JDAM_strike = 4;
ac_num_AIM9X_strike = 2;

ac_block_time = 10; % TODO calculate flight time for actual mission

ac_W_engine = 2 * 2450;

% Auxillary
cst.aux.block_time = 0;                                                                 % Block time (hours) TODO
cst.aux.fuel_density = 6.739;                                                           % Fuel density (lb/gal) TODO
cst.aux.fuel_price = 4.05;                                                              % Fuel price (USD/gal) TODO
cst.aux.oil_density = 6.739;                                                        % Lubricating oil density (lb/gal)
cst.aux.oil_price = 12.77;                                                           % Lubricating oil price (USD/gal)

% Environmental, Fleet, Compatibility, Weapons
cst.EFCW.AIM120_price = 916000;                                                         % Cost per AIM-120 (USD 2025)
cst.EFCW.AIM9X_price = 500000;                                                          % Cost per AIM-9X (USD 2025)
cst.EFCW.JDAM_price = 22000 + 3026.54;                                                  % Cost per JDAM (USD 2025)
cst.EFCW.life_support = 0;                                                              % Life support cost (USD 2025) TODO
cst.EFCW.avionics = 0;                                                                  % Avionics cost (USD 2025) TODO
cst.EFCW.surface_treat = 0;                                                             % Surface treatment cost (USD 2025, or USD 2025/gal) TODO
cst.EFCW.sub_tech = 0;                                                                  % Subsystem technologies cost (USD 2025)

% COC
cst.COC.crew_ratio = 1.1 * ac_num_crew;                                                 % Number of pilots per aircraft (Raymer 18.5.1)
cst.COC.pilot_rate = 162.16;                                                            % Pilot hourly rate (USD 2025)
cst.COC.pilot_hours = 2080;                                                             % Pilot hours per year (hours)
cst.COC.crew = cst.COC.crew_ratio * cst.COC.pilot_rate * cst.COC.pilot_hours;           % Crew yearly cost (USD 2025)

cst.COC.a2a_weapons = ac_num_AIM120C_a2a * cst.EFCW.AIM120_price + ...
                      ac_num_AIM9X_a2a * cst.EFCW.AIM9X_price;                          % Single A2A mission weapons cost, assumes all are used (USD 2025)

cst.COC.strike_weapons = ac_num_JDAM_strike * cst.EFCW.JDAM_price + ...
                         ac_num_AIM9X_strike * cst.EFCW.AIM9X_price;                    % Single strike mission weapons cost, assumes all are used (USD 2025)

cst.COC.avg_weapons = (0.5 * cst.COC.a2a_weapons) + (0.5 * ac_num_AIM9X_strike);        % Average mission cost, assumes 50-50 mission mix

cst.COC.FH_YR_AC = mean([300, 500]);                                                    % Flight hours per year per aircraft (Raymer 18.5.1)
cst.COC.fuel_cost = 1.02 * ac.initial.Wf * (cst.aux.fuel_price / cst.aux.fuel_density); % Fuel cost per mission (USD 2025)
cst.COC.fuel_cost_yr = (cst.COC.FH_YR_AC / ac_block_time) * cst.COC.fuel_cost;          % Fuel cost per year (USD 2025)

cst.COC.MMH_FH = mean([10, 15]);                                                        % Maintainance hours per flight hour (Raymer 18.5.1)
cst.COC.W_oil = 0.0125 * ac.initial.Wf * (ac_block_time / 100);                         % Oil weight per mission (lb)
cst.COC.oil_cost = 1.02 * cst.COC.W_oil * (cst.aux.oil_price / cst.aux.oil_density);    % Oil cost per mission (USD 2025)
cst.COC.oil_cost_yr = (cst.COC.FH_YR_AC / ac_block_time) * cst.COC.oil_cost;            % Oil cost per year (USD 2025)

end