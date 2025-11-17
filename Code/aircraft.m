function ac = aircraft()
% AIRCRAFT  Creates an aircraft struct containing default parameters.
%    ac = AIRCRAFT()  returns the aircraft struct.

% All units are metric (m-kg-s)

% Initial sizing parameters
% Aircraft parameters
ac.initial.num_crew = 1;
ac.initial.num_eng = 2;
ac.initial.num_drop_tanks = 0;
% Altitudes
ac.initial.h_cruise = 40000 .* 0.3048;              % Cruise altitude (ft to m)
ac.initial.h_ceiling = 50000 .* 0.3048;             % Ceiling altitude (ft to m)
ac.initial.h_land = 4000 .* 0.3048;                 % Highest elevation airfield
ac.initial.d_land = 8000 .* 0.3048;                 % Runway length (ft to m)
ac.initial.h_loiter = 10000 .* 0.3048;              % Loiter altitude (ft to m)
% Velocities and Mach numbers
ac.initial.M_cruise = 0.84;                         % Cruise Mach number
ac.initial.V_cruise = getV(ac.initial.h_cruise, ... % Cruise velocity (m/s)
                            ac.initial.M_cruise);
ac.initial.M_loiter = 0.35;                         % Loiter Mach number
ac.initial.V_climb = 151.2 .* 0.514444;             % Climb speed (kts to m/s)
ac.initial.climb_rate = 55.7 .* 0.514444;           % Rate of climb (kts to m/s)
ac.initial.climb_angle = deg2rad(13);               % Climb angle (deg to rad)
% Aircraft geometry
ac.initial.b = 48.75 .* 0.3048;                        % Wing span (ft to m)
ac.initial.Sref = (48.75.^2./3.67) .* 0.092903;                  % Planform area (ft^2 to m^2)
ac.initial.AR = ac.initial.b.^2 ./ ac.initial.Sref; % Aspect ratio
ac.initial.tc = 0.06;                               % Wing thickness-to-chord ratio
ac.initial.tc_r = 0.06;                             % Root thickness-to-chord ratio
ac.initial.taper = 0.2;                             % Taper ratio
ac.initial.sweep_c4 = deg2rad(30);                  % Quarter chord sweep angle
ac.initial.sweep_le = deg2rad(37.2);                % Leading edge sweep angle
ac.initial.S_csw = 77.5 .* 0.092903;                % Wing control surface area (ft^2 to m^2)
ac.initial.MAC = 15.2513 .* 0.3048;                 % Mean aerodynamic chord (ft to m)
ac.initial.xc_m = 0.5325;                           % Airfoil max thickness location
ac.initial.sweep_m = deg2rad(21.87);                % Max thickness sweep angle
% Flaps
ac.initial.CfC_le = 0.15;                           % Leading edge flap chord fraction
ac.initial.CfC_tein = 0.25;                         % Trailing edge flap chord fraction
ac.initial.CfC_teout = 0.25;                        % Flaperon chord fraction
ac.initial.SfS_le = 0.5985;                         % Leading edge flap area ratio
ac.initial.SfS_tein = 0.3921;                       % Trailing edge flap area ratio
ac.initial.SfS_teout = 0.2064;                      % Flaperon area ratio
ac.initial.dflap_le = 15;                           % Leading edge flap deflection (deg)
ac.initial.dflap_te = 35;                           % Trailing edge flap deflection (deg)
% Horizontal Tail
ac.initial.fus_width_HT = 10.7 .* 0.3048;           % Fuselage width at the horizontal tail (ft to m)
ac.initial.b_HT = 24.0 .* 0.3048;                   % Horizontal tail span (ft to m)
ac.initial.S_HT = 192.2 .* 0.092903;                % Horizontal tail area (ft^2 to m^2)
ac.initial.MAC_HT = 8.777 .* 0.3048;                % Horizontal tail mean aerodynamic chord (ft to m)
ac.initial.xc_m_HT = 0.5;                           % Biconvex max thickness location
ac.initial.tc_HT = 0.04;                            % Horizontal tail thickness-to-chord ratio
ac.initial.sweep_m_HT = deg2rad(29.82);             % Horizontal tail max thickness sweep angle
% Vertical Tail
ac.initial.S_VT = 89.08 .* 0.092903;                % Vertical tail area (1 tail) (ft^2 to m^2)
ac.initial.S_rud = 26.72 .* 0.092903;               % Rudder area (1 tail) (ft^2 to m^2)
ac.initial.L_mom_VT = 13.2 .* 0.3048;               % Vertical tail moment arm length (ft to m)
ac.initial.AR_VT = 1.4;                             % Vertical tail aspect ratio (1 tail)
ac.initial.taper_VT = 0.4;                          % Vertical tail taper ratio
ac.initial.sweep_c4_VT = deg2rad(37);               % Vertical tail quarter chord sweep angle
ac.initial.MAC_VT = 8.465 .* 0.3048;                % Vertical tail mean aerodynamic chord (ft to m)
ac.initial.xc_m_VT = 0.5;                           % Biconvex max thickness location
ac.initial.tc_VT = 0.04;                            % Vertical tail thickness-to-chord ratio
ac.initial.sweep_m_VT = deg2rad(31.80);             % Vertical tail max thickness sweep angle
ac.initial.cant_VT = deg2rad(20);                   % Vertical stabilizer cant angle
% Fuselage+
ac.initial.fus_width = 13.17 .* 0.3048;             % Fuselage structrual width (ft to m)
ac.initial.fus_length = 40.75 .* 0.3048;            % Fuselage structrual length (ft to m)
ac.initial.fus_depth = 6.32./2 .* 0.3048;           % Fuselage structrual depth (ft to m)
ac.initial.L_duct = 15.26 .* 0.3048;                % Duct length (ft to m)
ac.initial.S_cs = ac.initial.S_csw + ...            % Total control surface area (ft^2 to m^2)
                  ac.initial.S_HT + ...
                  ac.initial.S_rud;
ac.initial.l_canopy = 9.61 .* 0.3048;               % Canopy length (ft to m)
ac.initial.l_fus = 43.83 .* 0.3048;                 % Fuselage length (ft to m)
ac.initial.Amax_fus = 68.16 .* 0.3048;              % Fuselage frontal area (ft^2 to m^2)
ac.initial.Amax_canopy = 5.86 .* 0.3048;            % Canopy frontal area (ft^2 to m^2)
% Landing gear
ac.gear.L_ng = 3.2567 .* 0.3048;                    % Nose landing gear length (ft to m)
ac.gear.L_mg = 3.1219 .* 0.3048;                    % Main landing gear length (ft to m)
ac.gear.N_nw = 2;                                   % Number of nose gear wheels
ac.gear.A_nw = 1.05 .* 0.092903;                    % Nose wheel frontal area (ft^2 to m^2)
ac.gear.A_ng = 1.35 .* 0.092903;                    % Nose gear strut frontal area (ft^2 to m^2)
ac.gear.A_mw = 3.18 .* 0.092903;                    % Main wheel frontal area (ft^2 to m^2)
ac.gear.A_mg = 0.78 .* 0.092903;                    % Main gear strut frontal area (ft^2 to m^2)
% Aircraft aerodynamics
ac.polar.a2a.clean = simple_polar("clean", ac.initial.num_drop_tanks);
ac.polar.a2a.half = simple_polar("half_flaps", ac.initial.num_drop_tanks);
ac.polar.a2a.full = simple_polar("full_flaps", ac.initial.num_drop_tanks);
ac.polar.a2a.half_gear = simple_polar("half_flaps_gear", ac.initial.num_drop_tanks);
ac.polar.a2a.full_gear = simple_polar("full_flaps_gear", ac.initial.num_drop_tanks);
ac.polar.strike.clean = simple_polar("clean", ac.initial.num_drop_tanks);
ac.polar.strike.half = simple_polar("half_flaps", ac.initial.num_drop_tanks);
ac.polar.strike.full = simple_polar("full_flaps", ac.initial.num_drop_tanks);
ac.polar.strike.half_gear = simple_polar("half_flaps_gear", ac.initial.num_drop_tanks);
ac.polar.strike.full_gear = simple_polar("full_flaps_gear", ac.initial.num_drop_tanks);
% Refined polars (Declaration)
ac.initial.CL_cruise = 0.4323;                      % Cruise CL at mid-mission weight (end of cruise out)
ac.polar.clean = [];                                % Fuel tanks only if present for all polars
ac.polar.catapult = [];                             % Full flaps, gear deployed
ac.polar.approach = [];                             % Half flaps, gear deployed, hook deployed
ac.polar.takeoff = [];                              % Half flaps, gear deployed
ac.polar.landing = [];                              % Full flaps, gear deployed
% Supersonic parameters
ac.sup.Amax = (82.30-16.83) .* 0.092903;            % Maximum cross-sectional area (ft^2 to m^2)
ac.sup.l = 2 .* 31.25 .* 0.3048;                    % Supersonic length (ft to m)
ac.sup.Ewd = 2.2;
% Engine performance and geometry
ac.initial.TSFC_dry = 0.68 ./ 3600;                 % Dry thrust specific fuel consumption (lb/lb-s to N/N-s)
ac.initial.TSFC_wet = 1.90 ./ 3600;                 % Afterburning thrust specific fuel consumption (lb/lb-s to N/N-s)
ac.initial.T_mil = ac.initial.num_eng .* ...        % Military thrust (lb to N)
                   17669 .* 4.44822;             
ac.initial.T_max = ac.initial.num_eng .* ...        % Maximum thrust (lb to N)
                   33093 .* 4.44822;
ac.initial.W_eng = 3990 .* 4.44822;                 % Individual engine weight (lb to N)
ac.initial.D_eng = 46.5 ./ 12 .* 0.3048;            % Engine diameter (in to m)
ac.initial.L_eng = 185.3 ./ 12 .* 0.3048;           % Engine length (in to m)
ac.initial.L_engcon = 24.87 .* 0.3048;              % Engine controls length (ft to m)
% Miscellaneous
ac.initial.num_fcs = 4;                             % Number of flight control systems
ac.initial.num_util = 15;                           % Number of hydraulic utility functions
% Fuel tanks
ac.initial.num_int_tanks = 5;                       % Number of internal fuel tanks TODO
ac.initial.rho_f = 6.74;                            % Fuel density (lb/gal)
ac.initial.V_drop_tanks = 480 .* 0.00378541;        % Drop tank volume (gallon to m^3)
ac.initial.W_drop_tanks = 310 .* 4.44822;           % Drop tank volume (gallon to m^3)
ac.initial.l_tanks = 17.92 .* 0.3048;               % Drop tank length (ft to m)
ac.initial.l_pylon = 10.75 .* 0.3048;               % Pylon length (ft to m)
ac.initial.Amax_tanks = 5.55 .* 0.3048;             % Tank frontal area (ft^2 to m^2)
ac.initial.Amax_pylon = 1.08 .* 0.3048;             % Pylon frontal area (ft^2 to m^2)
% Wetted areas
ac.initial.Swet_wing = 779.29 .* 0.092903;          % Wing wetted area (ft^2 to m^2)
ac.initial.Swet_HT = 385.76 .* 0.092903;            % Horizontal tail wetted area (ft^2 to m^2)
ac.initial.Swet_VT = 364.05 .* 0.092903;            % Vertical tail wetted area (ft^2 to m^2)
ac.initial.Swet_fus = 1092.98 .* 0.092903;          % Fuselage wetted area (ft^2 to m^2) excludes canopy
ac.initial.Swet_canopy = 41.74 .* 0.092903;         % Canopy wetted area (ft^2 to m^2)
ac.initial.Swet_tanks = 119.78 .* 0.092903;         % Drop tank wetted area (ft^2 to m^2)
ac.initial.Swet_pylon = 42.07 .* 0.092903;          % Pylon wetted area (ft^2 to m^2)

% Air-to-air mission parameters
ac.a2a.R = 1000 .* 1852;                            % Combat radius (nm to m)
ac.a2a.M_dash = 1.65;                               % Dash Mach number
ac.a2a.t_combat = 3.0 .* 60;                        % Combat time (min to s)
ac.a2a.t_loiter = 20 .* 60;                         % Loiter time (min to s)
ac.a2a.h_combat = 10000 .* 0.3048;                  % Combat altitude (ft to m)
ac.a2a.h_dash = 30000 .* 0.3048;                    % Combat altitude (ft to m)
ac.a2a.num_120 = 6;                                 % Number of AIM-120 missiles
ac.a2a.num_9x = 2;                                  % Number of AIM-9x missiles
ac.a2a.turn_rate = deg2rad(10);                     % Turn rate (deg/s to rad/s)
ac.a2a.max_g = 8;                                   % Maximum vertical load factor
ac.a2a.max_g_V = getV(ac.a2a.h_combat, 0.95);       % Velocity for max load factor (m/s)
ac.a2a.climb_rate = 17500 .* 0.00508;               % Sea level rate of climb (ft/min to m/s)
% Weights
ac.a2a.W0 = 60000 .* 4.44822;                       % Takeoff weight (lb to N)
ac.a2a.We = 30000 .* 4.44822;                       % Empty weight (lb to N)
ac.a2a.Wf = 24800 .* 4.44822;                       % Fuel weight (lb to N)
ac.a2a.Wf_ext = 10000 .* 4.44822;                   % External Fuel weight (lb to N)
ac.a2a.W_crew = ac.initial.num_crew .* ...          % Crew weight (lb to N)
                    200 .* 4.44822;                 
ac.a2a.W_pay = 2460 .* 4.44822;                     % Payload weight (lb to N)
% Mission segment weight fractions
ac.a2a.Wfracs = [];
ac.a2a.segments = [];

% Strike mission parameters
ac.strike.R = 1000 .* 1852;                         % Combat radius (nm to m)
ac.strike.M_dash = 0.90;                            % Combat dash Mach number
ac.strike.V_dash = getV(0, ac.strike.M_dash);       % Combat dash velocity (m/s)
ac.strike.R_combat = 100 .* 1852;                   % Combat dash distance (nm to m)
ac.strike.t_combat = ac.strike.R_combat ./ ...      % Combat dash time (s)
                     ac.strike.V_dash;
ac.strike.t_loiter = 20 .* 60;                      % Loiter time (min to s)
ac.strike.h_combat = 0;                             % Combat altitude (ft to m)
ac.strike.num_JDAM = 4;                             % Number of MK-83 JDAMs
ac.strike.num_9x = 2;                               % Number of AIM-9x missiles
ac.strike.max_g = 8;                                % Maximum vertical load factor
ac.strike.max_g_V = getV(ac.strike.h_combat, 0.95); % Velocity for max load factor (m/s)
ac.strike.climb_rate = 10900 .* 0.00508;            % Sea level rate of climb (ft/min to m/s)
ac.strike.climb_rate_combat = 12950 .* 0.00508;     % Combat rate of climb (ft/min to m/s)
% Weights
ac.strike.W0 = 60000 .* 4.44822;                    % Takeoff weight (lb to N)
ac.strike.We = 30000 .* 4.44822;                    % Empty weight (lb to N)
ac.strike.Wf = 24800 .* 4.44822;                    % Fuel weight (lb to N)
ac.strike.Wf_ext = 10000 .* 4.44822;                % External Fuel weight (lb to N)
ac.strike.W_crew = ac.initial.num_crew .* ...       % Crew weight (lb to N)
                    200 .* 4.44822;                 
ac.strike.W_pay = 4424 .* 4.44822;                  % Payload weight (lb to N)
% Mission segment weight fractions
ac.strike.Wfracs = [];
ac.strike.segments = [];

% Point constraints
ac.pt.seroc_to = 200 .* 0.00508;                    % Approach SEROC (ft/min to m/s) TODO
ac.pt.seroc_ap = 500 .* 0.00508;                    % Takeoff SEROC (ft/min to m/s) TODO
ac.pt.seroc_to_V = 156 .* 0.514444;                 % Approach SEROC velocity (kts to m/s) TODO
ac.pt.seroc_ap_V = 144 .* 0.514444;                 % Takeoff SEROC velocity (kts to m/s) TODO

% Refined polars (initialization)
ac.polar.clean = drag_polar(ac, ...                 % Fuel tanks only if present for all polars
                            "no", false, true, false);  
ac.polar.catapult = drag_polar(ac, ...              % Full flaps, gear deployed
                            "full", true, true, false);  
ac.polar.approach = drag_polar(ac, ...              % Half flaps, gear deployed, hook deployed
                            "half", true, true, true);  
ac.polar.approach_nogear = drag_polar(ac, ...              % Half flaps, gear deployed, hook deployed
                            "half", false, true, true);  
ac.polar.takeoff = drag_polar(ac, ...               % Half flaps, gear deployed
                            "half", true, true, false);  
ac.polar.takeoff_nogear = drag_polar(ac, ...               % Half flaps, gear deployed
                            "half", false, true, false);  
ac.polar.landing = drag_polar(ac, ...               % Full flaps, gear deployed
                            "full", true, true, false);   
% Cruise spline
ac.polar.cruise_pp = generate_cruise_spline(ac, ac.polar.clean);
end