function [ac] = iterate_W0_TS(ac, Wfrac_reg, mission_fun, T0, S)
% ITERATE_W0  Iteratively calculates takeoff weight for a mission.
%   [ac, W0] = ITERATE_W0(ac, Wfrac_fun, mission_fun) calculates takeoff weight.

options = optimoptions("fsolve", "Display", "none");

if isequal(mission_fun, @a2a_Ffrac)
    ac.a2a.W0 = fsolve(@(W0) W0_residual(ac, Wfrac_reg, mission_fun, T0, S, W0), ac.a2a.W0, options);
    % ac.a2a.We = ac.a2a.W0 .* (Wfrac_reg.A .* ac.a2a.W0.^Wfrac_reg.C);
    [~, ac] = W0_residual(ac, Wfrac_reg, mission_fun, T0, S, ac.a2a.W0);
    [~, ac.a2a.Wfracs, ac.a2a.segments] = mission_fun(ac);
elseif isequal(mission_fun, @strike_Ffrac)
    ac.strike.W0 = fsolve(@(W0) W0_residual(ac, Wfrac_reg, mission_fun, T0, S, W0), ac.strike.W0, options);
    % ac.strike.We = ac.strike.W0 .* (Wfrac_reg.A .* ac.strike.W0.^Wfrac_reg.C);
    [~, ac] = W0_residual(ac, Wfrac_reg, mission_fun, T0, S, ac.strike.W0);
    [Ffrac, ac.strike.Wfracs, ac.strike.segments] = mission_fun(ac);
    ac.strike.Wf = ac.strike.W0 .* Ffrac;
else
    fprintf("Error. Invalid mission function.\n");
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
        ac.polar.clean = simple_polar_2("clean", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        ac.polar.half = simple_polar_2("half_flaps", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        ac.polar.full = simple_polar_2("full_flaps", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        ac.polar.half_gear = simple_polar_2("half_flaps_gear", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        ac.polar.full_gear = simple_polar_2("full_flaps_gear", ac.a2a.W0, S, ac.initial.num_drop_tanks);

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
        ac.polar.clean = simple_polar_2("clean", ac.strike.W0, S, ac.initial.num_drop_tanks);
        ac.polar.half = simple_polar_2("half_flaps", ac.strike.W0, S, ac.initial.num_drop_tanks);
        ac.polar.full = simple_polar_2("full_flaps", ac.strike.W0, S, ac.initial.num_drop_tanks);
        ac.polar.half_gear = simple_polar_2("half_flaps_gear", ac.strike.W0, S, ac.initial.num_drop_tanks);
        ac.polar.full_gear = simple_polar_2("full_flaps_gear", ac.strike.W0, S, ac.initial.num_drop_tanks);

        [Ffrac, ~, ~] = mission_fun(ac);
        R = W0 - (ac.strike.W_crew + ac.strike.W_pay) - ac.a2a.We - W0.*Ffrac;
    end
end