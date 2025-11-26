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

%% Run
% Takeoff weight
W = ac.a2a.W0 .* ac.a2a.Wfracs(1);

h = linspace(0, 65000, 1000) .* 0.3048;

M_stall = stall_limit(ac, W, h);
M_q = q_limit(ac, h);

[M_mil, h_mil, Ps_mil] = Ps_ceiling(ac, W, h, M_stall, M_q, false);
[M_max, h_max, Ps_max] = Ps_ceiling(ac, W, h, M_stall, M_q, true);

% Unit conversion
h = h ./ 0.3048;
h_mil = h_mil ./ 0.3048;
h_max = h_max ./ 0.3048;
Ps_mil = Ps_mil ./ 0.3048;
Ps_max = Ps_max ./ 0.3048;

%% Plot
figure(1);
clf;

p1 = plot(M_stall, h, "-k");
hold on;
p2 = plot(M_q, h, "-k");
p3 = plot(linspace(0, 2, 100), ac.initial.h_ceiling ./ 0.3048 .* ones(1, 100), "-.k");
[Mc_mil, c1] = contour(M_mil, h_mil, Ps_mil, [0, 0]);
[Mc_max, c2] = contour(M_max, h_max, Ps_max, [0, 0]);
[Mc_ser, c3] = contour(M_max, h_max, Ps_max, [300, 300]./60);
c1.Visible = "off";
c2.Visible = "off";
c3.Visible = "off";
n_c1 = Mc_mil(2, 1);
n_c2 = Mc_max(2, 1);
n_c3 = Mc_ser(2, 1);
p4 = plot(Mc_mil(1, 2:1+n_c1), Mc_mil(2, 2:1+n_c1), "--k");
p5 = plot(Mc_max(1, 2:1+n_c2), Mc_max(2, 2:1+n_c2), "--k");
p6 = plot(Mc_ser(1, 2:1+n_c3), Mc_ser(2, 2:1+n_c3), ":k");

xlabel("Mach number", "FontSize", fontsize);
ylabel("Altitude (ft)", "FontSize", fontsize);

xlim([0, 2]);

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

dn = 5;
label_line(p1, 0.4, dn, "Stall limit", "interpreter", "latex", "FontSize", fontsize);
label_line(p2, 1.6, -dn, "$q$-limit", "interpreter", "latex", "FontSize", fontsize);
label_line(p3, 0.4, dn, "Pilot ejection altitude limit", "interpreter", "latex", "FontSize", fontsize);
label_line(p4, 1.03, 2.*dn, "$P_s=0$ intermediate thrust", "interpreter", "latex", "FontSize", fontsize);
label_line(p5, 1.4, dn, "$P_s=0$ maximum thrust", "interpreter", "latex", "FontSize", fontsize);
text(1.45, 61000, "Absolute ceiling", "interpreter", "latex", "FontSize", fontsize, "HorizontalAlignment", "center");
text(1.45, 53000, "Service ceiling", "interpreter", "latex", "FontSize", fontsize, "HorizontalAlignment", "center");

%% Functions
function M = stall_limit(ac, W, h)
    [~, a, ~, rho] = atmoscoesa(h);

    CLmax = ac.polar.clean.get_CLmax();
    V = sqrt(2.*W ./ (rho .* ac.initial.Sref .* CLmax));

    M = V ./ a;
end

function M = q_limit(ac, h)
    [~, a, ~, rho] = atmoscoesa(ac.a2a.h_dash);
    maxq = 0.5 .* rho .* (2.*a).^2;

    [~, a, ~, rho] = atmoscoesa(h);
    V = sqrt(2.*maxq ./ rho);

    M = V ./ a;
end

function [M, h, Ps] = Ps_ceiling(ac, W, h_in, M_stall, M_q, is_max)
    WS = W ./ ac.initial.Sref;

    pts = 100;
    h = linspace(min(h_in), max(h_in), pts);

    M_stall = interp1(h_in, M_stall, h);
    M_q = interp1(h_in, M_q, h);

    h = h';
    [~, a, ~, rho] = atmoscoesa(h);

    M = zeros(pts, pts);
    for i = 1:pts
        M(i, :) = linspace(M_stall(i), M_q(i), pts);
    end

    CD0 = zeros(pts, pts);
    K = zeros(pts, pts);
    if is_max
        TW = ac.initial.T_max ./ W .* ones(pts, pts);
    else
        TW = ac.initial.T_mil ./ W .* ones(pts, pts);
    end
    for i = 1:pts
        for j = 1:pts
            CD0(i, j) = ac.polar.clean.get_CD0(h(i), M(i, j));
            K(i, j) = ac.polar.clean.get_K(M(i, j));
            TW(i, j) = TW(i, j) .* get_thrust_frac(M(i, j), h(i), 1.08, is_max, false);
        end
    end

    V = M .* a;
    q = 0.5 .* rho .* V.^2;
    Ps = V .* (TW - q.*CD0./WS - K./q.*WS);

    h = repmat(h, 1, pts);
end