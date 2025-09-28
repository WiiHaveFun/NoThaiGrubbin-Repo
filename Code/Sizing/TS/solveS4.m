function S = solveS4(ac, T0, Wfrac_reg, mission_fun, con_fun, Tfrac)



options = optimoptions("fsolve", "Display", "none");
x0 = [1; 1];
[x, ~, flag, ~] = fsolve(@(x) residual(x, ac, T0, Wfrac_reg, mission_fun, con_fun, Tfrac), x0, options);
if flag <= 0
    % S = NaN;
    S = x(1) .* ac.initial.Sref;
else
    S = x(1) .* ac.initial.Sref;
end
end

function R = residual(x, ac, T0, Wfrac_reg, mission_fun, con_fun, Tfrac)
    R = zeros(2, 1);
    S = x(1) .* ac.initial.Sref;
    if isequal(mission_fun, @a2a_Ffrac)
        W0 = x(2) .* ac.a2a.W0;
        
        [R(1), ac] = W0_residual(ac, Wfrac_reg, mission_fun, T0, S, W0);
        [~, ac.a2a.Wfracs, ac.a2a.segments] = mission_fun(ac);
    elseif isequal(mission_fun, @strike_Ffrac)
        W0 = x(2) .* ac.strike.W0;
        
        [R(1), ac] = W0_residual(ac, Wfrac_reg, mission_fun, T0, S, W0);
        [~, ac.strike.Wfracs, ac.strike.segments] = mission_fun(ac);
    end
    
    R(2) = S_residual(ac, T0, S, mission_fun, con_fun, Tfrac);
end

function R = S_residual(ac, T0, S, mission_fun, con_fun, Tfrac)
    if isequal(mission_fun, @a2a_Ffrac)
        if isequal(con_fun, @max_g)
            polar = ac.polar.a2a.clean;
            WS = max_g(ac.a2a.max_g, ac.a2a.max_g_V, ac.a2a.h_combat, polar.CLmax, ac.a2a.Wfracs(6));
        elseif isequal(con_fun, @landing)
            Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
            polar = ac.polar.a2a.full_gear;
            WS = landing(2000, 0, polar.CLmax, Wfrac_land_a2a);
        elseif isequal(con_fun, @catapult2)
            TW = T0 ./ ac.a2a.W0;
            polar = ac.polar.a2a.full_gear;
            WS = catapult2(TW, ac.a2a.W0, polar.CD0, getK(ac, polar), polar.CLmax, ac.a2a.Wfracs(1), Tfrac);
        elseif isequal(con_fun, @recovery)
            Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
            polar = ac.polar.a2a.full_gear;
            WS = recovery(ac.a2a.W0, polar.CLmax, Wfrac_land_a2a);
        end
        R = S - ac.a2a.W0 ./ WS;
    elseif isequal(mission_fun, @strike_Ffrac)
        if isequal(con_fun, @max_g)
            polar = ac.polar.strike.clean;
            WS = max_g(ac.strike.max_g, ac.strike.max_g_V, ac.strike.h_combat, polar.CLmax, ac.strike.Wfracs(6));
        elseif isequal(con_fun, @landing)
            Wfrac_land_strike = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ ac.strike.W0;
            polar = ac.polar.strike.full_gear;
            WS = landing(2000, 0, polar.CLmax, Wfrac_land_strike);
        elseif isequal(con_fun, @catapult2)
            TW = T0 ./ ac.strike.W0;
            polar = ac.polar.strike.full_gear;
            WS = catapult2(TW, ac.strike.W0, polar.CD0, getK(ac, polar), polar.CLmax, ac.strike.Wfracs(1), Tfrac);
        elseif isequal(con_fun, @recovery)
            Wfrac_land_strike = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ ac.strike.W0;
            polar = ac.polar.strike.full_gear;
            WS = recovery(ac.strike.W0, polar.CLmax, Wfrac_land_strike);
        end
        R = S - ac.strike.W0 ./ WS;
    end
end

function [R, ac] = W0_residual(ac, Wfrac_reg, mission_fun, T0, S, W0)
    sigma_wing = 44.*9.81; % kg/m^2 to N/m^2
    if isequal(mission_fun, @a2a_Ffrac)
        % Modify drag polars using wing area
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

        % ac.initial.T_max = T0;
        % ac.initial.T_mil = 0.6 .* T0;
        % ac.initial.Sref = S;
        [Ffrac, ~, ~] = mission_fun(ac);
        R = W0 - (ac.strike.W_crew + ac.strike.W_pay) - ac.strike.We - W0.*Ffrac;
    end
end
