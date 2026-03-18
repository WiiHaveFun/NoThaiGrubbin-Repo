%% Plot options
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(0,'defaultTextInterpreter','latex');
fontsize = 10;
width = 4;
height = 4;

%% Weights and weight fractions
ac = aircraft();
ac.initial.T_max = ac.initial.T_max*0.9;
ac.initial.T_mil = ac.initial.T_mil*0.9;

[ac] = iterate_W0_TS_ref(ac, @a2a_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS_ref(ac, @strike_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);

Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
Wfrac_land_strike = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ ac.strike.W0;

%% Polar
S = ac.initial.Sref;

% Cruise
W = ac.a2a.W0 .* ac.a2a.Wfracs(4);
[~, a, ~, rho] = atmoscoesa(ac.initial.h_cruise);
V = a * ac.initial.M_cruise;
CL_cruise = 2*W / (rho*V^2*S);

CD0 = ac.polar.clean.get_CD0(ac.initial.h_cruise, ac.initial.M_cruise);
K = ac.polar.clean.get_K(ac.initial.M_cruise);
CD_cruise = CD0 + K*CL_cruise^2;

% Approach
W = ac.a2a.W0 .* Wfrac_land_a2a;
[~, ~, P, ~] = atmoscoesa(0);
R = 287;
T = 305.2611; % Tropical day (89.8 F)
rho = P ./ (R .* T);
a = sqrt(1.4 * 287 * T);
CLmax = ac.polar.approach.get_CLmax();
V_stall = sqrt(2*W / (rho * S * CLmax));
WOD = 15.*0.514444;
V = (V_stall - WOD) * 1.1 + WOD;
M_ap = V./a;
CL_ap = 2*W / (rho*V^2*S);

CD0 = ac.polar.approach.get_CD0(0, M_ap);
K = ac.polar.approach.get_K(M_ap);
CD_ap = CD0 + K*CL_ap^2;

% Takeoff
W = ac.a2a.W0;
V = ac.pt.seroc_to_V;
M_to = V./a;
CL_to = 2*W / (rho*V^2*S);

CD0 = ac.polar.catapult.get_CD0(0, M_to);
K = ac.polar.catapult.get_K(M_to);
CD_to = CD0 + K*CL_to^2;

figure(1);
clf;
ac.polar.clean.plot_polar(ac.initial.h_cruise, ac.initial.M_cruise, "-k");
hold on;
ac.polar.approach_nogear.plot_polar(0, M_ap, "-b");
ac.polar.approach.plot_polar(0, M_ap, "--b");
ac.polar.catapult_nogear.plot_polar(0, M_to, "-r");
ac.polar.catapult.plot_polar(0, M_to, "--r");

scatter(CD_cruise, CL_cruise, 40, "k", "filled");
scatter(CD_ap, CL_ap, 40, "k", "filled");
scatter(CD_to, CL_to, 40, "k", "filled");

text(CD_cruise, CL_cruise, "~~~Cruise", "Rotation", 90);
text(CD_ap, CL_ap, "~~~Approach", "Rotation", 90);
text(CD_to, CL_to, "Catapult Launch~~~", "Rotation", 90, "HorizontalAlignment", "right");

legend("Clean", "Approach", "Approach, Gear Down", "Takeoff", "Takeoff, Gear Down", "Location", "southeast");

grid on;
xlabel("$C_D$");
ylabel("$C_L$");

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

% saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/cdr_polar.svg");
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/cdr_polar.png", "Resolution", 1000);

%% Parasitic
figure(2);
clf;
ac.polar.clean.plot_CD0(ac.initial.h_cruise);

text(0.1, 0.045, ["Cruise", "40,000 ft", "No Flaps"], "VerticalAlignment", "middle");

legend("Skin friction", ...
       "Miscellaneous", ...
       "Flap", ...
       "L\&P", ...
       "Wave", ...
       "Interpreter", "latex", "FontSize", fontsize, "Location", "northwest");

grid on;
xlabel("$M$");
ylabel("$C_{D0}$");

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

% saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CD0_cruise.svg");
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CD0_cruise.png", "Resolution", 1000);

figure(3);
clf;
ac.polar.catapult.plot_CD0(0);

text(0.1, 0.07, ["Catapult Launch", "Sea Level", "Full Flaps"], "VerticalAlignment", "middle");

legend("Skin friction", ...
       "Miscellaneous", ...
       "Flap", ...
       "L\&P", ...
       "Wave", ...
       "Interpreter", "latex", "FontSize", fontsize, "Location", "northwest");

grid on;
xlabel("$M$");
ylabel("$C_{D0}$");

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CD0_cat.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CD0_cat.png", "Resolution", 1000);

figure(4);
clf;
ac.polar.approach.plot_CD0(0);

text(0.1, 0.07, ["Approach", "Sea Level", "Half Flaps"], "VerticalAlignment", "middle");

legend("Skin friction", ...
       "Miscellaneous", ...
       "Flap", ...
       "L\&P", ...
       "Wave", ...
       "Interpreter", "latex", "FontSize", fontsize, "Location", "northwest");

grid on;
xlabel("$M$");
ylabel("$C_{D0}$");
ylim([0, 0.12]);

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CD0_ap.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CD0_ap.png", "Resolution", 1000);
