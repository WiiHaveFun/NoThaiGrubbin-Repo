%% Plot options
fontsize = 10;
width = 6.5;
height = 4;

%% Weights and weight fractions
F18_W0_driver_ref;

Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
Wfrac_land_strike = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ ac.strike.W0;

%% Polars
p_clean = ac.polar.clean;
p_catapult = ac.polar.catapult;
p_approach = ac.polar.approach;
p_takeoff = ac.polar.takeoff;
p_landing = ac.polar.landing;

%% A2A constraints
n = 400;
WS = linspace(1,12000,n);
TW = linspace(0,1.5,n);

% Dash
Tfrac = get_thrust_frac(ac.a2a.M_dash, ac.a2a.h_dash, 1.08, true, false);
CD0 = p_clean.get_CD0(ac.a2a.h_dash, ac.a2a.M_dash);
K = p_clean.get_K(ac.a2a.M_dash);
TW_a2a_dash = dash(WS, ac.a2a.M_dash, ac.a2a.h_dash, CD0, K, ac.a2a.Wfracs(4), Tfrac);
% Turn rate
TW_a2a_turn_rate = turn_rate_ref(WS, ac.a2a.turn_rate, 2.*ac.a2a.h_combat, p_clean, ac.a2a.Wfracs(6), []);
% Vertical load factor
WS_a2a_max_g = max_g(ac.a2a.max_g, ac.a2a.max_g_V, ac.a2a.h_combat, p_clean.get_CLmax(), ac.a2a.Wfracs(6));

% Cruise 1 and 2
CD0 = p_clean.get_CD0(ac.initial.h_cruise, ac.initial.M_cruise);
K = p_clean.get_K(ac.initial.M_cruise);
Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
TW_a2a_cruise_1 = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, CD0, K, ac.a2a.Wfracs(3), Tfrac);
TW_a2a_cruise_2 = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, CD0, K, ac.a2a.Wfracs(8), Tfrac);
% Ceiling
CD0 = p_clean.get_CD0(ac.initial.h_ceiling, ac.initial.M_cruise);
K = p_clean.get_K(ac.initial.M_cruise);
Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
TW_a2a_ceiling = ceiling(WS, ac.initial.M_cruise, ac.initial.h_ceiling, CD0, K, ac.a2a.Wfracs(3), Tfrac);

% SEROC takeoff
[~, a, ~, ~] = atmoscoesa(0);
CD0 = p_catapult.get_CD0(0, ac.pt.seroc_to_V./a);
K = p_catapult.get_K(ac.pt.seroc_to_V./a);
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_a2a_climb_to = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, CD0, K, true, true, ac.initial.num_eng, true, ac.a2a.Wfracs(1), Tfrac);
% SEROC approach
CD0 = p_approach.get_CD0(0, ac.pt.seroc_ap_V./a);
K = p_approach.get_K(ac.pt.seroc_to_V./a);
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_a2a_climb_ap = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, CD0, K, true, true, ac.initial.num_eng, true, Wfrac_land_a2a, Tfrac);
% Climb 1
[V, ~] = get_best_climb_V(ac, ac.a2a.Wfracs(2), ac.a2a.W0, 0, p_clean, false);
CD0 = p_clean.get_CD0(0, V./a);
K = p_clean.get_K(V./a);
Tfrac = get_thrust_frac(V./a, 0, 1.08, false, false);
TW_a2a_climb_1 = climb_rate(WS, ac.a2a.climb_rate, V, 0, CD0, K, false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(2), Tfrac);
% Climb 2
[~, a, ~, ~] = atmoscoesa(ac.a2a.h_combat);
[V, ~] = get_best_climb_V(ac, ac.a2a.Wfracs(7), ac.a2a.W0, ac.a2a.h_combat, p_clean, false);
CD0 = p_clean.get_CD0(ac.a2a.h_combat, V./a);
K = p_clean.get_K(V./a);
Tfrac = get_thrust_frac(V./a, ac.a2a.h_combat, 1.08, false, false);
TW_a2a_climb_2 = climb_rate(WS, ac.a2a.climb_rate, V, ac.a2a.h_combat, CD0, K, false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(7), Tfrac);

% Takeoff % TODO set ground roll distance, BPR, mu, 
[~, a, ~, ~] = atmoscoesa(ac.initial.h_land);
CD0 = p_takeoff.get_CD0(ac.initial.h_land, ac.pt.seroc_to_V./a);
K = p_takeoff.get_K(ac.pt.seroc_to_V./a);
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_a2a_takeoff = takeoff(WS, ac.initial.d_land, ac.initial.h_land, CD0, 1.24, 0.68, 0.025, ac.a2a.Wfracs(1), Tfrac);
% Landing
WS_a2a_landing = landing(ac.initial.d_land, ac.initial.h_land, 1.57, Wfrac_land_a2a);

% Catapult launch
[~, a, ~, ~] = atmoscoesa(0);
CD0 = p_catapult.get_CD0(0, ac.pt.seroc_to_V./a);
K = p_catapult.get_K(ac.pt.seroc_to_V./a);
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
WS_a2a_catapult = catapult2(TW, ac.a2a.W0, CD0, K, 1.57, ac.a2a.Wfracs(1), Tfrac);
% Recovery
WS_a2a_recovery = recovery(ac.a2a.W0, 1.24, Wfrac_land_a2a);

% Fill in catapult
% WS_temp = linspace(1, WS_a2a_catapult(1), 50);
% WS_a2a_catapult = [WS_temp(1:end-1), WS_a2a_catapult];
% TW_a2a_catapult = [TW_a2a_catapult(1).*ones(1, length(WS_temp)-1), TW_a2a_catapult];

% N/m^2 to lb/ft^2
WS_a2a_max_g = WS_a2a_max_g .* 0.020885434273039;
WS_a2a_landing = WS_a2a_landing .* 0.020885434273039;
WS_a2a_catapult = WS_a2a_catapult .* 0.020885434273039;
WS_a2a_recovery = WS_a2a_recovery .* 0.020885434273039;

%% Strike constraints
% Dash
CD0 = p_clean.get_CD0(ac.strike.h_combat, ac.strike.M_dash);
K = p_clean.get_K(ac.strike.M_dash);
Tfrac = get_thrust_frac(ac.strike.M_dash, ac.strike.h_combat, 1.08, true, false);
TW_strike_dash = dash(WS, ac.strike.M_dash, ac.strike.h_combat, CD0, K, ac.strike.Wfracs(5), Tfrac);
% Vertical load factor
WS_strike_max_g = max_g(ac.strike.max_g, ac.strike.max_g_V, ac.strike.h_combat, p_clean.get_CLmax(), ac.strike.Wfracs(6));

% Cruise 1 and 2
CD0 = p_clean.get_CD0(ac.initial.h_cruise, ac.initial.M_cruise);
K = p_clean.get_K(ac.initial.M_cruise);
Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
TW_strike_cruise_1 = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, CD0, K, ac.strike.Wfracs(3), Tfrac);
TW_strike_cruise_2 = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, CD0, K, ac.strike.Wfracs(8), Tfrac);
% Ceiling
CD0 = p_clean.get_CD0(ac.initial.h_ceiling, ac.initial.M_cruise);
K = p_clean.get_K(ac.initial.M_cruise);
Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
TW_strike_ceiling = ceiling(WS, ac.initial.M_cruise, ac.initial.h_ceiling, CD0, K, ac.strike.Wfracs(3), Tfrac);

% SEROC takeoff
[~, a, ~, ~] = atmoscoesa(0);
CD0 = p_catapult.get_CD0(0, ac.pt.seroc_to_V./a);
K = p_catapult.get_K(ac.pt.seroc_to_V./a);
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_strike_climb_to = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, CD0, K, true, true, ac.initial.num_eng, true, ac.strike.Wfracs(1), Tfrac);
% SEROC approach
CD0 = p_approach.get_CD0(0, ac.pt.seroc_ap_V./a);
K = p_approach.get_K(ac.pt.seroc_to_V./a);
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_strike_climb_ap = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, CD0, K, true, true, ac.initial.num_eng, true, Wfrac_land_strike, Tfrac);
% Climb 1
[V, ~] = get_best_climb_V(ac, ac.strike.Wfracs(2), ac.strike.W0, 0, p_clean, false);
CD0 = p_clean.get_CD0(0, V./a);
K = p_clean.get_K(V./a);
Tfrac = get_thrust_frac(V./a, 0, 1.08, false, false);
TW_strike_climb_1 = climb_rate(WS, ac.strike.climb_rate, V, 0, CD0, K, false, false, ac.initial.num_eng, false, ac.strike.Wfracs(2), Tfrac);
% Climb 2
CD0 = p_clean.get_CD0(0, ac.strike.M_dash);
K = p_clean.get_K(ac.strike.M_dash);
Tfrac = get_thrust_frac(ac.strike.M_dash, 0, 1.08, false, false);
TW_strike_climb_2 = climb_rate(WS, ac.strike.climb_rate_combat, ac.strike.V_dash, 0, CD0, K, false, false, ac.initial.num_eng, false, ac.strike.Wfracs(6), Tfrac);
% Climb 3
[V, ~] = get_best_climb_V(ac, ac.strike.Wfracs(7), ac.strike.W0, 0, p_clean, false);
CD0 = p_clean.get_CD0(0, V./a);
K = p_clean.get_K(V./a);
Tfrac = get_thrust_frac(V./a, 0, 1.08, false, false);
TW_strike_climb_3 = climb_rate(WS, ac.strike.climb_rate, V, 0, CD0, K, false, false, ac.initial.num_eng, false, ac.strike.Wfracs(7), Tfrac);

% Takeoff % TODO set ground roll distance, BPR, mu, 
[~, a, ~, ~] = atmoscoesa(ac.initial.h_land);
CD0 = p_takeoff.get_CD0(ac.initial.h_land, ac.pt.seroc_to_V./a);
K = p_takeoff.get_K(ac.pt.seroc_to_V./a);
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_strike_takeoff = takeoff(WS, ac.initial.d_land, ac.initial.h_land, CD0, 1.24, 0.68, 0.025, ac.strike.Wfracs(1), Tfrac);
% Landing
WS_strike_landing = landing(ac.initial.d_land, ac.initial.h_land, 1.57, Wfrac_land_strike);

% Catapult launch
[~, a, ~, ~] = atmoscoesa(0);
CD0 = p_catapult.get_CD0(0, ac.pt.seroc_to_V./a);
K = p_catapult.get_K(ac.pt.seroc_to_V./a);
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
WS_strike_catapult = catapult2(TW, ac.strike.W0, CD0, K, 1.57, ac.strike.Wfracs(1), Tfrac);
% Recovery
WS_strike_recovery = recovery(ac.strike.W0, 1.24, Wfrac_land_strike);

% % Fill in catapult
% WS_temp = linspace(1, WS_strike_catapult(1), 50);
% WS_strike_catapult = [WS_temp(1:end-1), WS_strike_catapult];
% TW_strike_catapult = [TW_strike_catapult(1).*ones(1, length(WS_temp)-1), TW_strike_catapult];

% N/m^2 to lb/ft^2
WS_strike_max_g = WS_strike_max_g .* 0.020885434273039;
WS_strike_landing = WS_strike_landing .* 0.020885434273039;
WS_strike_catapult = WS_strike_catapult .* 0.020885434273039;
WS_strike_recovery = WS_strike_recovery .* 0.020885434273039;

%% Plot A2A
WS2 = WS .* 0.020885434273039;

% Design Point
WSdesign = ac.a2a.W0 ./ ac.initial.Sref .* 0.020885434273039;
TWmax = ac.initial.T_max./ac.a2a.W0;
TWmil = ac.initial.T_mil./ac.a2a.W0;

figure(1);
clf;
p1 = plot(WS2, TW_a2a_dash, "--r");
hold on;
p2 = plot(WS2, TW_a2a_turn_rate, "--", "color", "#F9A603");
p3 = plot(WS_a2a_max_g.*ones(n, 1), TW, "-", "color", "#808080");

p4 = plot(WS2, TW_a2a_cruise_1, "-", "color", "#0000FF");
p5 = plot(WS2, TW_a2a_cruise_2, "-", "color", "#6BADCE");
p6 = plot(WS2, TW_a2a_ceiling, "--", "color", "#734F96");

p7 = plot(WS2, TW_a2a_climb_to, "--", "color", "#1A2421");
p8 = plot(WS2, TW_a2a_climb_ap, "--", "color", "#0B6623");
p9 = plot(WS2, TW_a2a_climb_1, "-", "color", "#028A0F");
p10 = plot(WS2, TW_a2a_climb_2, "-", "color", "#028A0F");

p11 = plot(WS2, TW_a2a_takeoff, "-", "color", "#222021");
p12 = plot(WS_a2a_landing.*ones(n, 1), TW, "-", "color", "#A52A2A");

% p13 = plot(WS_a2a_catapult, TW_a2a_catapult, "--", "color", "#7F00FF");
p13 = plot(WS_a2a_catapult, TW, "--", "color", "#7F00FF");
p14 = plot(WS_a2a_recovery.*ones(n, 1), TW, "-", "color", "#000000");

scatter(WSdesign, TWmax, 20, [252, 106, 3]./255, "filled");
scatter(WSdesign, TWmil, 20, "black", "filled");

% Highlight feasible region
WSmask = WS2 <= min([WS_a2a_max_g, WS_a2a_landing, max(WS_a2a_catapult), WS_a2a_recovery]);
feasibleWS = WS2(WSmask);
% TW_a2a_catapult_interp = interp1(unique(WS_a2a_catapult), TW_a2a_catapult(1:length(unique(WS_a2a_catapult))), feasibleWS);
% TW_env = max([TW_a2a_dash(WSmask); TW_a2a_turn_rate(WSmask); TW_a2a_cruise_1(WSmask); ...
%               TW_a2a_cruise_2(WSmask); TW_a2a_ceiling(WSmask); TW_a2a_climb_to(WSmask); ...
%               TW_a2a_climb_ap(WSmask); TW_a2a_climb_1(WSmask); TW_a2a_climb_2(WSmask); ...
%               TW_a2a_takeoff(WSmask); TW_a2a_catapult_interp; TW_a2a_catapult(WSmask);]);
TW_env = max([TW_a2a_dash(WSmask); TW_a2a_turn_rate(WSmask); TW_a2a_cruise_1(WSmask); ...
              TW_a2a_cruise_2(WSmask); TW_a2a_ceiling(WSmask); TW_a2a_climb_to(WSmask); ...
              TW_a2a_climb_ap(WSmask); TW_a2a_climb_1(WSmask); TW_a2a_climb_2(WSmask); ...
              TW_a2a_takeoff(WSmask)]);
fill([feasibleWS, feasibleWS(end:-1:1)], [TW_env, 1.5.*ones(size(TW_env))], "g", "FaceAlpha", "0.05", "EdgeColor", "none");

% Highlight feasible region (military thrust)
WSmask = WS2 <= min([WS_a2a_max_g, WS_a2a_landing, WS_a2a_recovery]);
feasibleWS = WS2(WSmask);
TW_env = max([TW_a2a_cruise_1(WSmask); ...
              TW_a2a_cruise_2(WSmask); ...
              TW_a2a_climb_1(WSmask); TW_a2a_climb_2(WSmask)]);
fill([feasibleWS, feasibleWS(end:-1:1)], [TW_env, 1.5.*ones(size(TW_env))], "y", "FaceAlpha", "0.05", "EdgeColor", "none");

text(90, 1.25, "Feasible", "HorizontalAlignment", "center", "Interpreter", "latex", "FontSize", fontsize);
text(WSdesign, TWmax, "Design Point (Max)~~~", "HorizontalAlignment", "right", "Interpreter", "latex", "FontSize", fontsize);
text(WSdesign, TWmil, "Design Point (Mil)~~~", "HorizontalAlignment", "right", "Interpreter", "latex", "FontSize", fontsize);

ylim([0, 1.5]);
xlim([0, 200]);
xlabel("$W/S (lb/ft^2)$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$T/W$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

% set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221,6.861111111111111,width,height]);
set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

dn = 5;
label_line(p1, 70, dn, "M1.65 Dash", "interpreter", "latex", "FontSize", fontsize);
label_line(p2, 145, dn, "10 deg/s Sustained Turn", "interpreter", "latex", "FontSize", fontsize);
label_line(p3, 180, dn, "8g Vertical Load Factor~~", "interpreter", "latex", "FontSize", fontsize);
label_line(p4, 80, dn, "Cruise 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p5, 160, -dn, "Cruise 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p6, 175, dn, "50,000 ft Ceiling", "interpreter", "latex", "FontSize", fontsize);
label_line(p7, 175, dn, "SEROC Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p8, 175, dn, "SEROC Approach", "interpreter", "latex", "FontSize", fontsize);
label_line(p9, 125, dn, "Climb 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p10, 160, -dn, "Climb 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p11, 185, dn, "Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p12, 180, -2*dn, "Landing~~", "interpreter", "latex", "FontSize", fontsize);
label_line(p13, 60, dn, "Catapult", "interpreter", "latex", "FontSize", fontsize);
label_line(p14, 180, -dn, "Recovery~~", "interpreter", "latex", "FontSize", fontsize);

% grid on;

% saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/F18_sizing_a2a_cdr.svg");
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/F18_sizing_a2a_cdr.png", "Resolution", 1000);
% set(gcf, 'Renderer', 'painters');
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/sizing_a2a_iter1.pdf", "ContentType", "vector");

%% Plot Strike

% Design Point
WSdesign = ac.strike.W0 ./ ac.initial.Sref .* 0.020885434273039;
TWmax = ac.initial.T_max./ac.strike.W0;
TWmil = ac.initial.T_mil./ac.strike.W0;

figure(2);
clf;
p1 = plot(WS2, TW_strike_dash, "-r");
hold on;
p2 = plot(WS_strike_max_g.*ones(n, 1), TW, "-", "color", "#808080");

p3 = plot(WS2, TW_strike_cruise_1, "-", "color", "#0000FF");
p4 = plot(WS2, TW_strike_cruise_2, "-", "color", "#6BADCE");
p5 = plot(WS2, TW_strike_ceiling, "--", "color", "#734F96");

p6 = plot(WS2, TW_strike_climb_to, "--", "color", "#1A2421");
p7 = plot(WS2, TW_strike_climb_ap, "--", "color", "#0B6623");
p8 = plot(WS2, TW_strike_climb_1, "-", "color", "#028A0F");
p9 = plot(WS2, TW_strike_climb_2, "-", "color", "#028A0F");
p10 = plot(WS2, TW_strike_climb_3, "-", "color", "#028A0F");

p11 = plot(WS2, TW_strike_takeoff, "-", "color", "#222021");
p12 = plot(WS_strike_landing.*ones(n, 1), TW, "-", "color", "#A52A2A");

p13 = plot(WS_strike_catapult, TW, "--", "color", "#7F00FF");
p14 = plot(WS_strike_recovery.*ones(n, 1), TW, "-", "color", "#000000");

scatter(WSdesign, TWmax, 20, [252, 106, 3]./255, "filled");
scatter(WSdesign, TWmil, 20, "black", "filled");

% Highlight feasible region
WSmask = WS2 <= min([WS_strike_max_g, WS_strike_landing, max(WS_strike_catapult), WS_strike_recovery]);
feasibleWS = WS2(WSmask);
% TW_strike_catapult_interp = interp1(unique(WS_strike_catapult), TW_strike_catapult(1:length(unique(WS_strike_catapult))), feasibleWS);
% TW_env = max([TW_strike_dash(WSmask); TW_strike_cruise_1(WSmask); ...
%               TW_strike_cruise_2(WSmask); TW_strike_ceiling(WSmask); TW_strike_climb_to(WSmask); ...
%               TW_strike_climb_ap(WSmask); TW_strike_climb_1(WSmask); TW_strike_climb_2(WSmask); TW_strike_climb_3(WSmask); ...
%               TW_strike_takeoff(WSmask); TW_strike_catapult_interp; TW_strike_catapult(WSmask);]);
TW_env = max([TW_strike_dash(WSmask); TW_strike_cruise_1(WSmask); ...
              TW_strike_cruise_2(WSmask); TW_strike_ceiling(WSmask); TW_strike_climb_to(WSmask); ...
              TW_strike_climb_ap(WSmask); TW_strike_climb_1(WSmask); TW_strike_climb_2(WSmask); TW_strike_climb_3(WSmask); ...
              TW_strike_takeoff(WSmask)]);
fill([feasibleWS, feasibleWS(end:-1:1)], [TW_env, 1.5.*ones(size(TW_env))], "g", "FaceAlpha", "0.05", "EdgeColor", "none");

% Highlight feasible region (military thrust)
WSmask = WS2 <= min([WS_strike_max_g, WS_strike_landing, WS_strike_recovery]);
feasibleWS = WS2(WSmask);
% TW_strike_catapult_interp = interp1(unique(WS_strike_catapult), TW_strike_catapult(1:length(unique(WS_strike_catapult))), feasibleWS);
TW_env = max([TW_strike_dash(WSmask); TW_strike_cruise_1(WSmask); ...
              TW_strike_cruise_2(WSmask); ...
              TW_strike_climb_1(WSmask); TW_strike_climb_2(WSmask); TW_strike_climb_3(WSmask)]);
fill([feasibleWS, feasibleWS(end:-1:1)], [TW_env, 1.5.*ones(size(TW_env))], "y", "FaceAlpha", "0.05", "EdgeColor", "none");

text(80, 1, "Feasible", "HorizontalAlignment", "center", "Interpreter", "latex", "FontSize", fontsize);
text(WSdesign, TWmax, "Design Point (Max)~~~", "HorizontalAlignment", "right", "Interpreter", "latex", "FontSize", fontsize);
text(WSdesign, TWmil, "Design Point (Mil)~~~", "HorizontalAlignment", "right", "Interpreter", "latex", "FontSize", fontsize);

ylim([0, 1.5]);
xlim([0, 200]);
xlabel("$W/S (lb/ft^2)$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$T/W$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

% set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221+width,6.861111111111111,width,height]);
set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221+width,6.861111111111111,width,height]);

dn = 5;
label_line(p1, 180, dn, "M0.9 Dash", "interpreter", "latex", "FontSize", fontsize);
label_line(p2, 180, dn, "8g Vertical Load Factor~~", "interpreter", "latex", "FontSize", fontsize);
label_line(p3, 180, dn, "Cruise 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p4, 180, dn, "Cruise 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p5, 180, dn, "50,000 ft Ceiling", "interpreter", "latex", "FontSize", fontsize);
label_line(p6, 175, dn, "SEROC Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p7, 175, dn, "SEROC Approach", "interpreter", "latex", "FontSize", fontsize);
label_line(p8, 80, dn, "Climb 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p9, 100, dn, "Climb 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p10, 80, -dn, "Climb 3", "interpreter", "latex", "FontSize", fontsize);
label_line(p11, 180, dn, "Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p12, 180, -dn, "Landing~~", "interpreter", "latex", "FontSize", fontsize);
label_line(p13, 60, dn, "Catapult", "interpreter", "latex", "FontSize", fontsize);
label_line(p14, 180, dn, "Recovery~~", "interpreter", "latex", "FontSize", fontsize);

% grid on;

saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/F18_sizing_strike_cdr.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/F18_sizing_strike_cdr.png", "Resolution", 1000);
% set(gcf, 'Renderer', 'painters');
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/sizing_strike.pdf", "ContentType", "vector");

%% Helper functions TODO turn into full function later
function K = getK(ac, polar)
    K = 1 ./ (pi .* ac.initial.AR .* polar.e);
end
