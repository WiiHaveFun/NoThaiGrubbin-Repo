function Vn = get_Vn(ac, W)

% All velocities are EAS
[~, ~, ~, rho_sl] = atmoscoesa(0);

CLmax = ac.polar.clean.get_CLmax();
S = ac.initial.Sref;
Vstall = sqrt(2*W / (rho_sl * S * CLmax));

[~, ~, ~, rho] = atmoscoesa(ac.initial.h_cruise);
Vcruise = sqrt(rho/rho_sl) * ac.initial.V_cruise;

[~, a, ~, rho] = atmoscoesa(ac.a2a.h_dash);
Vdash = sqrt(rho/rho_sl) * (ac.a2a.M_dash * a);

% Vdive = Vdash * 1.25;
[~, a, ~, rho] = atmoscoesa(ac.a2a.h_dash);
Vdive = sqrt(rho/rho_sl) * (2.0 * a);

Vcorner = sqrt(2*W*ac.initial.max_g / (rho_sl * S * CLmax));
Vcornern = sqrt(-2*W*ac.initial.max_ng / (rho_sl * S * CLmax));

n = 1000;
V = linspace(0, Vdive, n);

n_top(V < Vcorner) = 0.5 .* rho_sl .* V(V < Vcorner).^2 .* S .* CLmax ./ W;
n_top(V >= Vcorner) = ac.initial.max_g;

n_bot(V < Vcornern) = -0.5 .* rho_sl .* V(V < Vcornern).^2 .* S .* CLmax ./ W;
n_bot(V >= Vcornern & V < Vdash) = ac.initial.max_ng;
n_bot(V >= Vdash) = interp1([Vdash, Vdive], [ac.initial.max_ng, -1], V(V >= Vdash));

Vcorner_ult = sqrt(2*W*ac.initial.max_g*1.5 / (rho_sl * S * CLmax));
Vcornern_ult = sqrt(-2*W*ac.initial.max_ng*1.5 / (rho_sl * S * CLmax));

n_top_ult(V < Vcorner_ult) = 0.5 .* rho_sl .* V(V < Vcorner_ult).^2 .* S .* CLmax ./ W;
n_top_ult(V >= Vcorner_ult) = ac.initial.max_g * 1.5;

n_bot_ult(V < Vcornern_ult) = -0.5 .* rho_sl .* V(V < Vcornern_ult).^2 .* S .* CLmax ./ W;
n_bot_ult(V >= Vcornern_ult & V < Vdash) = ac.initial.max_ng * 1.5;
n_bot_ult(V >= Vdash) = interp1([Vdash, Vdive], [ac.initial.max_ng * 1.5, -1.5], V(V >= Vdash));

Vn.Vstall = Vstall;
Vn.Vdash = Vdash;
Vn.Vdive = Vdive;
Vn.Vcorner = Vcorner;
Vn.Vcornern = Vcornern;
Vn.Vcorner_ult = Vcorner_ult;
Vn.Vcornern_ult = Vcornern_ult;
Vn.n_top = n_top;
Vn.n_bot = n_bot;
Vn.n_top_ult = n_top_ult;
Vn.n_bot_ult = n_bot_ult;

% Gusts
Ude_rough = 66 .* 0.3048; % ft/s to m/s
Ude_dash = 50 .* 0.3048;
Ude_dive = 25 .* 0.3048;

gust_fun = @(Vb) 1 + gust(ac, W, Vb, Ude_rough, false) - 0.5 .* rho_sl .* Vb.^2 .* S .* CLmax ./ W;
options = optimoptions("fsolve", "Display", "none");
Vb = fsolve(@(Vb) gust_fun(Vb), 100, options);
Vn.Vb = Vb;

Vn.n_rough = 1 + gust(ac, W, Vb, Ude_rough, false);

Vn.dn_rough(V < Vb) = gust(ac, W, V(V < Vb), Ude_rough, false);
Vn.dn_rough(V >= Vb & V < Vdash) = interp1([Vb, Vdash], [Vn.dn_rough(end), gust(ac, W, Vdash, Ude_dash, true)], V(V >= Vb & V < Vdash));
Vn.dn_rough(V >= Vdash) = nan;
Vn.dn_dash(V < Vdash) = gust(ac, W, V(V < Vdash), Ude_dash, true);
Vn.dn_dash(V > Vdash) = interp1([Vdash, Vdive], [Vn.dn_dash(end), gust(ac, W, Vdive, Ude_dive, true)], V(V > Vdash));
Vn.dn_dive = gust(ac, W, V, Ude_dive, true);

Vn.dn_gust = max(max(Vn.dn_rough, Vn.dn_dash, "omitnan"), Vn.dn_dive, "omitnan");

Vn.n_com_top = [Vn.n_top(V < Vb), max(Vn.n_top(V > Vb), 1 + Vn.dn_gust(V > Vb))];
Vn.n_com_bot = [Vn.n_bot(V < Vb), min(Vn.n_bot(V > Vb), 1 - Vn.dn_gust(V > Vb))];

Vn.V = V;



end

function [dn_gust] = gust(ac, W, V, Ude, is_sup)
    [~, ~, ~, rho_sl] = atmoscoesa(0);
    [~, ~, ~, rho] = atmoscoesa(20000 .* 0.3048);
    g = 9.81;
    Cla = ac.polar.CLa;
    S = ac.initial.Sref;
    V = sqrt(rho_sl/rho) * V;

    mu = 2 .* W./S ./ (rho .* 9.81 .* ac.initial.MAC .* Cla);
    
    if is_sup
        K = mu^1.03 / (6.95 + mu^1.03);
    else
        K = 0.88*mu / (5.3 + mu);
    end

    dn_gust = rho.*K.*Ude.*V.*Cla / (2.*(W./S));
end