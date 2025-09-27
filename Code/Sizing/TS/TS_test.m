ac = aircraft();
Wefrac_reg = empty_weight_frac_reg("Raymer");

[ac] = iterate_W0_TS(ac, Wefrac_reg, @a2a_Ffrac, ac.initial.T_max, ac.initial.Sref);

Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
Wfrac_land_strike = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ ac.strike.W0;

%% Polars
p_clean = ac.polar.a2a.clean;
p_half = ac.polar.a2a.half;
p_full = ac.polar.a2a.full;
p_half_gear = ac.polar.a2a.half_gear;
p_full_gear = ac.polar.a2a.full_gear;

K_clean = getK(ac, p_clean);
K_half_gear = getK(ac, p_half_gear);
K_full_gear = getK(ac, p_full_gear);

%% Test

% S = 900 .* 0.092903;

Tfrac = get_thrust_frac(ac.a2a.M_dash, ac.a2a.h_dash, 1.08, true, false);
varargin = {ac.a2a.M_dash, ac.a2a.h_dash, 2.*p_clean.CD0, 2.*K_clean};
% T0 = solveT(ac, ac.initial.Sref, Wefrac_reg, @a2a_Ffrac, @dash, 4, Tfrac, varargin{:})
T0 = solveT3(ac, ac.initial.Sref, Wefrac_reg, @a2a_Ffrac, @dash, Tfrac)

% n = 20;
% S = linspace(ac.initial.Sref.*0.7, ac.initial.Sref.*1.3, n);
% T0 = zeros(n, 1);
% for i = 1:n
%     disp(i);
%     T0(i) = solveT2(ac, S(i), Wefrac_reg, @a2a_Ffrac, @dash, 4, Tfrac, varargin{:});
% end
% figure(3);
% clf;
% plot(S, T0./4.44822);

% varargin = {ac.strike.max_g, ac.strike.max_g_V, ac.strike.h_combat, p_clean.CLmax};
% % S = solveS2(ac, ac.initial.T_max, Wefrac_reg, @a2a_Ffrac, @max_g, 6, varargin{:})
% 
% n = 20;
% T0 = linspace(ac.initial.T_max.*0.7, ac.initial.T_max.*1.3, n);
% S = zeros(n, 1);
% for i = 1:n
%     disp(i);
%     S(i) = solveS2(ac, T0(i), Wefrac_reg, @a2a_Ffrac, @max_g, 6, varargin{:});
% end
% figure(3);
% clf;
% plot(S, T0)