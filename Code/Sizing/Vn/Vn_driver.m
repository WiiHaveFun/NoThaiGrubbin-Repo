%% Plot options
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(0,'defaultTextInterpreter','latex');
fontsize = 10;
width = 6.5;
height = 4;

%% Weights and weight fractions
ac = aircraft();
ac.initial.T_max = ac.initial.T_max*0.9;
ac.initial.T_mil = ac.initial.T_mil*0.9;

[ac] = iterate_W0_TS_ref(ac, @a2a_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS_ref(ac, @strike_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);

%% Vn
Vn_max = get_Vn(ac, ac.a2a.W0);
Vn_mid = get_Vn(ac, ac.a2a.W0.*ac.a2a.Wfracs(6));
Vn_min = get_Vn(ac, ac.strike.W0.*ac.a2a.Wfracs(end));

%% Plots Max
Vn = Vn_max;
V = Vn.V ./ 0.514444;

figure(1);
clf;
% Maneuver limit load, ultimate load
plot(V, Vn.n_top_ult, ":k");
hold on;
plot(V, Vn.n_bot_ult, ":k");
plot(V, Vn.n_top, "--k");
plot(V, Vn.n_bot, "--k");
% Gust
p1 = plot(V, 1 + Vn.dn_rough, "-.r");
plot(V, 1 - Vn.dn_rough, "-.r");
p2 = plot(V, 1 + Vn.dn_dash, "-.b");
plot(V, 1 - Vn.dn_dash, "-.b");
p3 = plot(V, 1 + Vn.dn_dive, "-.k");
plot(V, 1 - Vn.dn_dive, "-.k");
% Combined
plot(V, Vn.n_com_top, "-k", "LineWidth", 1);
plot(V, Vn.n_com_bot, "-k", "LineWidth", 1);
% End
plot([V(end), V(end)], [-1.5, ac.initial.max_g*1.5], ":k");
plot([V(end), V(end)], [Vn.n_com_bot(end), Vn.n_com_top(end)], "-k", "LineWidth", 1);
% Stall
plot([Vn.Vstall Vn.Vstall] ./ 0.514444, [-1, 1], "-k");
% Corner
scatter(Vn.Vcorner ./ 0.514444, ac.initial.max_g, 30, "k", "filled");
% Rough air speed
scatter(Vn.Vb ./ 0.514444, Vn.n_rough, 30, "k", "filled");
% Dash
scatter(Vn.Vdash ./ 0.514444, ac.initial.max_g, 30, "k", "filled");
% Dive
scatter(Vn.Vdive ./ 0.514444, ac.initial.max_g, 30, "k", "filled");

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

% Labels
dn = 0.2;
text(Vn.Vcorner ./ 0.514444, ac.initial.max_g+dn, "$V_A$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");
text(Vn.Vb ./ 0.514444, Vn.n_rough+dn, "$V_B$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");
text(Vn.Vdash ./ 0.514444, ac.initial.max_g+dn, "$V_C$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");
text(Vn.Vdive ./ 0.514444, ac.initial.max_g+dn, "$V_D$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");

dn = 7;
label_line(p1, 525, dn, "$V_B$ gust", "FontSize", fontsize);
label_line(p2, 650, dn, "$V_C$ gust", "FontSize", fontsize);
label_line(p3, 525, -dn, "$V_D$ gust", "FontSize", fontsize);

yline(0);
xlabel("$V_\mathrm{EAS}$ (kts)", "FontSize", fontsize);
ylabel("$n$", "FontSize", fontsize);

set(gcf, 'Renderer', 'painters');
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/Vn_max.pdf", "ContentType", "vector");
saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/Vn_max.svg");

%% Mid
Vn = Vn_mid;
V = Vn.V ./ 0.514444;

figure(2);
clf;
% Maneuver limit load, ultimate load
plot(V, Vn.n_top_ult, ":k");
hold on;
plot(V, Vn.n_bot_ult, ":k");
plot(V, Vn.n_top, "--k");
plot(V, Vn.n_bot, "--k");
% Gust
p1 = plot(V, 1 + Vn.dn_rough, "-.r");
plot(V, 1 - Vn.dn_rough, "-.r");
p2 = plot(V, 1 + Vn.dn_dash, "-.b");
plot(V, 1 - Vn.dn_dash, "-.b");
p3 = plot(V, 1 + Vn.dn_dive, "-.k");
plot(V, 1 - Vn.dn_dive, "-.k");
% Combined
plot(V, Vn.n_com_top, "-k", "LineWidth", 1);
plot(V, Vn.n_com_bot, "-k", "LineWidth", 1);
% End
plot([V(end), V(end)], [-1.5, ac.initial.max_g*1.5], ":k");
plot([V(end), V(end)], [Vn.n_com_bot(end), Vn.n_com_top(end)], "-k", "LineWidth", 1);
% Stall
plot([Vn.Vstall Vn.Vstall] ./ 0.514444, [-1, 1], "-k");
% Corner
scatter(Vn.Vcorner ./ 0.514444, ac.initial.max_g, 30, "k", "filled");
% Rough air speed
scatter(Vn.Vb ./ 0.514444, Vn.n_rough, 30, "k", "filled");
% Dash
scatter(Vn.Vdash ./ 0.514444, ac.initial.max_g, 30, "k", "filled");
% Dive
scatter(Vn.Vdive ./ 0.514444, ac.initial.max_g, 30, "k", "filled");

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

% Labels
dn = 0.2;
text(Vn.Vcorner ./ 0.514444, ac.initial.max_g+dn, "$V_A$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");
text(Vn.Vb ./ 0.514444, Vn.n_rough+dn, "$V_B$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");
text(Vn.Vdash ./ 0.514444, ac.initial.max_g+dn, "$V_C$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");
text(Vn.Vdive ./ 0.514444, ac.initial.max_g+dn, "$V_D$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");

dn = 7;
label_line(p1, 525, dn, "$V_B$ gust", "FontSize", fontsize);
label_line(p2, 650, dn, "$V_C$ gust", "FontSize", fontsize);
label_line(p3, 525, -dn, "$V_D$ gust", "FontSize", fontsize);

yline(0);
xlabel("$V_\mathrm{EAS}$ (kts)", "FontSize", fontsize);
ylabel("$n$", "FontSize", fontsize);

set(gcf, 'Renderer', 'painters');
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/Vn_mid.pdf", "ContentType", "vector");
saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/Vn_mid.svg");

%% Min
Vn = Vn_min;
V = Vn.V ./ 0.514444;

figure(3);
clf;
% Maneuver limit load, ultimate load
plot(V, Vn.n_top_ult, ":k");
hold on;
plot(V, Vn.n_bot_ult, ":k");
plot(V, Vn.n_top, "--k");
plot(V, Vn.n_bot, "--k");
% Gust
p1 = plot(V, 1 + Vn.dn_rough, "-.r");
plot(V, 1 - Vn.dn_rough, "-.r");
p2 = plot(V, 1 + Vn.dn_dash, "-.b");
plot(V, 1 - Vn.dn_dash, "-.b");
p3 = plot(V, 1 + Vn.dn_dive, "-.k");
plot(V, 1 - Vn.dn_dive, "-.k");
% Combined
plot(V, Vn.n_com_top, "-k", "LineWidth", 1);
plot(V, Vn.n_com_bot, "-k", "LineWidth", 1);
% End
plot([V(end), V(end)], [-1.5, ac.initial.max_g*1.5], ":k");
plot([V(end), V(end)], [Vn.n_com_bot(end), Vn.n_com_top(end)], "-k", "LineWidth", 1);
% Stall
plot([Vn.Vstall Vn.Vstall] ./ 0.514444, [-1, 1], "-k");
% Corner
scatter(Vn.Vcorner ./ 0.514444, ac.initial.max_g, 30, "k", "filled");
% Rough air speed
scatter(Vn.Vb ./ 0.514444, Vn.n_rough, 30, "k", "filled");
% Dash
scatter(Vn.Vdash ./ 0.514444, ac.initial.max_g, 30, "k", "filled");
% Dive
scatter(Vn.Vdive ./ 0.514444, ac.initial.max_g, 30, "k", "filled");

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

% Labels
dn = 0.2;
text(Vn.Vcorner ./ 0.514444, ac.initial.max_g+dn, "$V_A$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");
text(Vn.Vb ./ 0.514444, Vn.n_rough+dn, "$V_B$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");
text(Vn.Vdash ./ 0.514444, ac.initial.max_g+dn, "$V_C$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");
text(Vn.Vdive ./ 0.514444, ac.initial.max_g+dn, "$V_D$", "FontSize", fontsize, "HorizontalAlignment", "right",  "VerticalAlignment", "bottom");

dn = 7;
label_line(p1, 525, dn, "$V_B$ gust", "FontSize", fontsize);
label_line(p2, 650, dn, "$V_C$ gust", "FontSize", fontsize);
label_line(p3, 525, -dn, "$V_D$ gust", "FontSize", fontsize);

yline(0);
xlabel("$V_\mathrm{EAS}$ (kts)", "FontSize", fontsize);
ylabel("$n$", "FontSize", fontsize);

set(gcf, 'Renderer', 'painters');
% exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/Vn_min.pdf", "ContentType", "vector");
saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/Vn_min.svg");
