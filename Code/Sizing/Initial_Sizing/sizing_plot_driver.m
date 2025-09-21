%% Plot options
fontsize = 10;
width = 5;
height = 3;

%% Weights and weight fractions
ac = aircraft();
Wefrac_reg = empty_weight_frac_reg("Raymer");

[ac] = iterate_W0(ac, Wefrac_reg, @a2a_Ffrac);
[ac] = iterate_W0(ac, Wefrac_reg, @strike_Ffrac);

Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
Wfrac_land_strike = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ ac.strike.W0;

%% Polars
p_clean = simple_polar("clean", 2);
p_half = simple_polar("half_flaps", 2);
p_full = simple_polar("full_flaps", 2);
p_half_gear = simple_polar("half_flaps_gear", 2);
p_full_gear = simple_polar("full_flaps_gear", 2);

K_clean = getK(ac, p_clean);
K_half_gear = getK(ac, p_half_gear);
K_full_gear = getK(ac, p_full_gear);

%% A2A constraints
n = 200;
WS = linspace(1,10000,n);
TW = linspace(0,1.5,n);

% Dash
Tfrac = get_thrust_frac(ac.a2a.M_dash, ac.a2a.h_dash, 1.08, true, false);
TW_a2a_dash = dash(WS, ac.a2a.M_dash, ac.a2a.h_dash, 2.*p_clean.CD0, 2.*K_clean, ac.a2a.Wfracs(4), Tfrac);
% Turn rate
TW_a2a_turn_rate = turn_rate(WS, ac.a2a.turn_rate, 2.*ac.a2a.h_combat, p_clean.CD0, K_clean, ac.a2a.Wfracs(6), []);
% Vertical load factor
WS_a2a_max_g = max_g(ac.a2a.max_g, ac.a2a.max_g_V, ac.a2a.h_combat, p_clean.CLmax, ac.a2a.Wfracs(6));

% Cruise 1 and 2
Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
TW_a2a_cruise_1 = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, p_clean.CD0, K_clean, ac.a2a.Wfracs(3), Tfrac);
TW_a2a_cruise_2 = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, p_clean.CD0, K_clean, ac.a2a.Wfracs(8), Tfrac);
% Ceiling
Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
TW_a2a_ceiling = ceiling(WS, ac.initial.M_cruise, ac.initial.h_ceiling, p_clean.CD0, K_clean, ac.a2a.Wfracs(3), Tfrac);

% SEROC takeoff
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_a2a_climb_to = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, p_full_gear.CD0, K_full_gear, true, true, ac.initial.num_eng, true, ac.a2a.Wfracs(1), Tfrac);
% SEROC approach
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_a2a_climb_ap = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, p_full_gear.CD0, K_full_gear, true, true, ac.initial.num_eng, true, Wfrac_land_a2a, Tfrac);
% Climb 1
Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
TW_a2a_climb_1 = climb_rate(WS, 2.54, ac.initial.V_climb, 0, p_clean.CD0, K_clean, false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(2), Tfrac);
% Climb 2
Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
TW_a2a_climb_2 = climb_rate(WS, 2.54, ac.initial.V_climb, ac.a2a.h_combat, p_clean.CD0, K_clean, false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(7), Tfrac);


% Takeoff % TODO set ground roll distance, BPR, mu, 
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_a2a_takeoff = takeoff(WS, 762, 0, p_half_gear.CD0, p_half_gear.CLmax, 0.68, 0.025, ac.a2a.Wfracs(1), Tfrac);
% Landing
WS_a2a_landing = landing(2000, 0, p_full_gear.CLmax, Wfrac_land_a2a);

% Catapult launch
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
[WS_a2a_catapult, TW_a2a_catapult] = catapult(WS, TW, ac.a2a.W0, p_full_gear.CD0, K_full_gear, p_full_gear.CLmax, ac.a2a.Wfracs(1), Tfrac);
% Recovery
WS_a2a_recovery = recovery(ac.a2a.W0, p_full_gear.CLmax, Wfrac_land_a2a);

% N/m^2 to lb/ft^2
WS_a2a_max_g = WS_a2a_max_g .* 0.020885434273039;
WS_a2a_landing = WS_a2a_landing .* 0.020885434273039;
WS_a2a_catapult = WS_a2a_catapult .* 0.020885434273039;
WS_a2a_recovery = WS_a2a_recovery .* 0.020885434273039;

%% Strike constraints
% Dash
Tfrac = get_thrust_frac(ac.strike.M_dash, ac.strike.h_combat, 1.08, true, false);
TW_strike_dash = dash(WS, ac.strike.M_dash, ac.strike.h_combat, p_clean.CD0, K_clean, ac.strike.Wfracs(5), Tfrac);
% Vertical load factor
WS_strike_max_g = max_g(ac.strike.max_g, ac.strike.max_g_V, ac.strike.h_combat, p_clean.CLmax, ac.strike.Wfracs(6));

% Cruise 1 and 2
Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
TW_strike_cruise_1 = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, p_clean.CD0, K_clean, ac.strike.Wfracs(3), Tfrac);
TW_strike_cruise_2 = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, p_clean.CD0, K_clean, ac.strike.Wfracs(8), Tfrac);
% Ceiling
Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
TW_strike_ceiling = ceiling(WS, ac.initial.M_cruise, ac.initial.h_ceiling, p_clean.CD0, K_clean, ac.strike.Wfracs(3), Tfrac);

% SEROC takeoff
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_strike_climb_to = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, p_full_gear.CD0, K_full_gear, true, true, ac.initial.num_eng, true, ac.strike.Wfracs(1), Tfrac);
% SEROC approach
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_strike_climb_ap = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, p_full_gear.CD0, K_full_gear, true, true, ac.initial.num_eng, true, Wfrac_land_strike, Tfrac);
% Climb 1
Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
TW_strike_climb_1 = climb_rate(WS, 2.54, ac.initial.V_climb, 0, p_clean.CD0, K_clean, false, false, ac.initial.num_eng, false, ac.strike.Wfracs(2), Tfrac);
% Climb 2
Tfrac = get_thrust_frac(ac.strike.M_dash, 0, 1.08, false, false);
TW_strike_climb_2 = climb_rate(WS, 65, ac.strike.V_dash, 0, p_clean.CD0, K_clean, false, false, ac.initial.num_eng, false, ac.strike.Wfracs(6), Tfrac);
% Climb 3
Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
TW_strike_climb_3 = climb_rate(WS, 2.54, ac.initial.V_climb, 0, p_clean.CD0, K_clean, false, false, ac.initial.num_eng, false, ac.strike.Wfracs(7), Tfrac);

% Takeoff % TODO set ground roll distance, BPR, mu, 
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
TW_strike_takeoff = takeoff(WS, 762, 0, p_half_gear.CD0, p_half_gear.CLmax, 0.68, 0.025, ac.strike.Wfracs(1), Tfrac);
% Landing
WS_strike_landing = landing(2000, 0, p_full_gear.CLmax, Wfrac_land_strike);

% Catapult launch
Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
[WS_strike_catapult, TW_strike_catapult] = catapult(WS, TW, ac.strike.W0, p_full_gear.CD0, K_full_gear, p_full_gear.CLmax, ac.strike.Wfracs(1), Tfrac);
% Recovery
WS_strike_recovery = recovery(ac.strike.W0, p_full_gear.CLmax, Wfrac_land_strike);

% N/m^2 to lb/ft^2
WS_strike_max_g = WS_strike_max_g .* 0.020885434273039;
WS_strike_landing = WS_strike_landing .* 0.020885434273039;
WS_strike_catapult = WS_strike_catapult .* 0.020885434273039;
WS_strike_recovery = WS_strike_recovery .* 0.020885434273039;

%% Plot A2A
WS2 = WS .* 0.020885434273039;

% Design Point
WSdesign = 4000 .* 0.020885434273039;
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

p11 = plot(WS2, TW_a2a_takeoff, "--", "color", "#222021");
p12 = plot(WS_a2a_landing.*ones(n, 1), TW, "-", "color", "#A52A2A");

p13 = plot(WS_a2a_catapult, TW_a2a_catapult, "--", "color", "#7F00FF");
p14 = plot(WS_a2a_recovery.*ones(n, 1), TW, "-", "color", "#000000");

scatter(WSdesign, TWmax, 100, [252, 106, 3]./255, "filled");
scatter(WSdesign, TWmil, 100, "black", "filled");

ylim([0, 1.5]);
xlim([0, 200]);
xlabel("$W/S (lb/ft^2)$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$T/W$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,7.5,8]);

label(p1, "Dash", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p2, "Sustained Turn", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p3, "Vertical Load Factor", 'location', 'center', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p4, "Cruise 1", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p5, "Cruise 2", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p6, "Ceiling", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p7, "SEROC Takeoff", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p8, "SEROC Approach", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p9, "Climb 1", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p10, "Climb 2", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p11, "Takeoff", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p12, "Landing", 'location', 'center', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p13, "Catapult", 'location', 'center', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p14, "Recovery", 'location', 'center', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);

%% Plot Strike
% Design Point
WSdesign = 4000 .* 0.020885434273039;
TWmax = ac.initial.T_max./ac.a2a.W0;
TWmil = ac.initial.T_mil./ac.a2a.W0;

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

p11 = plot(WS2, TW_strike_takeoff, "--", "color", "#222021");
p12 = plot(WS_strike_landing.*ones(n, 1), TW, "-", "color", "#A52A2A");

p13 = plot(WS_strike_catapult, TW_strike_catapult, "--", "color", "#7F00FF");
p14 = plot(WS_strike_recovery.*ones(n, 1), TW, "-", "color", "#000000");

scatter(WSdesign, TWmax, 100, [252, 106, 3]./255, "filled");
scatter(WSdesign, TWmil, 100, "black", "filled");

ylim([0, 1.5]);
xlim([0, 200]);
xlabel("$W/S (lb/ft^2)$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$T/W$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,7.5,8]);

label(p1, "Dash", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p2, "Vertical Load Factor", 'location', 'center', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p3, "Cruise 1", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p4, "Cruise 2", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p5, "Ceiling", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p6, "SEROC Takeoff", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p7, "SEROC Approach", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p8, "Climb 1", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p9, "Climb 2", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p10, "Climb 3", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p11, "Takeoff", 'location', 'right', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p12, "Landing", 'location', 'center', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p13, "Catapult", 'location', 'center', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);
label(p14, "Recovery", 'location', 'center', 'interpreter', 'latex', 'slope', 'FontSize', fontsize);

%% Helper functions TODO turn into full function later
function K = getK(ac, polar)
    K = 1 ./ (pi .* ac.initial.AR .* polar.e);
end