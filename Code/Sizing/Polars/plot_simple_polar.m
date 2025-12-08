%% Plot options
fontsize = 10;
width = 6.5;
height = 3.5;

n = 100;

CL_clean = linspace(0, ac.polar.a2a.clean.CLmax, n);
CL_half = linspace(0, ac.polar.a2a.half.CLmax, n);
CL_full = linspace(0, ac.polar.a2a.full.CLmax, n);

CD_clean = ac.polar.a2a.clean.CD0 + 1 ./ (pi .* ac.initial.AR .* ac.polar.a2a.clean.e) .* CL_clean.^2;
CD_half = ac.polar.a2a.half.CD0 + 1 ./ (pi .* ac.initial.AR .* ac.polar.a2a.half.e) .* CL_half.^2;
CD_half_gear = ac.polar.a2a.half_gear.CD0 + 1 ./ (pi .* ac.initial.AR .* ac.polar.a2a.half_gear.e) .* CL_half.^2;
CD_full = ac.polar.a2a.full.CD0 + 1 ./ (pi .* ac.initial.AR .* ac.polar.a2a.full.e) .* CL_full.^2;
CD_full_gear = ac.polar.a2a.full_gear.CD0 + 1 ./ (pi .* ac.initial.AR .* ac.polar.a2a.full_gear.e) .* CL_full.^2;

CL_cruise = 0.5547;
CD_cruise = ac.polar.a2a.clean.CD0 + 1 ./ (pi .* ac.initial.AR .* ac.polar.a2a.clean.e) .* CL_cruise.^2;


[~, ~, P, ~] = atmoscoesa(0);
R = 287;
T = 305.2611; % Tropical day (89.8 F)
rho = P ./ (R .* T);

V_TO = 142 .* 0.514444;
CL_takeoff = 2.*ac.a2a.W0 ./ (rho .* V_TO.^2 .* ac.initial.Sref);
CD_takeoff = ac.polar.a2a.full_gear.CD0 + 1 ./ (pi .* ac.initial.AR .* ac.polar.a2a.full_gear.e) .* CL_takeoff.^2;

V_stall = sqrt(2.*ac.strike.W0.*Wfrac_land_strike ./ (rho .* ac.polar.a2a.full_gear.CLmax .* ac.initial.Sref));
V_AP = ((V_stall-15.*0.514444) .* 1.1 + 15.*0.514444);
CL_approach = 2.*ac.strike.W0.*Wfrac_land_strike ./ (rho .* V_AP.^2 .* ac.initial.Sref);
CD_approach = ac.polar.a2a.full_gear.CD0 + 1 ./ (pi .* ac.initial.AR .* ac.polar.a2a.full_gear.e) .* CL_approach.^2;

V_stall = sqrt(2.*ac.strike.W0.*Wfrac_land_strike ./ (rho .* ac.polar.a2a.half_gear.CLmax .* ac.initial.Sref));
V_AP = ((V_stall-15.*0.514444) .* 1.1 + 15.*0.514444);
CL_approach_half = 2.*ac.strike.W0.*Wfrac_land_strike ./ (rho .* V_AP.^2 .* ac.initial.Sref);
CD_approach_half = ac.polar.a2a.half_gear.CD0 + 1 ./ (pi .* ac.initial.AR .* ac.polar.a2a.half_gear.e) .* CL_approach_half.^2;

% CL_takeoff
% CD_takeoff
% 
% CL_approach
% CD_approach

figure(1);
clf;
plot(CD_clean, CL_clean, "-k");
hold on;
plot(CD_half, CL_half, "-b");
plot(CD_half_gear, CL_half, "--b");
plot(CD_full, CL_full, "-r");
plot(CD_full_gear, CL_full, "--r");

scatter(CD_cruise, CL_cruise, 50, "filled", "b");
text(CD_cruise, CL_cruise, "~~~Cruise", "Rotation", 90, "Interpreter", "latex", "FontSize", fontsize);

scatter(CD_takeoff, CL_takeoff, 50, "filled", "b");
text(CD_takeoff, CL_takeoff, "Catapult Launch~~~", "Rotation", 90, "HorizontalAlignment", "right", "Interpreter", "latex", "FontSize", fontsize);

% scatter(CD_approach, CL_approach, 50, "filled", "b");
% text(CD_approach, CL_approach, "Approach~~~", "Rotation", 90, "HorizontalAlignment", "right", "Interpreter", "latex", "FontSize", fontsize);

scatter(CD_approach_half, CL_approach_half, 50, "filled", "b");
text(CD_approach_half, CL_approach_half, "~~~~~~Approach", "Rotation", 90, "HorizontalAlignment", "left", "Interpreter", "latex", "FontSize", fontsize);

xlabel("$C_D$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$C_L$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

% set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221,6.861111111111111,width,height]);
set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

legend("Clean, 2 Tanks", "Half Flaps", "Half Flaps, Gear Down", "Full Flaps", "Full Flaps, Gear Down", ...
       "Interpreter", "latex", "FontSize", fontsize, "Location", "southeast");

grid on;

% saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/simple_polars.svg");
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/simple_polars.png", "Resolution", 1000);
set(gcf, 'Renderer', 'painters');
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/simple_polars.pdf", "ContentType", "vector");
