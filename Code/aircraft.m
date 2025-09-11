function ac = aircraft()
% AIRCRAFT  Creates an aircraft struct containing default parameters.
%    ac = AIRCRAFT()  returns the aircraft struct.

% All units are metric (m-kg-s)

% Initial sizing parameters
% Altitudes
ac.initial.h_cruise = 40000 .* 0.3048;              % Cruise altitude (ft to m)
% Velocities and Mach numbers
ac.initial.M_cruise = 0.84;                         % Cruise Mach number
ac.initial.V_cruise = getV(ac.initial.h_cruise, ... % Cruise velocity (m/s)
                            ac.initial.M_cruise);
ac.initial.M_loiter = 0.35;                         % Loiter Mach number
ac.initial.V_climb = 151.2 .* 77.784;               % Climb speed (kts to m/s)
ac.initial.climb_rate = 55.7 .* 77.784;             % Rate of climb (kts to m/s)
ac.initial.climb_angle = deg2rad(13);               % Climb angle (deg to rad)
% Aircraft geometry
ac.initial.AR = 3;                                  % Aspect ratio
% Engine performance
ac.initial.TSFC_dry = 0.82 ./ 3600;                 % Dry thrust specific fuel consumption (lb/lb-s to N/N-s)
ac.initial.TSFC_wet = 1.844 ./ 3600;
ac.initial.T_mil = 2.*14447 .* 4.44822;             % Military thrust (lb to N)
ac.initial.T_max = 2.*21496 .* 4.44822;
% Aircraft weights
ac.initial.W0 = 60000 .* 4.44822;                   % Takeoff weight (lb to N)
ac.initial.We = 30000 .* 4.44822;                   % Empty weight (lb to N)
ac.initial.Wf = 24800 .* 4.44822;                   % Fuel weight (lb to N)
ac.initial.W_crew = 200 .* 4.44822;                 % Crew weight (lb to N)
ac.initial.W_pay = 2460 .* 4.44822;                 % Payload weight (lb to N)

% Air-to-air mission parameters
ac.a2a.R = 957.143 .* 1852;                            % Combat radius (nm to m)
ac.a2a.M_dash = 2.0;                                % Dash Mach number
ac.a2a.t_combat = 4.35714 .* 60;                          % Combat time (min to s)
ac.a2a.t_loiter = 20 .* 60;                         % Loiter time (min to s)
ac.a2a.h_combat = 10000 .* 0.3048;                  % Cruise altitude (ft to m)

% Strike mission parameters
% Altitudes
ac.strike.R = 1000 .* 1852;                         % Combat radius (nm to m)
ac.strike.M_dash = 0.90;                            % Combat dash Mach number
ac.strike.V_dash = getV(0, ac.strike.M_dash);       % Combat dash velocity (m/s)
ac.strike.R_combat = 100 .* 1852;                   % Combat dash distance (nm to m)
ac.strike.t_combat = ac.strike.R_combat ./ ...      % Combat dash time (s)
                     ac.strike.V_dash;
ac.strike.t_loiter = 20 .* 60;                      % Loiter time (min to s)

end