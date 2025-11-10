%% Design CL (mid mission weight)
[~, a, ~, rho] = atmoscoesa(ac.initial.h_cruise);
V = ac.initial.M_cruise .* a;
CL = 2 .* 2.8077e5 .* 0.8804 ./ (rho .* V.^2 .* ac.initial.Sref);

%% Drag buildup
fontsize = 10;
width = 6.5;
height = 5;

ac = aircraft;
% ac.sup.Amax = 79.30 .* 0.092903;
% ac.sup.Ewd = 1.8;
% ac.sup.l = 2 .* 31.25 .* 0.3048;

flap = "no";
gear = false;
tanks = true;
hook = false;
p = drag_polar(ac, flap, gear, tanks, hook);

figure(1);
clf;
tiledlayout(3, 1, "TileSpacing", "tight");

% Clean (Cruise altitude)
nexttile;
p.plot_CD0(ac.initial.h_cruise);
xlabel("$M$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$C_{D0}$", "Interpreter", "latex", "FontSize", fontsize);
legend("Skin friction", ...
       "Miscellaneous", ...
       "Flap", ...
       "Leakages and protuberances", ...
       "Wave", ...
       "Interpreter", "latex", "FontSize", fontsize, "Location", "northeastoutside");
title("Cruise", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

% Takeoff
nexttile;
flap = "full";
gear = true;
tanks = true;
hook = false;
p = drag_polar(ac, flap, gear, tanks, hook);
p.plot_CD0(0);
xlabel("$M$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$C_{D0}$", "Interpreter", "latex", "FontSize", fontsize);
title("Takeoff", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

% Approach
nexttile;
flap = "half";
gear = true;
tanks = true;
hook = true;
p = drag_polar(ac, flap, gear, tanks, hook);
p.plot_CD0(0);
xlabel("$M$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$C_{D0}$", "Interpreter", "latex", "FontSize", fontsize);
title("Approach", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);
set(gcf, 'Renderer', 'painters');
exportgraphics(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/A8_drag.pdf", "ContentType", "vector");

%% Polars
fontsize = 10;
width = 6.5;
height = 3;

figure(2);
clf;

h = ac.initial.h_cruise;
M = ac.initial.M_cruise;

flap = "no";
gear = false;
tanks = true;
hook = false;
p = drag_polar(ac, flap, gear, tanks, hook);
p.plot_polar(h, M);
hold on;
scatter(p.get_CD0(h, M) + p.get_K(M).*ac.initial.CL_cruise.^2, ac.initial.CL_cruise, "k", "filled");

[~, a, ~, ~] = atmoscoesa(0);
M = ac.pt.seroc_to_V ./ a;

flap = "full";
gear = true;
tanks = true;
hook = false;
p = drag_polar(ac, flap, gear, tanks, hook);
p.plot_polar(0, M);

M = ac.pt.seroc_ap_V ./ a;

flap = "half";
gear = true;
tanks = true;
hook = true;
p = drag_polar(ac, flap, gear, tanks, hook);
p.plot_polar(0, M);

xlabel("$C_D$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$C_L$", "Interpreter", "latex", "FontSize", fontsize);
legend("Cruise", "", "Takeoff", "Approach", "Interpreter", "Latex", "FontSize", fontsize, "Location", "northwest");
set(gca, 'TickLabelInterpreter', 'latex');

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);
set(gcf, 'Renderer', 'painters');
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/A8_polar.pdf", "ContentType", "vector");

%%
h = ac.initial.h_cruise;
M = ac.initial.M_cruise;

% MK-83
l = 119.5 ./ 39.37;
Amax = 4.276 .* 0.092903;
Cf = turb_cf(h, l, M);
FF = ext_ff(l, Amax);
Q = 1.3;
Swet = 36.49919798 .* 0.092903;
CD0 = Cf .* FF .* Q .* Swet ./ ac.initial.Sref

% AIM-9X
l = 119 ./ 39.37;
Amax = 0.545 .* 0.092903;
Cf = turb_cf(h, l, M);
FF = ext_ff(l, Amax);
Q = 1.25;
Swet = 12.98088631 .* 0.092903;
CD0 = Cf .* FF .* Q .* Swet ./ ac.initial.Sref

% AIM-120C
l = 144 ./ 39.37;
Amax = 1.069 .* 0.092903;
Cf = turb_cf(h, l, M);
FF = ext_ff(l, Amax);
Q = 1.3;
Swet = 21.99114858 .* 0.092903;
CD0 = Cf .* FF .* Q .* Swet ./ ac.initial.Sref

% Tank
l = ac.initial.l_tanks;
Amax = ac.initial.Amax_tanks;
Cf = turb_cf(h, l, M);
FF = ext_ff(l, Amax);
Q = 1.3;
Swet = ac.initial.Swet_tanks;
CD0 = Cf .* FF .* Q .* Swet ./ ac.initial.Sref

% Tank
l = ac.initial.l_pylon;
Amax = ac.initial.Amax_pylon;
Cf = turb_cf(h, l, M);
FF = ext_ff(l, Amax);
Q = 1.5;
Swet = ac.initial.Swet_pylon;
CD0 = Cf .* FF .* Q .* Swet ./ ac.initial.Sref

%% Tank trade
flap = "no";
gear = false;
tanks = false;
hook = false;
p = drag_polar(ac, flap, gear, tanks, hook);

CD0_clean = p.get_CD0(h, M);