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

%% Plot
W = ac.a2a.W0 .* ac.a2a.Wfracs(6);

[M_limit, turn_rate_limit] = lift_limit(ac, W);
[M_struct, turn_rate_struct] = struct_limit(ac, W);
M_limit = [M_limit, M_struct(2:end)];
turn_rate_limit = [turn_rate_limit, turn_rate_struct(2:end)];

[M_Ps, turn_rate_Ps, Ps] = Ps_contour(ac, W, M_limit, turn_rate_limit);

n = [1.1, 1.5, 2:ac.initial.max_g+1];
R = [1000, 2000, 3000, 5000, 10000, 15000];
[M_n, turn_rate_n] = n_contour(ac, n, R(1));
[M_R, turn_rate_R] = R_contour(ac, R);

% Unit conversion
turn_rate_limit = rad2deg(turn_rate_limit);
turn_rate_Ps = rad2deg(turn_rate_Ps);
turn_rate_n = rad2deg(turn_rate_n);
turn_rate_R = rad2deg(turn_rate_R);
Ps = Ps ./ 0.3048;

figure(1);
clf;

p1 = plot(M_n, turn_rate_n, "--k");
hold on;
p2 = plot(M_R, turn_rate_R, "--k");
plot([M_limit, M_limit(end)], [turn_rate_limit, 0], "-b");
[C, h] = contour(M_Ps, turn_rate_Ps, Ps, [-400, 0, 400:200:1200], "-b", "LabelFormat", "%d ft/s", "ShowText", "on");
clabel(C, h, "FontSize", fontsize, "Interpreter", "latex", "labelspacing", 1000);

xlabel("Mach number", "FontSize", fontsize);
ylabel("Turn rate (deg/s)", "FontSize", fontsize)f

xlim([0.05, 1.4]);
ylim([0, 20]);

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

dn = 5;
for i = 1:length(n)
    label_line(p1(i), M_n(2, i), 0, sprintf("%.1f~~~~~~~", n(i)), "interpreter", "latex", "FontSize", fontsize);
end
for i = 1:length(R)
    label_line(p2(i), M_R(2, i), -dn, sprintf("%d ft~~~~~~~~~~~~~", R(i)), "interpreter", "latex", "FontSize", fontsize);
end

text(0.1, 17, {'10,000 ft', 'Maximum thrust', 'Combat weight'}, 'Interpreter', 'latex', 'FontSize', fontsize);

%% Functions
function [M, turn_rate] = lift_limit(ac, W)
    [~, a, ~, rho] = atmoscoesa(ac.a2a.h_combat);

    g = 9.81;
    CLmax = ac.polar.clean.get_CLmax();
    WS = W ./ ac.initial.Sref;

    n = linspace(1, ac.initial.max_g, 1000);

    V = sqrt(2.*WS.*n ./ (rho.*CLmax));
    
    turn_rate = g.*sqrt(n.^2 - 1) ./ V;
    M = V ./ a;
end

function [M, turn_rate] = struct_limit(ac, W)
    [~, a, ~, rho] = atmoscoesa(ac.a2a.h_dash);
    maxq = 0.5 .* rho .* (2.*a).^2;

    [~, a, ~, rho] = atmoscoesa(ac.a2a.h_combat);

    n = ac.initial.max_g;
    g = 9.81;
    CLmax = ac.polar.clean.get_CLmax();
    WS = W ./ ac.initial.Sref;
    Vcorner = sqrt(2.*WS.*n ./ (rho.*CLmax));
    Vmax = sqrt(2.*maxq ./ rho);

    V = linspace(Vcorner, Vmax, 1000);

    turn_rate = g.*sqrt(n.^2 - 1) ./ V;
    M = V ./ a;

    % turn_rate = [turn_rate, 0];
    % M = [M, M(end)];
end

function [M, turn_rate, Ps] = Ps_contour(ac, W, M_limit, turn_rate_limit)
    pts = 1000;
    h = ac.a2a.h_combat;
    [~, a, ~, rho] = atmoscoesa(h);

    M = linspace(min(M_limit)+1e-3, max(M_limit), pts);
    turn_rate = zeros(pts, pts);
    for i = 1:length(M)
        turn_rate(:, i) = linspace(0, interp1(M_limit, turn_rate_limit, M(i)), pts);
    end

    CD0 = zeros(size(M));
    K = zeros(size(M));
    TW = ac.initial.T_max ./ W .* ones(size(M));
    for i = 1:pts
        CD0(i) = ac.polar.clean.get_CD0(h, M(i));
        K(i) = ac.polar.clean.get_K(M(i));
        TW(i) = TW(i) .* get_thrust_frac(M(i), h, 1.08, true, false);
    end
    
    g = 9.81;
    WS = W ./ ac.initial.Sref;
    V = M .* a;
    n = sqrt((turn_rate.*V./g).^2 + 1);
    q = 0.5 .* rho .* V.^2;
    Ps = V .* (TW - q.*CD0./WS - n.^2.*K./q.*WS);

    M = repmat(M, pts, 1);  
end

function [M, turn_rate] = n_contour(ac, n, R1)
    [~, a, ~, ~] = atmoscoesa(ac.a2a.h_combat);
    g = 9.81;
    V1 = sqrt(R1.*g.*sqrt(n.^2 - 1));
    V = zeros(1000, length(n));
    for i = 1:length(n)
        V(:, i) = linspace(V1(i), 600, 1000);
    end    

    turn_rate = g.*sqrt(n.^2 - 1) ./ V;
    M = V ./ a;
end

function [M, turn_rate] = R_contour(ac, R)
    [~, a, ~, ~] = atmoscoesa(ac.a2a.h_combat);
    
    n = linspace(1.1, ac.initial.max_g+1, 1000)';
    g = 9.81;

    V = sqrt(R.*g.*sqrt(n.^2 - 1));
    M = V ./ a;

    turn_rate = g.*sqrt(n.^2 - 1) ./ V;
end