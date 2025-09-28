%% Plot options
fontsize = 10;
width = 6.5;
height = 8;

%% Weights and weight fractions
% ac = aircraft();
Wefrac_reg = empty_weight_frac_reg("Raymer");

% TODO enforce identical polars or separate polars by mission
[ac] = iterate_W0_TS(ac, Wefrac_reg, @a2a_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS(ac, Wefrac_reg, @strike_Ffrac, ac.initial.T_max, ac.initial.Sref);

%% A2A constraints
n = 20;
S = linspace(300 .* 0.092903, 1000 .* 0.092903, n);
T0 = linspace(30000 .* 4.44822, 80000 .* 4.44822, n);

T0_a2a_dash = zeros(size(n, 1));
T0_a2a_turn_rate = zeros(size(n, 1));
S_a2a_max_g = zeros(size(n, 1));

T0_a2a_cruise_1 = zeros(size(n, 1));
T0_a2a_cruise_2 = zeros(size(n, 1));
T0_a2a_ceiling = zeros(size(n, 1));

T0_a2a_climb_to = zeros(size(n, 1));
T0_a2a_climb_ap = zeros(size(n, 1));
T0_a2a_climb_1 = zeros(size(n, 1));
T0_a2a_climb_2 = zeros(size(n, 1));

T0_a2a_takeoff = zeros(size(n, 1));
S_a2a_landing = zeros(size(n, 1));

S_a2a_catapult = zeros(size(n, 1));
S_a2a_recovery = zeros(size(n, 1));

for i = 1:n
    % Dash
    Tfrac = get_thrust_frac(ac.a2a.M_dash, ac.a2a.h_dash, 1.08, true, false);
    T0_a2a_dash(i) = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @dash, Tfrac);
    % Turn rate
    T0_a2a_turn_rate(i) = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @turn_rate, []);
    % Vertical load factor
    S_a2a_max_g(i) = solveS4(ac, T0(i), Wefrac_reg, @a2a_Ffrac, @max_g, []);

    % Cruise 1 and 2
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
    T0_a2a_cruise_1(i) = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @cruise_1, Tfrac);
    T0_a2a_cruise_2(i) = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @cruise_2, Tfrac);
    % Ceiling
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
    T0_a2a_ceiling(i) = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @ceiling, Tfrac);

    % SEROC takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    T0_a2a_climb_to(i) = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @seroc_to, Tfrac);
    % SEROC approach
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    T0_a2a_climb_ap(i) = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @seroc_ap, Tfrac);
    % Climb 1
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    T0_a2a_climb_1(i) = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @climb_1, Tfrac);
    % Climb 2
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    T0_a2a_climb_2(i) = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @climb_2, Tfrac);

    % Takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    T0_a2a_takeoff(i) = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @takeoff, Tfrac);
    % Landing
    S_a2a_landing(i) = solveS4(ac, T0(i), Wefrac_reg, @a2a_Ffrac, @landing, []);

    % Catapult
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    S_a2a_catapult(i) = solveS4(ac, T0(i), Wefrac_reg, @a2a_Ffrac, @catapult2, Tfrac);
    % Recovery
    S_a2a_recovery(i) = solveS4(ac, T0(i), Wefrac_reg, @a2a_Ffrac, @recovery, []);
end

% N to lb
T0_a2a_dash = T0_a2a_dash ./ 4.44822;
T0_a2a_turn_rate = T0_a2a_turn_rate ./ 4.44822;
T0_a2a_cruise_1 = T0_a2a_cruise_1 ./ 4.44822;
T0_a2a_cruise_2 = T0_a2a_cruise_2 ./ 4.44822;
T0_a2a_ceiling = T0_a2a_ceiling ./ 4.44822;
T0_a2a_climb_to = T0_a2a_climb_to ./ 4.44822;
T0_a2a_climb_ap = T0_a2a_climb_ap ./ 4.44822;
T0_a2a_climb_1 = T0_a2a_climb_1 ./ 4.44822;
T0_a2a_climb_2 = T0_a2a_climb_2 ./ 4.44822;
T0_a2a_takeoff = T0_a2a_takeoff ./ 4.44822;

T0_a2a_dash(imag(T0_a2a_dash) ~= 0) = NaN;
T0_a2a_turn_rate(imag(T0_a2a_turn_rate) ~= 0) = NaN;
T0_a2a_cruise_1(imag(T0_a2a_cruise_1) ~= 0) = NaN;
T0_a2a_cruise_2(imag(T0_a2a_cruise_2) ~= 0) = NaN;
T0_a2a_ceiling(imag(T0_a2a_ceiling) ~= 0) = NaN;
T0_a2a_climb_to(imag(T0_a2a_climb_to) ~= 0) = NaN;
T0_a2a_climb_ap(imag(T0_a2a_climb_ap) ~= 0) = NaN;
T0_a2a_climb_1(imag(T0_a2a_climb_1) ~= 0) = NaN;
T0_a2a_climb_2(imag(T0_a2a_climb_2) ~= 0) = NaN;
T0_a2a_takeoff(imag(T0_a2a_takeoff) ~= 0) = NaN;

% m^2 to ft^2
S_a2a_max_g = S_a2a_max_g ./ 0.092903;
S_a2a_landing = S_a2a_landing ./ 0.092903;
S_a2a_catapult = S_a2a_catapult ./ 0.092903;
S_a2a_recovery = S_a2a_recovery ./ 0.092903;

%% Plot A2A
S_plot = S ./ 0.092903;
T0_plot = T0 ./ 4.44822;

figure(3);
clf;
p1 = plot(S_plot, T0_a2a_dash, "--r");
hold on;
p2 = plot(S_plot, T0_a2a_turn_rate, "--", "color", "#F9A603");
p3 = plot(S_a2a_max_g, T0_plot, "-", "color", "#808080");

p4 = plot(S_plot, T0_a2a_cruise_1, "-", "color", "#0000FF");
p5 = plot(S_plot, T0_a2a_cruise_2, "-", "color", "#6BADCE");
p6 = plot(S_plot, T0_a2a_ceiling, "--", "color", "#734F96");

p7 = plot(S_plot(~isnan(T0_a2a_climb_to)), T0_a2a_climb_to(~isnan(T0_a2a_climb_to)), "--", "color", "#1A2421");
p8 = plot(S_plot, T0_a2a_climb_ap, "--", "color", "#0B6623");
p9 = plot(S_plot, T0_a2a_climb_1, "-", "color", "#028A0F");
p10 = plot(S_plot, T0_a2a_climb_2, "-", "color", "#028A0F");

p11 = plot(S_plot(~isnan(T0_a2a_takeoff)), T0_a2a_takeoff(~isnan(T0_a2a_takeoff)), "--", "color", "#222021");
p12 = plot(S_a2a_landing, T0_plot, "-", "color", "#A52A2A");

p13 = plot(S_a2a_catapult, T0_plot, "--", "color", "#7F00FF");
p14 = plot(S_a2a_recovery, T0_plot, "-", "color", "#000000");

scatter(ac.initial.Sref ./ 0.092903, ac.initial.T_max ./ 4.44822, 100, [252, 106, 3]./255, "filled");

ylim([0, 80000]);
xlim([300, 1000]);
xlabel("$S (ft^2)$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$T (lb)$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221,6.861111111111111,width,height]);

dn = 5;
label_line(p1, 900, dn, "M1.7 Dash", "interpreter", "latex", "FontSize", fontsize);
label_line(p2, 850, dn, "10 deg/s Sustained Turn", "interpreter", "latex", "FontSize", fontsize);
label_line(p3, 460, dn, "8g Vertical Load Factor", "interpreter", "latex", "FontSize", fontsize);
label_line(p4, 750, dn, "Cruise 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p5, 850, dn, "Cruise 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p6, 900, -dn, "50,000 ft Ceiling", "interpreter", "latex", "FontSize", fontsize);
label_line(p7, 900, dn, "SEROC Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p8, 900, dn, "SEROC Approach", "interpreter", "latex", "FontSize", fontsize);
label_line(p9, 850, dn, "Climb 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p10, 950, dn, "Climb 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p11, 970, dn, "Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p12, 500, dn, "Landing", "interpreter", "latex", "FontSize", fontsize);
label_line(p13, 850, dn, "Catapult", "interpreter", "latex", "FontSize", fontsize);
label_line(p14, 540, -dn, "Recovery", "interpreter", "latex", "FontSize", fontsize);

%% Strike constraints
n = 20;
S = linspace(300 .* 0.092903, 1000 .* 0.092903, n);
T0 = linspace(20000 .* 4.44822, 80000 .* 4.44822, n);

T0_strike_dash = zeros(size(n, 1));
S_strike_max_g = zeros(size(n, 1));

T0_strike_cruise_1 = zeros(size(n, 1));
T0_strike_cruise_2 = zeros(size(n, 1));
T0_strike_ceiling = zeros(size(n, 1));

T0_strike_climb_to = zeros(size(n, 1));
T0_strike_climb_ap = zeros(size(n, 1));
T0_strike_climb_1 = zeros(size(n, 1));
T0_strike_climb_2 = zeros(size(n, 1));
T0_strike_climb_3 = zeros(size(n, 1));

T0_strike_takeoff = zeros(size(n, 1));
S_strike_landing = zeros(size(n, 1));

S_strike_catapult = zeros(size(n, 1));
S_strike_recovery = zeros(size(n, 1));

for i = 1:n
    % Dash
    Tfrac = get_thrust_frac(ac.strike.M_dash, ac.strike.h_combat, 1.08, true, false);
    T0_strike_dash(i) = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @dash, Tfrac);
    % Vertical load factor
    S_strike_max_g(i) = solveS4(ac, T0(i), Wefrac_reg, @strike_Ffrac, @max_g, []);

    % Cruise 1 and 2
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
    T0_strike_cruise_1(i) = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @cruise_1, Tfrac);
    T0_strike_cruise_2(i) = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @cruise_2, Tfrac);
    % Ceiling
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
    T0_strike_ceiling(i) = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @ceiling, Tfrac);

    % SEROC takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    T0_strike_climb_to(i) = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @seroc_to, Tfrac);
    % SEROC approach
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    T0_strike_climb_ap(i) = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @seroc_ap, Tfrac);
    % Climb 1
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    T0_strike_climb_1(i) = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @climb_1, Tfrac);
    % Climb 2
    Tfrac = get_thrust_frac(ac.strike.M_dash, 0, 1.08, false, false);
    T0_strike_climb_2(i) = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @climb_2, Tfrac);
    % Climb 3
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    T0_strike_climb_3(i) = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @climb_3, Tfrac);

    % Takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    T0_strike_takeoff(i) = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @takeoff, Tfrac);
    % Landing
    S_strike_landing(i) = solveS4(ac, T0(i), Wefrac_reg, @strike_Ffrac, @landing, []);

    % Catapult
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    S_strike_catapult(i) = solveS4(ac, T0(i), Wefrac_reg, @strike_Ffrac, @catapult2, Tfrac);
    % Recovery
    S_strike_recovery(i) = solveS4(ac, T0(i), Wefrac_reg, @strike_Ffrac, @recovery, []);
end

% N to lb
T0_strike_dash = T0_strike_dash ./ 4.44822;
T0_strike_cruise_1 = T0_strike_cruise_1 ./ 4.44822;
T0_strike_cruise_2 = T0_strike_cruise_2 ./ 4.44822;
T0_strike_ceiling = T0_strike_ceiling ./ 4.44822;
T0_strike_climb_to = T0_strike_climb_to ./ 4.44822;
T0_strike_climb_ap = T0_strike_climb_ap ./ 4.44822;
T0_strike_climb_1 = T0_strike_climb_1 ./ 4.44822;
T0_strike_climb_2 = T0_strike_climb_2 ./ 4.44822;
T0_strike_climb_3 = T0_strike_climb_3 ./ 4.44822;
T0_strike_takeoff = T0_strike_takeoff ./ 4.44822;

T0_strike_dash(imag(T0_strike_dash) ~= 0) = NaN;
T0_strike_cruise_1(imag(T0_strike_cruise_1) ~= 0) = NaN;
T0_strike_cruise_2(imag(T0_strike_cruise_2) ~= 0) = NaN;
T0_strike_ceiling(imag(T0_strike_ceiling) ~= 0) = NaN;
T0_strike_climb_to(imag(T0_strike_climb_to) ~= 0) = NaN;
T0_strike_climb_ap(imag(T0_strike_climb_ap) ~= 0) = NaN;
T0_strike_climb_1(imag(T0_strike_climb_1) ~= 0) = NaN;
T0_strike_climb_2(imag(T0_strike_climb_2) ~= 0) = NaN;
T0_strike_climb_3(imag(T0_strike_climb_3) ~= 0) = NaN;
T0_strike_takeoff(imag(T0_strike_takeoff) ~= 0) = NaN;


% m^2 to ft^2
S_strike_max_g = S_strike_max_g ./ 0.092903;
S_strike_landing = S_strike_landing ./ 0.092903;
S_strike_catapult = S_strike_catapult ./ 0.092903;
S_strike_recovery = S_strike_recovery ./ 0.092903;

%% Plot Strike
S_plot = S ./ 0.092903;
T0_plot = T0 ./ 4.44822;

figure(4);
clf;
p1 = plot(S_plot, T0_strike_dash, "-r");
hold on;
p2 = plot(S_strike_max_g, T0_plot, "-", "color", "#808080");

p3 = plot(S_plot, T0_strike_cruise_1, "-", "color", "#0000FF");
p4 = plot(S_plot, T0_strike_cruise_2, "-", "color", "#6BADCE");
p5 = plot(S_plot, T0_strike_ceiling, "--", "color", "#734F96");

p6 = plot(S_plot, T0_strike_climb_to, "--", "color", "#1A2421");
p7 = plot(S_plot, T0_strike_climb_ap, "--", "color", "#0B6623");
p8 = plot(S_plot, T0_strike_climb_1, "-", "color", "#028A0F");
p9 = plot(S_plot, T0_strike_climb_2, "-", "color", "#028A0F");
p10 = plot(S_plot, T0_strike_climb_3, "-", "color", "#028A0F");

p11 = plot(S_plot, T0_strike_takeoff, "--", "color", "#222021");
p12 = plot(S_strike_landing, T0_plot, "-", "color", "#A52A2A");

p13 = plot(S_strike_catapult, T0_plot, "--", "color", "#7F00FF");
p14 = plot(S_strike_recovery, T0_plot, "-", "color", "#000000");

scatter(ac.initial.Sref ./ 0.092903, ac.initial.T_max ./ 4.44822, 100, [252, 106, 3]./255, "filled");

ylim([0, 80000]);
xlim([300, 1000]);
xlabel("$S (ft^2)$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$T (lb)$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221+width,6.861111111111111,width,height]);

dn = 5;
label_line(p1, 800, dn, "M0.9 Dash", "interpreter", "latex", "FontSize", fontsize);
label_line(p2, 410, -dn, "8g Vertical Load Factor~~", "interpreter", "latex", "FontSize", fontsize);
label_line(p3, 650, dn, "Cruise 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p4, 650, -dn, "Cruise 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p5, 780, dn, "50,000 ft Ceiling", "interpreter", "latex", "FontSize", fontsize);
label_line(p6, 900, dn, "SEROC Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p7, 900, dn, "SEROC Approach", "interpreter", "latex", "FontSize", fontsize);
label_line(p8, 800, dn, "Climb 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p9, 650, dn, "Climb 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p10, 900, -dn, "Climb 3", "interpreter", "latex", "FontSize", fontsize);
label_line(p11, 950, dn, "Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p12, 550, dn, "Landing~~", "interpreter", "latex", "FontSize", fontsize);
label_line(p13, 800, dn, "Catapult", "interpreter", "latex", "FontSize", fontsize);
label_line(p14, 570, dn, "Recovery~~", "interpreter", "latex", "FontSize", fontsize);
