%% Takeoff
V = 156 * 0.514444;

[~, a, P, ~] = atmoscoesa(0);
R = 287;
T = 305.2611; % Tropical day (89.8 F)
rho = P ./ (R .* T);

TW = ac.initial.T_max / ac.a2a.W0;
TW = TW / 2; % OEI
TW = TW * 0.94; % Max continous thrust
TW = TW * 0.8;
TW = TW * get_thrust_frac(V/a, 0, 1.08, true, true);

WS = ac.a2a.W0 / ac.initial.Sref;

CD0 = ac.polar.catapult.get_CD0(0, V/a);
K = ac.polar.catapult.get_K(V/a);

Vg = V*TW - rho*V^3*CD0 / (2*WS) - 2*K / (rho*V) * WS;
fprintf("Takeoff SEROC: %.4f\n", Vg / 0.00508);

%% Approach
V = 127 * 0.514444;

[~, a, P, ~] = atmoscoesa(0);
R = 287;
T = 305.2611; % Tropical day (89.8 F)
rho = P ./ (R .* T);

Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
W = ac.a2a.W0 * Wfrac_land_a2a;

TW = ac.initial.T_max / W;
TW = TW / 2; % OEI
TW = TW * 0.94; % Max continous thrust
TW = TW * 0.8;
TW = TW * get_thrust_frac(V/a, 0, 1.08, true, true);

WS = W / ac.initial.Sref;

CD0 = ac.polar.approach.get_CD0(0, V/a);
K = ac.polar.approach.get_K(V/a);

Vg = V*TW - rho*V^3*CD0 / (2*WS) - 2*K / (rho*V) * WS;
fprintf("Approach SEROC: %.4f\n", Vg / 0.00508);
