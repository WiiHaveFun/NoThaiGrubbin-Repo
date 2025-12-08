%% Plot options
fontsize = 10;
width = 6.5;
height = 4;

%% Weights and weight fractions
ac = aircraft();
ac.initial.T_max = ac.initial.T_max*0.9;
ac.initial.T_mil = ac.initial.T_mil*0.9;

% TODO enforce identical polars or separate polars by mission
[ac] = iterate_W0_TS_ref(ac, @a2a_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS_ref(ac, @strike_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);

%% A2A constraints
n = 50;
S = linspace(400 .* 0.092903, 800 .* 0.092903, n);
T0 = linspace(20000 .* 4.44822, 80000 .* 4.44822, n);

T0_a2a_dash = zeros(size(n, 1));
T0_a2a_turn_rate = zeros(size(n, 1));
T0_a2a_turn_rate_2 = zeros(size(n, 1));
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

x_1_prev = [1, 1];
x_2_prev = [1, 1];
x_2_prev_2 = [1, 1];
x_3_prev = [1, 1];
x_4_prev = [1, 1];
x_5_prev = [1, 1];
x_6_prev = [1, 1];
x_7_prev = [1, 1];
x_8_prev = [1, 1];
x_9_prev = [1, 1];
x_10_prev = [1,1];
x_11_prev = [1, 1];
x_12_prev = [1, 1];
x_13_prev = [1, 1];
x_14_prev = [1, 1];

tic;
parpool(8);
for i = n:-1:1
    % Dash
    Tfrac = get_thrust_frac(ac.a2a.M_dash, ac.a2a.h_dash, 1.08, true, false);
    f1 = parfeval(@solveT5, 2, ac, S(i), @a2a_ref_Ffrac, @dash, Tfrac, x_1_prev);
    % [T0_a2a_dash(i), x_1_prev] = solveT5(ac, S(i), @a2a_ref_Ffrac, @dash, Tfrac, x_1_prev);
    % Turn rate
    f2 = parfeval(@solveT5, 2, ac, S(i), @a2a_ref_Ffrac, @turn_rate_ref, [], x_2_prev);
    % [T0_a2a_turn_rate(i), x_2_prev] = solveT5(ac, S(i), @a2a_ref_Ffrac, @turn_rate_ref, [], x_2_prev);
    % [T0_a2a_turn_rate_2(n+1-i), x_2_prev_2] = solveT5(ac, S(n+1-i), @a2a_ref_Ffrac, @turn_rate, [], x_2_prev_2);
    % Vertical load factor
    f3 = parfeval(@solveS5, 2, ac, T0(i), @a2a_ref_Ffrac, @max_g, [], x_3_prev);
    % [S_a2a_max_g(i), x_3_prev] = solveS5(ac, T0(i), @a2a_ref_Ffrac, @max_g, [], x_3_prev);

    % Cruise 1 and 2
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
    f4 = parfeval(@solveT5, 2, ac, S(i), @a2a_ref_Ffrac, @cruise_1, Tfrac, x_4_prev);
    f5 = parfeval(@solveT5, 2, ac, S(i), @a2a_ref_Ffrac, @cruise_2, Tfrac, x_5_prev);
    % [T0_a2a_cruise_1(i), x_4_prev] = solveT5(ac, S(i), @a2a_ref_Ffrac, @cruise_1, Tfrac, x_4_prev);
    % [T0_a2a_cruise_2(i), x_5_prev] = solveT5(ac, S(i), @a2a_ref_Ffrac, @cruise_2, Tfrac, x_5_prev);
    % Ceiling
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
    f6 = parfeval(@solveT5, 2, ac, S(i), @a2a_ref_Ffrac, @ceiling, Tfrac, x_6_prev);
    % [T0_a2a_ceiling(i), x_6_prev] = solveT5(ac, S(i), @a2a_ref_Ffrac, @ceiling, Tfrac, x_6_prev);

    % SEROC takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    f7 = parfeval(@solveT5, 2, ac, S(i), @a2a_ref_Ffrac, @seroc_to, Tfrac, x_7_prev);
    % [T0_a2a_climb_to(i), x_7_prev] = solveT5(ac, S(i), @a2a_ref_Ffrac, @seroc_to, Tfrac, x_7_prev);
    % SEROC approach
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    f8 = parfeval(@solveT5, 2, ac, S(i), @a2a_ref_Ffrac, @seroc_ap, Tfrac, x_8_prev);
    % [T0_a2a_climb_ap(i), x_8_prev] = solveT5(ac, S(i), @a2a_ref_Ffrac, @seroc_ap, Tfrac, x_8_prev);
    % Climb 1
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    f9 = parfeval(@solveT5, 2, ac, S(i), @a2a_ref_Ffrac, @climb_1, Tfrac, x_9_prev);
    % [T0_a2a_climb_1(i), x_9_prev] = solveT5(ac, S(i), @a2a_ref_Ffrac, @climb_1, Tfrac, x_9_prev);
    % Climb 2
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    f10 = parfeval(@solveT5, 2, ac, S(i), @a2a_ref_Ffrac, @climb_2, Tfrac, x_10_prev);
    % [T0_a2a_climb_2(i), x_10_prev] = solveT5(ac, S(i), @a2a_ref_Ffrac, @climb_2, Tfrac, x_10_prev);

    % Takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    f11 = parfeval(@solveT5, 2, ac, S(i), @a2a_ref_Ffrac, @takeoff, Tfrac, x_11_prev);
    % [T0_a2a_takeoff(i), x_11_prev] = solveT5(ac, S(i), @a2a_ref_Ffrac, @takeoff, Tfrac, x_11_prev);
    % Landing
    f12 = parfeval(@solveS5, 2, ac, T0(i), @a2a_ref_Ffrac, @landing, [], x_12_prev);
    % [S_a2a_landing(i), x_12_prev] = solveS5(ac, T0(i), @a2a_ref_Ffrac, @landing, [], x_12_prev);

    % Catapult
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    f13 = parfeval(@solveS5, 2, ac, T0(i), @a2a_ref_Ffrac, @catapult2, Tfrac, x_13_prev);
    % [S_a2a_catapult(i), x_13_prev] = solveS5(ac, T0(i), @a2a_ref_Ffrac, @catapult2, Tfrac, x_13_prev);
    % Recovery
    f14 = parfeval(@solveS5, 2, ac, T0(i), @a2a_ref_Ffrac, @recovery, [], x_14_prev);
    % [S_a2a_recovery(i), x_14_prev] = solveS5(ac, T0(i), @a2a_ref_Ffrac, @recovery, [], x_14_prev);

    [T0_a2a_dash(i), x_1_prev] = fetchOutputs(f1);
    [T0_a2a_turn_rate(i), x_2_prev] = fetchOutputs(f2);
    [S_a2a_max_g(i), x_3_prev] = fetchOutputs(f3);
    [T0_a2a_cruise_1(i), x_4_prev] = fetchOutputs(f4);
    [T0_a2a_cruise_2(i), x_5_prev] = fetchOutputs(f5);
    [T0_a2a_ceiling(i), x_6_prev] = fetchOutputs(f6);
    [T0_a2a_climb_to(i), x_7_prev] = fetchOutputs(f7);
    [T0_a2a_climb_ap(i), x_8_prev] = fetchOutputs(f8);
    [T0_a2a_climb_1(i), x_9_prev] = fetchOutputs(f9);
    [T0_a2a_climb_2(i), x_10_prev] = fetchOutputs(f10);
    [T0_a2a_takeoff(i), x_11_prev] = fetchOutputs(f11);
    [S_a2a_landing(i), x_12_prev] = fetchOutputs(f12);
    [S_a2a_catapult(i), x_13_prev] = fetchOutputs(f13);
    [S_a2a_recovery(i), x_14_prev] = fetchOutputs(f14);
    disp(i);
end
delete(gcp("nocreate"));
toc;

% N to lb
T0_a2a_dash = T0_a2a_dash ./ 4.44822;
T0_a2a_turn_rate = T0_a2a_turn_rate ./ 4.44822;
T0_a2a_turn_rate_2 = T0_a2a_turn_rate_2 ./ 4.44822;
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
T0_a2a_turn_rate_2(imag(T0_a2a_turn_rate_2) ~= 0) = NaN;
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

save('a2a_TS_ref.mat');

%%
n = 20;
AEP = zeros(n);
a2a_W0 = zeros(n);

S2 = linspace(350 .* 0.092903, 800 .* 0.092903, n);
T02 = linspace(8000 .* 4.44822, 80000 .* 4.44822, n);

tic
parpool(8);
parfor i = 1:n
    for j = 1:n
        ac = aircraft();
        ac.initial.T_max = ac.initial.T_max*0.9;
        ac.initial.T_mil = ac.initial.T_mil*0.9;
        [ac] = iterate_W0_TS_ref_2(ac, @a2a_ref_Ffrac, T02(i), S2(j));
        [ac] = iterate_W0_TS_ref_2(ac, @strike_ref_Ffrac, T02(i), S2(j));
        a2a_W0(i, j) = ac.a2a.W0;
        cst = cost(ac);
        AEP(i, j) = cst.unit.AEP;
    end
end
delete(gcp("nocreate"));
toc

save("AEP_CDR.mat", "AEP");

%% Weights and weight fractions
ac = aircraft();
ac.initial.T_max = ac.initial.T_max*0.9;
ac.initial.T_mil = ac.initial.T_mil*0.9;

% TODO enforce identical polars or separate polars by mission
[ac] = iterate_W0_TS_ref(ac, @a2a_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS_ref(ac, @strike_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);

%% Plot A2A
S_plot = S ./ 0.092903;
T0_plot = T0 ./ 4.44822;

S2_plot = S2 ./ 0.092903;
T02_plot = T02 ./ 4.44822;

[S_grid, T0_grid] = meshgrid(S2_plot, T02_plot);
% TW_grid = T0_grid ./ (a2a_W0 ./ 4.44822);
% TW_grid(imag(TW_grid)~=0) = NaN;
% WS_grid = a2a_W0 ./ 4.44822 ./ S_plot;
% WS_grid(imag(WS_grid)~=0) = NaN;
% a2a_W0(imag(a2a_W0)~=0) = NaN;

figure(5);
clf;
p1 = plot(S_plot, T0_a2a_dash, "--r");
hold on;
p2 = plot(S_plot, T0_a2a_turn_rate, "--", "color", "#F9A603");
p2_2 = plot(S_plot, T0_a2a_turn_rate_2, "--", "color", "#F9A603");
p3 = plot(S_a2a_max_g, T0_plot, "-", "color", "#808080");

p4 = plot(S_plot, T0_a2a_cruise_1, "-", "color", "#0000FF");
p5 = plot(S_plot, T0_a2a_cruise_2, "-", "color", "#6BADCE");
p6 = plot(S_plot, T0_a2a_ceiling, "--", "color", "#734F96");

p7 = plot(S_plot, T0_a2a_climb_to, "--", "color", "#2EB774");
p8 = plot(S_plot, T0_a2a_climb_ap, "--", "color", "#0B6623");
p9 = plot(S_plot, T0_a2a_climb_1, "-", "color", "#028A0F");
p10 = plot(S_plot, T0_a2a_climb_2, "-", "color", "#028A0F");

p11 = plot(S_plot, T0_a2a_takeoff, "-", "color", "#222021");
p12 = plot(S_a2a_landing, T0_plot, "-", "color", "#A52A2A");

p13 = plot(S_a2a_catapult, T0_plot, "--", "color", "#7F00FF");
p14 = plot(S_a2a_recovery, T0_plot, "-", "color", "#000000");

scatter(ac.initial.Sref ./ 0.092903, ac.initial.T_max ./ 4.44822, 20, [252, 106, 3]./255, "filled");
% scatter(ac.initial.Sref ./ 0.092903, ac.initial.T_mil ./ 4.44822, 20, "k", "filled");

% AEP(imag(AEP)~=0) = NaN;
[C1, p15] = contour(S_grid, T0_grid, 500.*AEP./1e9, 44:0.5:55, "-k", "ShowText", "on", "EdgeAlpha", 0.2, "LabelSpacing", 400);
% contour(S_grid, T0_grid, TW_grid, linspace(0, 2, 9), "-r", "ShowText", "on");
% contour(S_grid, T0_grid, WS_grid, linspace(50, 120, 9), "-g", "ShowText", "on");
% contour(S_grid, T0_grid, a2a_W0 ./ 4.44822 ./ 1e3, "-b", "ShowText", "on");
clabel(C1, p15, "Interpreter", "latex", "FontSize", fontsize);

shadeRegion({S_plot, S_plot, S_a2a_catapult, S_a2a_landing}, {T0_a2a_dash, T0_a2a_takeoff, T0_plot, T0_plot}, {'lower', 'lower', 'upper', 'upper'}, [500, 1000, 100]);
text(700, 6.5e4, "Feasible", "HorizontalAlignment", "center", "Interpreter", "latex", "FontSize", fontsize);
text(ac.initial.Sref ./ 0.092903, ac.initial.T_max ./ 4.44822, "Design Point (Max)~", "HorizontalAlignment", "right", "Interpreter", "latex", "FontSize", fontsize);
% text(ac.initial.Sref ./ 0.092903, ac.initial.T_mil ./ 4.44822, "Design Point (Mil)~", "HorizontalAlignment", "right", "Interpreter", "latex", "FontSize", fontsize);

legend(p15, "Flyaway Cost 500 Units (\$B 2025)", "Interpreter", "latex", "FontSize", fontsize);

ylim([10000, 80000]);
xlim([500, 800]);
xlabel("$S (ft^2)$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$T (lb)$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

% set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221,6.861111111111111,width,height]);
set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);


dn = 5;
label_line(p1, 700, dn, "M1.65 Dash", "interpreter", "latex", "FontSize", fontsize);
label_line(p2, 600, -dn, "10 deg/s Sustained Turn", "interpreter", "latex", "FontSize", fontsize);
label_line(p3, 550, -dn, "8g Vertical Load Factor", "interpreter", "latex", "FontSize", fontsize);
label_line(p4, 550, dn, "Cruise 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p5, 550, dn, "Cruise 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p6, 540, dn, "50,000 ft Ceiling", "interpreter", "latex", "FontSize", fontsize);
label_line(p7, 750, dn, "SEROC Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p8, 750, dn, "SEROC Approach", "interpreter", "latex", "FontSize", fontsize);
label_line(p9, 550, dn, "Climb 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p10, 550, dn, "Climb 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p11, 600, dn, "Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p12, 550, dn, "Landing", "interpreter", "latex", "FontSize", fontsize);
label_line(p13, 600, dn, "Catapult", "interpreter", "latex", "FontSize", fontsize);
label_line(p14, 550, -dn, "Recovery", "interpreter", "latex", "FontSize", fontsize);

saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/TS_a2a_cdr.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/TS_a2a_cdr.png", "Resolution", 1000);
% set(gcf, 'Renderer', 'painters');
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/TS_a2a.pdf", "ContentType", "vector");

%% Weights and weight fractions
ac = aircraft();
ac.initial.T_max = ac.initial.T_max*0.9;
ac.initial.T_mil = ac.initial.T_mil*0.9;

% TODO enforce identical polars or separate polars by mission
[ac] = iterate_W0_TS_ref(ac, @a2a_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS_ref(ac, @strike_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);

%% Strike constraints
n = 50;
S = linspace(350 .* 0.092903, 800 .* 0.092903, n);
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

x_1_prev = [1, 1];
x_2_prev = [1, 1];
x_3_prev = [1, 1];
x_4_prev = [1, 1];
x_5_prev = [1, 1];
x_6_prev = [1, 1];
x_7_prev = [1, 1];
x_8_prev = [1, 1];
x_9_prev = [1, 1];
x_10_prev = [1, 1];
x_11_prev = [1, 1];
x_12_prev = [1, 1];
x_13_prev = [1, 1];
x_14_prev = [1, 1];

tic;
parpool(8);
for i = n:-1:1
    % Dash
    Tfrac = get_thrust_frac(ac.strike.M_dash, ac.strike.h_combat, 1.08, true, false);
    f1 = parfeval(@solveT5, 2, ac, S(i), @strike_ref_Ffrac, @dash, Tfrac, x_1_prev);
    % [T0_strike_dash(i), x_1_prev] = solveT5(ac, S(i), @strike_ref_Ffrac, @dash, Tfrac, x_1_prev);
    % Vertical load factor
    f2 = parfeval(@solveS5, 2, ac, T0(i), @strike_ref_Ffrac, @max_g, [], x_2_prev);
    % [S_strike_max_g(i), x_2_prev] = solveS5(ac, T0(i), @strike_ref_Ffrac, @max_g, [], x_2_prev);

    % Cruise 1 and 2
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
    f3 = parfeval(@solveT5, 2, ac, S(i), @strike_ref_Ffrac, @cruise_1, Tfrac, x_3_prev);
    f4 = parfeval(@solveT5, 2, ac, S(i), @strike_ref_Ffrac, @cruise_2, Tfrac, x_4_prev);
    % [T0_strike_cruise_1(i), x_3_prev] = solveT5(ac, S(i), @strike_ref_Ffrac, @cruise_1, Tfrac, x_3_prev);
    % [T0_strike_cruise_2(i), x_4_prev] = solveT5(ac, S(i), @strike_ref_Ffrac, @cruise_2, Tfrac, x_4_prev);
    % Ceiling
    Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
    f5 = parfeval(@solveT5, 2, ac, S(i), @strike_ref_Ffrac, @ceiling, Tfrac, x_5_prev);
    % [T0_strike_ceiling(i), x_5_prev] = solveT5(ac, S(i), @strike_ref_Ffrac, @ceiling, Tfrac, x_5_prev);

    % SEROC takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    f6 = parfeval(@solveT5, 2, ac, S(i), @strike_ref_Ffrac, @seroc_to, Tfrac, x_6_prev);
    % [T0_strike_climb_to(i), x_6_prev] = solveT5(ac, S(i), @strike_ref_Ffrac, @seroc_to, Tfrac, x_6_prev);
    % SEROC approach
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    f7 = parfeval(@solveT5, 2, ac, S(i), @strike_ref_Ffrac, @seroc_ap, Tfrac, x_7_prev);
    % [T0_strike_climb_ap(i), x_7_prev] = solveT5(ac, S(i), @strike_ref_Ffrac, @seroc_ap, Tfrac, x_7_prev);
    % Climb 1
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    f8 = parfeval(@solveT5, 2, ac, S(i), @strike_ref_Ffrac, @climb_1, Tfrac, x_8_prev);
    % [T0_strike_climb_1(i), x_8_prev] = solveT5(ac, S(i), @strike_ref_Ffrac, @climb_1, Tfrac, x_8_prev);
    % Climb 2
    Tfrac = get_thrust_frac(ac.strike.M_dash, 0, 1.08, false, false);
    f9 = parfeval(@solveT5, 2, ac, S(i), @strike_ref_Ffrac, @climb_2, Tfrac, x_9_prev);
    % [T0_strike_climb_2(i), x_9_prev] = solveT5(ac, S(i), @strike_ref_Ffrac, @climb_2, Tfrac, x_9_prev);
    % Climb 3
    Tfrac = get_thrust_frac(0, 0, 1.08, false, false);
    f10 = parfeval(@solveT5, 2, ac, S(i), @strike_ref_Ffrac, @climb_3, Tfrac, x_10_prev);
    % [T0_strike_climb_3(i), x_10_prev] = solveT5(ac, S(i), @strike_ref_Ffrac, @climb_3, Tfrac, x_10_prev);

    % Takeoff
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    f11 = parfeval(@solveT5, 2, ac, S(i), @strike_ref_Ffrac, @takeoff, Tfrac, x_11_prev);
    % [T0_strike_takeoff(i), x_11_prev] = solveT5(ac, S(i), @strike_ref_Ffrac, @takeoff, Tfrac, x_11_prev);
    % Landing
    f12 = parfeval(@solveS5, 2, ac, T0(i), @strike_ref_Ffrac, @landing, [], x_12_prev);
    % [S_strike_landing(i), x_12_prev] = solveS5(ac, T0(i), @strike_ref_Ffrac, @landing, [], x_12_prev);

    % Catapult
    Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
    f13 = parfeval(@solveS5, 2, ac, T0(i), @strike_ref_Ffrac, @catapult2, Tfrac, x_13_prev);
    % [S_strike_catapult(i), x_13_prev] = solveS5(ac, T0(i), @strike_ref_Ffrac, @catapult2, Tfrac, x_13_prev);
    % Recovery
    f14 = parfeval(@solveS5, 2, ac, T0(i), @strike_ref_Ffrac, @recovery, [], x_14_prev);
    % [S_strike_recovery(i), x_14_prev] = solveS5(ac, T0(i), @strike_ref_Ffrac, @recovery, [], x_14_prev);

    [T0_strike_dash(i), x_1_prev] = fetchOutputs(f1);
    [S_strike_max_g(i), x_2_prev] = fetchOutputs(f2);
    [T0_strike_cruise_1(i), x_3_prev] = fetchOutputs(f3);
    [T0_strike_cruise_2(i), x_4_prev] = fetchOutputs(f4);
    [T0_strike_ceiling(i), x_5_prev] = fetchOutputs(f5);
    [T0_strike_climb_to(i), x_6_prev] = fetchOutputs(f6);
    [T0_strike_climb_ap(i), x_7_prev] = fetchOutputs(f7);
    [T0_strike_climb_1(i), x_8_prev] = fetchOutputs(f8);
    [T0_strike_climb_2(i), x_9_prev] = fetchOutputs(f9);
    [T0_strike_climb_3(i), x_10_prev] = fetchOutputs(f10);
    [T0_strike_takeoff(i), x_11_prev] = fetchOutputs(f11);
    [S_strike_landing(i), x_12_prev] = fetchOutputs(f12);
    [S_strike_catapult(i), x_13_prev] = fetchOutputs(f13);
    [S_strike_recovery(i), x_14_prev] = fetchOutputs(f14);
    disp(i);
end
delete(gcp("nocreate"));
toc;

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

S2_plot = S2 ./ 0.092903;
T02_plot = T02 ./ 4.44822;

[S_grid, T0_grid] = meshgrid(S2_plot, T02_plot);

figure(4);
clf;
p1 = plot(S_plot, T0_strike_dash, "-r");
hold on;
p2 = plot(S_strike_max_g, T0_plot, "-", "color", "#808080");

p3 = plot(S_plot, T0_strike_cruise_1, "-", "color", "#0000FF");
p4 = plot(S_plot, T0_strike_cruise_2, "-", "color", "#6BADCE");
p5 = plot(S_plot, T0_strike_ceiling, "--", "color", "#734F96");

p6 = plot(S_plot, T0_strike_climb_to, "--", "color", "#2EB774");
p7 = plot(S_plot, T0_strike_climb_ap, "--", "color", "#0B6623");
p8 = plot(S_plot, T0_strike_climb_1, "-", "color", "#028A0F");
p9 = plot(S_plot, T0_strike_climb_2, "-", "color", "#028A0F");
p10 = plot(S_plot, T0_strike_climb_3, "-", "color", "#028A0F");

p11 = plot(S_plot, T0_strike_takeoff, "-", "color", "#222021");
p12 = plot(S_strike_landing, T0_plot, "-", "color", "#A52A2A");

p13 = plot(S_strike_catapult, T0_plot, "--", "color", "#7F00FF");
p14 = plot(S_strike_recovery, T0_plot, "-", "color", "#000000");

scatter(ac.initial.Sref ./ 0.092903, ac.initial.T_max ./ 4.44822, 20, [252, 106, 3]./255, "filled");
scatter(ac.initial.Sref ./ 0.092903, ac.initial.T_mil ./ 4.44822, 20, "k", "filled");

[C1, p15] = contour(S_grid, T0_grid, 500.*AEP./1e9, 44:0.5:55, "-k", "ShowText", "on", "EdgeAlpha", 0.2, "LabelSpacing", 400);
clabel(C1, p15, "Interpreter", "latex", "FontSize", fontsize);

shadeRegion({S_plot, S_strike_max_g, S_plot, S_plot, S_plot, S_plot, S_plot, S_plot, S_plot, S_plot, S_plot, S_strike_landing, S_strike_catapult, S_strike_recovery}, ...
            {T0_strike_dash, T0_plot, T0_strike_cruise_1, T0_strike_cruise_2, T0_strike_ceiling, ...
             T0_strike_climb_to, T0_strike_climb_ap, T0_strike_climb_1, T0_strike_climb_2, T0_strike_climb_3, ...
             T0_strike_takeoff, T0_plot, T0_plot, T0_plot}, ...
            {'lower', 'upper', 'lower', 'lower', 'lower', ...
             'lower', 'lower', 'lower', 'lower', 'lower', ...
             'lower', 'upper', 'upper', 'upper'}, [500, 1000, 1000]);
text(700, 5e4, "Feasible", "HorizontalAlignment", "center", "Interpreter", "latex", "FontSize", fontsize);
text(ac.initial.Sref ./ 0.092903, ac.initial.T_max ./ 4.44822, "Design Point (Max)~~~", "HorizontalAlignment", "right", "Interpreter", "latex", "FontSize", fontsize);
text(ac.initial.Sref ./ 0.092903, ac.initial.T_mil ./ 4.44822, "Design Point (Mil)~~~", "HorizontalAlignment", "right", "Interpreter", "latex", "FontSize", fontsize);

legend(p15, "Flyaway Cost 500 Units (\$B 2025)", "Interpreter", "latex", "FontSize", fontsize);

ylim([8000, 80000]);
xlim([350, 800]);
xlabel("$S (ft^2)$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$T (lb)$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

% set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221+width,6.861111111111111,width,height]);
set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221+width,6.861111111111111,width,height]);

dn = 5;
label_line(p1, 400, dn, "M0.9 Dash", "interpreter", "latex", "FontSize", fontsize);
label_line(p2, 380, dn, "8g Vertical Load Factor", "interpreter", "latex", "FontSize", fontsize);
label_line(p3, 400, dn, "Cruise 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p4, 400, dn, "Cruise 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p5, 440, dn, "50,000 ft Ceiling", "interpreter", "latex", "FontSize", fontsize);
label_line(p6, 600, dn, "SEROC Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p7, 700, dn, "SEROC Approach", "interpreter", "latex", "FontSize", fontsize);
label_line(p8, 550, dn, "Climb 1", "interpreter", "latex", "FontSize", fontsize);
label_line(p9, 550, -dn, "Climb 2", "interpreter", "latex", "FontSize", fontsize);
label_line(p10, 600, -dn, "Climb 3", "interpreter", "latex", "FontSize", fontsize);
label_line(p11, 400, dn, "Takeoff", "interpreter", "latex", "FontSize", fontsize);
label_line(p12, 520, dn, "Landing", "interpreter", "latex", "FontSize", fontsize);
label_line(p13, 525, dn, "Catapult", "interpreter", "latex", "FontSize", fontsize);
label_line(p14, 520, -dn, "Recovery", "interpreter", "latex", "FontSize", fontsize);

% saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/TS_strike_cdr.svg");
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/TS_strike_cdr.png", "Resolution", 1000);
% set(gcf, 'Renderer', 'painters');
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/TS_strike.pdf", "ContentType", "vector");
