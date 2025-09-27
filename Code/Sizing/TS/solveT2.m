function T0 = solveT2(ac, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, Tfrac, varargin)



options = optimoptions("fsolve", "Display", "final");
x0 = [1; 1];
[x, ~, flag, ~] = fsolve(@(x) residual(x, ac, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, Tfrac, varargin{:}), x0);
if flag <= 0
    T0 = NaN;
else
    T0 = x(1) .* ac.initial.T_max;
end

figure(1);
clf;
W0 = linspace(30000.*4.44822, 90000.*4.44822, 50);
T = linspace(40000.*4.44822, 80000.*4.44822, 50);

out = zeros([50, 50, 2])
for i = 1:50
    for j = 1:50
        x = [T(i); W0(j)];
        out1(i, j, :) = residual(x, ac, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, Tfrac, varargin{:});
    end
end
[T, W0] = meshgrid(T, W0);
surf(T, W0, out1(:, :, 1))
hold on;
surf(T, W0, out1(:, :, 2))
end

function R = residual(x, ac, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, Tfrac, varargin)
    R = zeros(2, 1);
    T0 = x(1) .* ac.initial.T_max;
    if isequal(mission_fun, @a2a_Ffrac)
        W0 = x(2) .* ac.a2a.W0;
        
        [R(1), ac] = W0_residual(ac, Wfrac_reg, mission_fun, T0, S, W0);
        [~, ac.a2a.Wfracs, ac.a2a.segments] = mission_fun(ac);
    elseif isequal(mission_fun, @strike_Ffrac)
        W0 = x(2) .* ac.strike.W0;
        
        [R(1), ac] = W0_residual(ac, Wfrac_reg, mission_fun, T0, S, W0);
        [~, ac.strike.Wfracs, ac.strike.segments] = mission_fun(ac);
    end
    
    R(2) = T0_residual(ac, T0, S, mission_fun, con_fun, Wfrac_idx, Tfrac, varargin{:});
end

function R = T0_residual(ac, T0, S, mission_fun, con_fun, Wfrac_idx, Tfrac, varargin)
    if isequal(mission_fun, @a2a_Ffrac)
        WS = ac.a2a.W0 ./ S;
        if isequal(con_fun, @dash)
            polar = ac.polar.a2a.clean;
            TW = con_fun(WS, ac.a2a.M_dash, ac.a2a.h_dash, 2.*polar.CD0, 2.*getK(ac, polar), ac.a2a.Wfracs(4), Tfrac);
        end
        
        R = T0 - TW .* ac.a2a.W0;
    elseif isequal(mission_fun, @strike_Ffrac)
        WS = ac.strike.W0 ./ S;
        TW = con_fun(WS, varargin{:}, ac.strike.Wfracs(Wfrac_idx), Tfrac);
        R = T0 - TW .* ac.strike.W0;
    end
end

function [R, ac] = W0_residual(ac, Wfrac_reg, mission_fun, T0, S, W0)
    sigma_wing = 44.*9.81; % kg/m^2 to N/m^2
    if isequal(mission_fun, @a2a_Ffrac)
        ac.a2a.W0 = W0;
        Wfrac = Wfrac_reg.A .* ac.a2a.W0.^Wfrac_reg.C;

        ac.a2a.We = ac.a2a.W0 .* Wfrac;
        % Modify wing weight using areal density
        ac.a2a.We = ac.a2a.We + sigma_wing .* (S - ac.initial.Sref);
        % Modify engine weight using maximum thrust
        ac.a2a.We = ac.a2a.We + get_Weng(T0) - get_Weng(ac.initial.T_max);
        % Modify drag polars using wing area
        ac.polar.a2a.clean = simple_polar_2("clean", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        ac.polar.a2a.half = simple_polar_2("half_flaps", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        ac.polar.a2a.full = simple_polar_2("full_flaps", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        ac.polar.a2a.half_gear = simple_polar_2("half_flaps_gear", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        ac.polar.a2a.full_gear = simple_polar_2("full_flaps_gear", ac.a2a.W0, S, ac.initial.num_drop_tanks);

        ac.initial.T_max = T0;
        ac.initial.T_mil = 0.6 .* T0;
        ac.initial.Sref = S;
        [Ffrac, ~, ~] = mission_fun(ac);
        R = W0 - (ac.a2a.W_crew + ac.a2a.W_pay) - ac.a2a.We - W0.*Ffrac;
    elseif isequal(mission_fun, @strike_Ffrac)
        ac.strike.W0 = W0;
        Wfrac = Wfrac_reg.A .* ac.strike.W0.^Wfrac_reg.C;

        ac.strike.We = ac.strike.W0 .* Wfrac;
        % Modify wing weight using areal density
        ac.strike.We = ac.strike.We + sigma_wing .* (S - ac.initial.Sref);
        % Modify engine weight using maximum thrust
        ac.strike.We = ac.strike.We + get_Weng(T0) - get_Weng(ac.initial.T_max);
        % Modify drag polars using wing area
        ac.polar.strike.clean = simple_polar_2("clean", ac.strike.W0, S, ac.initial.num_drop_tanks);
        ac.polar.strike.half = simple_polar_2("half_flaps", ac.strike.W0, S, ac.initial.num_drop_tanks);
        ac.polar.strike.full = simple_polar_2("full_flaps", ac.strike.W0, S, ac.initial.num_drop_tanks);
        ac.polar.strike.half_gear = simple_polar_2("half_flaps_gear", ac.strike.W0, S, ac.initial.num_drop_tanks);
        ac.polar.strike.full_gear = simple_polar_2("full_flaps_gear", ac.strike.W0, S, ac.initial.num_drop_tanks);

        ac.initial.T_max = T0;
        ac.initial.T_mil = 0.6 .* T0;
        ac.initial.Sref = S;
        [Ffrac, ~, ~] = mission_fun(ac);
        R = W0 - (ac.strike.W_crew + ac.strike.W_pay) - ac.strike.We - W0.*Ffrac;
    end
end