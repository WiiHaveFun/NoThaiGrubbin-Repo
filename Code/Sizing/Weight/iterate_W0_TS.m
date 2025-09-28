% W0_vals = logspace(2, 6, 200); % e.g. 100 to 100,000
% R_vals = arrayfun(@(W0) W0_residual(ac, Wefrac_reg, @a2a_Ffrac, 0.2.*ac.initial.T_max, 1.5.*ac.initial.Sref, W0), W0_vals);
% semilogx(W0_vals, R_vals), grid on, hold on
% xlabel('W0'), ylabel('Residual')
% yline(0);

function [ac, flag] = iterate_W0_TS(ac, Wfrac_reg, mission_fun, T0, S)
% ITERATE_W0  Iteratively calculates takeoff weight for a mission.
%   [ac, W0] = ITERATE_W0(ac, Wfrac_fun, mission_fun) calculates takeoff weight.

options = optimoptions("fsolve", "Display", "none", "Algorithm", "trust-region-dogleg");
if isequal(mission_fun, @a2a_Ffrac)
    [ac.a2a.W0, ~, flag, ~] = fsolve(@(W0) W0_residual(ac, Wfrac_reg, mission_fun, T0, S, W0), ac.a2a.W0, options);
    % [ac.a2a.W0, ~, flag, ~] = fzero(@(W0) W0_residual(ac, Wfrac_reg, mission_fun, T0, S, W0), [1e2, 1e7]);
    [~, ac] = W0_residual(ac, Wfrac_reg, mission_fun, T0, S, ac.a2a.W0);  
    [Ffrac, ac.a2a.Wfracs, ac.a2a.segments] = mission_fun(ac);
    ac.a2a.Wf = ac.a2a.W0 .* Ffrac;
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
        % Modify drag polars using wing area 
        % ac.polar.a2a.clean = simple_polar_2("clean", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        % ac.polar.a2a.half = simple_polar_2("half_flaps", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        % ac.polar.a2a.full = simple_polar_2("full_flaps", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        % ac.polar.a2a.half_gear = simple_polar_2("half_flaps_gear", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        % ac.polar.a2a.full_gear = simple_polar_2("full_flaps_gear", ac.a2a.W0, S, ac.initial.num_drop_tanks);
        ac.polar.a2a.clean = simple_polar_3("clean", ac.a2a.W0, ac.initial.Sref, S, ac.initial.num_drop_tanks);
        ac.polar.a2a.half = simple_polar_3("half_flaps", ac.a2a.W0, ac.initial.Sref, S, ac.initial.num_drop_tanks);
        ac.polar.a2a.full = simple_polar_3("full_flaps", ac.a2a.W0, ac.initial.Sref, S, ac.initial.num_drop_tanks);
        ac.polar.a2a.half_gear = simple_polar_3("half_flaps_gear", ac.a2a.W0, ac.initial.Sref, S, ac.initial.num_drop_tanks);
        ac.polar.a2a.full_gear = simple_polar_3("full_flaps_gear", ac.a2a.W0, ac.initial.Sref, S, ac.initial.num_drop_tanks);
        
        ac.a2a.W0 = W0;
        Wfrac = Wfrac_reg.A .* ac.a2a.W0.^Wfrac_reg.C;

        ac.a2a.We = ac.a2a.W0 .* Wfrac;
        % Modify wing weight using areal density
        ac.a2a.We = ac.a2a.We + sigma_wing .* (S - ac.initial.Sref);
        % Modify engine weight using maximum thrust
        ac.a2a.We = ac.a2a.We + get_Weng(T0) - get_Weng(ac.initial.T_max);

        % This makes solutions hard to converge
        % ac.initial.T_max = T0;
        % ac.initial.T_mil = 0.6 .* T0;
        % ac.initial.Sref = S;
        [Ffrac, ~, ~] = mission_fun(ac);
        R = W0 - (ac.a2a.W_crew + ac.a2a.W_pay) - ac.a2a.We - W0.*Ffrac;
    elseif isequal(mission_fun, @strike_Ffrac)
        % Modify drag polars using wing area
        ac.polar.strike.clean = simple_polar_3("clean", ac.strike.W0, ac.initial.Sref, S, ac.initial.num_drop_tanks);
        ac.polar.strike.half = simple_polar_3("half_flaps", ac.strike.W0, ac.initial.Sref, S, ac.initial.num_drop_tanks);
        ac.polar.strike.full = simple_polar_3("full_flaps", ac.strike.W0, ac.initial.Sref, S, ac.initial.num_drop_tanks);
        ac.polar.strike.half_gear = simple_polar_3("half_flaps_gear", ac.strike.W0, ac.initial.Sref, S, ac.initial.num_drop_tanks);
        ac.polar.strike.full_gear = simple_polar_3("full_flaps_gear", ac.strike.W0, ac.initial.Sref, S, ac.initial.num_drop_tanks);

        ac.strike.W0 = W0;
        Wfrac = Wfrac_reg.A .* ac.strike.W0.^Wfrac_reg.C;

        ac.strike.We = ac.strike.W0 .* Wfrac;
        % Modify wing weight using areal density
        ac.strike.We = ac.strike.We + sigma_wing .* (S - ac.initial.Sref);
        % Modify engine weight using maximum thrust
        ac.strike.We = ac.strike.We + get_Weng(T0) - get_Weng(ac.initial.T_max);
        
        [Ffrac, ~, ~] = mission_fun(ac);
        R = W0 - (ac.strike.W_crew + ac.strike.W_pay) - ac.strike.We - W0.*Ffrac;
    end
end