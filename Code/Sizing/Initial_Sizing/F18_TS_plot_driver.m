%% Plot options
fontsize = 10;
width = 7;
height = 5;

%% Weights and weight fractions
F18_W0_driver;
Wefrac_reg = empty_weight_frac_reg("Raymer");

% TODO enforce identical polars or separate polars by mission
[ac] = iterate_W0_TS(ac, Wefrac_reg, @a2a_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS(ac, Wefrac_reg, @strike_Ffrac, ac.initial.T_max, ac.initial.Sref);

%% A2A constraints
n = 50;
S = linspace(300 .* 0.092903, 1000 .* 0.092903, n);
T0 = linspace(20000 .* 4.44822, 80000 .* 4.44822, n);

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

x_1_prev = [1, 0.5];
x_2_prev = [1, 0.5];
x_3_prev = [1, 0.5];
x_4_prev = [1, 0.5];
x_5_prev = [1, 0.5];
x_6_prev = [1, 0.5];
x_7_prev = [1, 0.5];
x_8_prev = [1, 0.5];
x_9_prev = [1, 0.5];
x_10_prev = [1, 0.5];
x_11_prev = [1, 0.5];
x_12_prev = [1, 0.5];
x_13_prev = [1, 0.5];
x_14_prev = [1, 0.5];

for i = n:-1:1
    % Dash
    Tfrac = get_thrust_frac(ac.a2a.M_dash, ac.a2a.h_dash, 1.08, true, false);
    [T0_a2a_dash(i), x_1_prev] = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @dash, Tfrac, x_1_prev);
    % Turn rate
    [T0_a2a_turn_rate(i), x_2_prev] = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @turn_rate, [], x_2_prev);
    % Vertical load factor
    [S_a2a_max_g(i), x_3_prev] = solveS4(ac, T0(i), Wefrac_reg, @a2a_Ffrac, @max_g, [], x_3_prev);

    % Cruise 1 and 2
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
    [T0_a2a_cruise_1(i), x_4_prev] = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @cruise_1, Tfrac, x_4_prev);
    [T0_a2a_cruise_2(i), x_5_prev] = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @cruise_2, Tfrac, x_5_prev);
    % Ceiling
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
    [T0_a2a_ceiling(i), x_6_prev] = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @ceiling, Tfrac, x_6_prev);

    % SEROC takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    [T0_a2a_climb_to(i), x_7_prev] = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @seroc_to, Tfrac, x_7_prev);
    % SEROC approach
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    [T0_a2a_climb_ap(i), x_8_prev] = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @seroc_ap, Tfrac, x_8_prev);
    % Climb 1
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    [T0_a2a_climb_1(i), x_9_prev] = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @climb_1, Tfrac, x_9_prev);
    % Climb 2
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    [T0_a2a_climb_2(i), x_10_prev] = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @climb_2, Tfrac, x_10_prev);

    % Takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    [T0_a2a_takeoff(i), x_11_prev] = solveT4(ac, S(i), Wefrac_reg, @a2a_Ffrac, @takeoff, Tfrac, x_11_prev);
    % Landing
    [S_a2a_landing(i), x_12_prev] = solveS4(ac, T0(i), Wefrac_reg, @a2a_Ffrac, @landing, [], x_12_prev);

    % Catapult
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    [S_a2a_catapult(i), x_13_prev] = solveS4(ac, T0(i), Wefrac_reg, @a2a_Ffrac, @catapult2, Tfrac, x_13_prev);
    % Recovery
    [S_a2a_recovery(i), x_14_prev] = solveS4(ac, T0(i), Wefrac_reg, @a2a_Ffrac, @recovery, [], x_14_prev);
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

%%
% AEP = zeros(n);
% for i = 1:n
%     for j = 1:n
%         F18_W0_driver;
%         [ac] = iterate_W0_TS(ac, Wefrac_reg, @a2a_Ffrac, T0(j), S(i));
%         [ac] = iterate_W0_TS(ac, Wefrac_reg, @strike_Ffrac, T0(j), S(i));
%         cst = cost(ac);
%         AEP(i, j) = cst.unit.AEP;
%     end
% end

%% Weights and weight fractions
F18_W0_driver;
Wefrac_reg = empty_weight_frac_reg("Raymer");

% TODO enforce identical polars or separate polars by mission
[ac] = iterate_W0_TS(ac, Wefrac_reg, @a2a_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS(ac, Wefrac_reg, @strike_Ffrac, ac.initial.T_max, ac.initial.Sref);

%% Plot A2A
S_plot = S ./ 0.092903;
T0_plot = T0 ./ 4.44822;

[S_grid, T0_grid] = meshgrid(S_plot, T0_plot);

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

scatter(ac.initial.Sref ./ 0.092903, ac.initial.T_max ./ 4.44822, 20, [252, 106, 3]./255, "filled");

% AEP(imag(AEP)~=0) = NaN;
% contour(S_grid, T0_grid, AEP./1e6, "-k", "ShowText", "on");

shadeRegion({S_plot, S_a2a_max_g, S_plot, S_plot, S_a2a_catapult, S_a2a_landing}, {T0_a2a_dash, T0_plot, T0_a2a_climb_to, T0_a2a_takeoff, T0_plot, T0_plot}, {'lower', 'upper', 'lower', 'lower', 'upper', 'upper'}, [370, 1000, 100]);
text(700, 5e4, "Feasible", "HorizontalAlignment", "center", "Interpreter", "latex", "FontSize", fontsize);
text(ac.initial.Sref ./ 0.092903, ac.initial.T_max ./ 4.44822, "~~~F/A-18E", "HorizontalAlignment", "left", "Interpreter", "latex", "FontSize", fontsize);

ylim([0, 80000]);
xlim([300, 1000]);
xlabel("$S (ft^2)$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$T (lb)$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221,6.861111111111111,width,height]);

dn = 5;
label_line(p1, 700, -dn, "M1.6 Dash", "interpreter", "latex", "FontSize", fontsize);
label_line(p2, 550, -dn, "8 deg/s Sustained Turn", "interpreter", "latex", "FontSize", fontsize);
label_line(p3, 360, -dn, "8g Vertical Load Factor", "interpreter", "latex", "FontSize", fontsize);
label_line(p4, 700, dn, "Cruise 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p5, 700, -dn, "Cruise 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p6, 700, -dn, "50,000 ft Ceiling", "interpreter", "latex", "FontSize", fontsize);
label_line(p7, 700, dn, "SEROC Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p8, 700, dn, "SEROC Approach", "interpreter", "latex", "FontSize", fontsize);
label_line(p9, 700, dn, "Climb 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p10, 700, -dn, "Climb 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p11, 560, dn, "Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p12, 450, dn, "Landing", "interpreter", "latex", "FontSize", fontsize);
label_line(p13, 500, dn, "Catapult", "interpreter", "latex", "FontSize", fontsize);
label_line(p14, 350, dn, "Recovery", "interpreter", "latex", "FontSize", fontsize);

saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/F18_TS_a2a.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/F18_TS_a2a.png", "Resolution", 1000);

%% Weights and weight fractions
F18_W0_driver;
Wefrac_reg = empty_weight_frac_reg("Raymer");

% TODO enforce identical polars or separate polars by mission
[ac] = iterate_W0_TS(ac, Wefrac_reg, @a2a_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS(ac, Wefrac_reg, @strike_Ffrac, ac.initial.T_max, ac.initial.Sref);

%% Strike constraints
n = 50;
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

x_1_prev = [1, 0.5];
x_2_prev = [1, 0.5];
x_3_prev = [1, 0.5];
x_4_prev = [1, 0.5];
x_5_prev = [1, 0.5];
x_6_prev = [1, 0.5];
x_7_prev = [1, 0.5];
x_8_prev = [1, 0.5];
x_9_prev = [1, 0.5];
x_10_prev = [1, 0.5];
x_11_prev = [1, 0.5];
x_12_prev = [1, 0.5];
x_13_prev = [1, 0.5];
x_14_prev = [1, 0.5];

for i = n:-1:1
    % Dash
    Tfrac = get_thrust_frac(ac.strike.M_dash, ac.strike.h_combat, 1.08, true, false);
    [T0_strike_dash(i), x_1_prev] = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @dash, Tfrac, x_1_prev);
    % Vertical load factor
    [S_strike_max_g(i), x_2_prev] = solveS4(ac, T0(i), Wefrac_reg, @strike_Ffrac, @max_g, [], x_2_prev);

    % Cruise 1 and 2
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
    [T0_strike_cruise_1(i), x_3_prev] = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @cruise_1, Tfrac, x_3_prev);
    [T0_strike_cruise_2(i), x_4_prev] = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @cruise_2, Tfrac, x_4_prev);
    % Ceiling
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
    [T0_strike_ceiling(i), x_5_prev] = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @ceiling, Tfrac, x_5_prev);

    % SEROC takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    [T0_strike_climb_to(i), x_6_prev] = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @seroc_to, Tfrac, x_6_prev);
    % SEROC approach
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    [T0_strike_climb_ap(i), x_7_prev] = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @seroc_ap, Tfrac, x_7_prev);
    % Climb 1
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    [T0_strike_climb_1(i), x_8_prev] = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @climb_1, Tfrac, x_8_prev);
    % Climb 2
    Tfrac = get_thrust_frac(ac.strike.M_dash, 0, 1.08, false, false);
    [T0_strike_climb_2(i), x_9_prev] = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @climb_2, Tfrac, x_9_prev);
    % Climb 3
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    [T0_strike_climb_3(i), x_10_prev] = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @climb_3, Tfrac, x_10_prev);

    % Takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    [T0_strike_takeoff(i), x_11_prev] = solveT4(ac, S(i), Wefrac_reg, @strike_Ffrac, @takeoff, Tfrac, x_11_prev);
    % Landing
    [S_strike_landing(i), x_12_prev] = solveS4(ac, T0(i), Wefrac_reg, @strike_Ffrac, @landing, [], x_12_prev);

    % Catapult
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    [S_strike_catapult(i), x_13_prev] = solveS4(ac, T0(i), Wefrac_reg, @strike_Ffrac, @catapult2, Tfrac, x_13_prev);
    % Recovery
    [S_strike_recovery(i), x_14_prev] = solveS4(ac, T0(i), Wefrac_reg, @strike_Ffrac, @recovery, [], x_14_prev);
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

scatter(ac.initial.Sref ./ 0.092903, ac.initial.T_max ./ 4.44822, 20, [252, 106, 3]./255, "filled");

% contour(S_grid, T0_grid, AEP./1e6, "-k", "ShowText", "on", "EdgeAlpha", 0.2);

shadeRegion({S_plot, S_plot, S_strike_catapult, S_strike_landing}, {T0_strike_climb_to, T0_strike_takeoff, T0_plot, T0_plot}, {'lower', 'lower', 'upper', 'upper'}, [400, 1000, 100]);
text(700, 5e4, "Feasible", "HorizontalAlignment", "center", "Interpreter", "latex", "FontSize", fontsize);
text(ac.initial.Sref ./ 0.092903, ac.initial.T_max ./ 4.44822, "~~~F/A-18E", "HorizontalAlignment", "left", "Interpreter", "latex", "FontSize", fontsize);

ylim([0, 80000]);
xlim([300, 1000]);
xlabel("$S (ft^2)$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$T (lb)$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221+width,6.861111111111111,width,height]);

dn = 5;
label_line(p1, 500, -dn, "M0.9 Dash", "interpreter", "latex", "FontSize", fontsize);
label_line(p2, 325, -dn, "8g Vertical Load Factor", "interpreter", "latex", "FontSize", fontsize);
label_line(p3, 500, dn, "Cruise 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p4, 400, dn, "Cruise 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p5, 900, dn, "50,000 ft Ceiling", "interpreter", "latex", "FontSize", fontsize);
label_line(p6, 900, dn, "SEROC Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p7, 900, dn, "SEROC Approach", "interpreter", "latex", "FontSize", fontsize);
label_line(p8, 600, dn, "Climb 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p9, 600, dn, "Climb 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p10, 600, -dn, "Climb 3", "interpreter", "latex", "FontSize", fontsize);
label_line(p11, 800, dn, "Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p12, 510, dn, "Landing", "interpreter", "latex", "FontSize", fontsize);
label_line(p13, 510, dn, "Catapult", "interpreter", "latex", "FontSize", fontsize);
label_line(p14, 430, dn, "Recovery", "interpreter", "latex", "FontSize", fontsize);

saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/F18_TS_strike.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/F18_TS_strike.png", "Resolution", 1000);