function ac = aircraft()
% AIRCRAFT  Creates an aircraft struct containing default parameters.
%    ac = AIRCRAFT()  returns the aircraft struct.

% All units are metric (m-kg-s)

% Initial sizing parameters
% Aircraft parameters
ac.initial.num_crew = 1;
ac.initial.num_eng = 2;
% Altitudes
ac.initial.h_cruise = 40000 .* 0.3048;              % Cruise altitude (ft to m)
ac.initial.h_ceiling = 50000 .* 0.3048;             % Ceiling altitude (ft to m)
% Velocities and Mach numbers
ac.initial.M_cruise = 0.84;                         % Cruise Mach number
ac.initial.V_cruise = getV(ac.initial.h_cruise, ... % Cruise velocity (m/s)
                            ac.initial.M_cruise);
ac.initial.M_loiter = 0.35;                         % Loiter Mach number
ac.initial.V_climb = 151.2 .* 0.514444;             % Climb speed (kts to m/s)
ac.initial.climb_rate = 55.7 .* 0.514444;           % Rate of climb (kts to m/s)
ac.initial.climb_angle = deg2rad(13);               % Climb angle (deg to rad)
% Aircraft geometry
ac.initial.AR = 3.14;                                  % Aspect ratio
% Engine performance
ac.initial.TSFC_dry = 0.68 ./ 3600;                 % Dry thrust specific fuel consumption (lb/lb-s to N/N-s)
ac.initial.TSFC_wet = 1.90 ./ 3600;
ac.initial.T_mil = ac.initial.num_eng .* ...        % Military thrust (lb to N)
                   17669 .* 4.44822;             
ac.initial.T_max = ac.initial.num_eng .* ...        % Maximum thrust (lb to N)
                   33093 .* 4.44822;
% Weights are specified for each mission
% % Aircraft weights
% ac.initial.W0 = 60000 .* 4.44822;                   % Takeoff weight (lb to N)
% ac.initial.We = 30000 .* 4.44822;                   % Empty weight (lb to N)
% ac.initial.Wf = 24800 .* 4.44822;                   % Fuel weight (lb to N)
% ac.initial.Wf_ext = 10000 .* 4.44822;                 % External Fuel weight (lb to N)
% ac.initial.W_crew = ac.initial.num_crew .* ...      % Crew weight (lb to N)
%                     200 .* 4.44822;                 
% ac.initial.W_pay = 2460 .* 4.44822;                 % Payload weight (lb to N)

% Air-to-air mission parameters
ac.a2a.R = 800 .* 1852;                         % Combat radius (nm to m)
ac.a2a.M_dash = 1.6;                                % Dash Mach number
ac.a2a.t_combat = 2.85714 .* 60;                    % Combat time (min to s)
ac.a2a.t_loiter = 20 .* 60;                         % Loiter time (min to s)
ac.a2a.h_combat = 10000 .* 0.3048;                  % Combat altitude (ft to m)
ac.a2a.h_dash = 30000 .* 0.3048;                    % Combat altitude (ft to m)
ac.a2a.num_120 = 6;                                 % Number of AIM-120 missiles
ac.a2a.num_9x = 2;                                  % Number of AIM-9x missiles
ac.a2a.turn_rate = deg2rad(10);                     % Turn rate (deg/s to rad/s)
ac.a2a.max_g = 9;                                   % Maximum vertical load factor
ac.a2a.max_g_V = 300;                               % Velocity for max load factor (m/s)
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
ac.strike.R = 945 .* 1852;                          % Combat radius (nm to m)
ac.strike.M_dash = 0.90;                            % Combat dash Mach number
ac.strike.V_dash = getV(0, ac.strike.M_dash);       % Combat dash velocity (m/s)
ac.strike.R_combat = 100 .* 1852;                   % Combat dash distance (nm to m)
ac.strike.t_combat = ac.strike.R_combat ./ ...      % Combat dash time (s)
                     ac.strike.V_dash;
ac.strike.t_loiter = 20 .* 60;                      % Loiter time (min to s)
ac.strike.h_combat = 0;                             % Combat altitude (ft to m)
ac.strike.num_JDAM = 4;                             % Number of MK-83 JDAMs
ac.strike.num_9x = 2;                               % Number of AIM-9x missiles
ac.strike.max_g = 9;                                % Maximum vertical load factor
ac.strike.max_g_V = 300;                            % Velocity for max load factor (m/s)
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
ac.pt.seroc_to = 200 .* 0.00508;                    % Approach SEROC (ft/min to m/s)
ac.pt.seroc_ap = 500 .* 0.00508;                    % Takeoff SEROC (ft/min to m/s)
ac.pt.seroc_to_V = 132 .* 0.514444;                 % Approach SEROC velocity (kts to m/s)
ac.pt.seroc_ap_V = 113 .* 0.514444;                   % Takeoff SEROC velocity (kts to m/s)

end