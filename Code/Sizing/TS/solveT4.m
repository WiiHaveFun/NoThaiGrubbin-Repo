function [T0, x] = solveT4(ac, S, Wfrac_reg, mission_fun, con_fun, Tfrac, x0)



options = optimoptions("fsolve", "Display", "final");
if isempty(x0)
    x0 = [1.0; 1.0];
end
[x, ~, flag, ~] = fsolve(@(x) residual(x, ac, S, Wfrac_reg, mission_fun, con_fun, Tfrac), x0, options);
if flag <= 0
    T0 = NaN;
    % T0 = x(1) .* ac.initial.T_max;
else
    T0 = x(1) .* ac.initial.T_max;
end
end

function R = residual(x, ac, S, Wfrac_reg, mission_fun, con_fun, Tfrac)
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
    
    R(2) = T0_residual(ac, T0, S, mission_fun, con_fun, Tfrac);
end

function R = T0_residual(ac, T0, S, mission_fun, con_fun, Tfrac)
    if isequal(mission_fun, @a2a_Ffrac)
        WS = ac.a2a.W0 ./ S;
        if isequal(con_fun, @dash)
            polar = ac.polar.a2a.clean;
            TW = dash(WS, ac.a2a.M_dash, ac.a2a.h_dash, 2.*polar.CD0, 2.*getK(ac, polar), ac.a2a.Wfracs(4), Tfrac);
        elseif isequal(con_fun, @turn_rate)
            polar = ac.polar.a2a.clean;
            TW = turn_rate(WS, ac.a2a.turn_rate, 2.*ac.a2a.h_combat, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(6), []);
        elseif isequal(con_fun, @cruise_1)
            polar = ac.polar.a2a.clean;
            TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(3), Tfrac);
        elseif isequal(con_fun, @cruise_2)
            polar = ac.polar.a2a.clean;
            TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(8), Tfrac);
        elseif isequal(con_fun, @ceiling)
            polar = ac.polar.a2a.clean;
            TW = ceiling(WS, ac.initial.M_cruise, ac.initial.h_ceiling, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(3), Tfrac);
        elseif isequal(con_fun, @seroc_to)
            polar = ac.polar.a2a.full_gear;
            TW = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, polar.CD0, getK(ac, polar), true, true, ac.initial.num_eng, true, ac.a2a.Wfracs(1), Tfrac);
        elseif isequal(con_fun, @seroc_ap)
            Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
            polar = ac.polar.a2a.full_gear;
            TW = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, polar.CD0, getK(ac, polar), true, true, ac.initial.num_eng, true, Wfrac_land_a2a, Tfrac);
        elseif isequal(con_fun, @climb_1)
            polar = ac.polar.a2a.clean;
            TW = climb_rate(WS, 2.54, ac.initial.V_climb, 0, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(2), Tfrac);
        elseif isequal(con_fun, @climb_2)
            polar = ac.polar.a2a.clean;
            TW = climb_rate(WS, 2.54, ac.initial.V_climb, ac.a2a.h_combat, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(7), Tfrac);
        elseif isequal(con_fun, @takeoff)
            polar = ac.polar.a2a.half_gear;
            TW = takeoff(WS, 1000, ac.initial.h_land, polar.CD0, polar.CLmax, 0.68, 0.025, ac.a2a.Wfracs(1), Tfrac);
        end
        R = T0 - TW .* ac.a2a.W0;
    elseif isequal(mission_fun, @strike_Ffrac)
        WS = ac.strike.W0 ./ S;
        if isequal(con_fun, @dash)
            polar = ac.polar.strike.clean;
            TW = dash(WS, ac.strike.M_dash, ac.strike.h_combat, polar.CD0, getK(ac, polar), ac.strike.Wfracs(5), Tfrac);
        elseif isequal(con_fun, @cruise_1)
            polar = ac.polar.strike.clean;
            TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, polar.CD0, getK(ac, polar), ac.strike.Wfracs(3), Tfrac);
        elseif isequal(con_fun, @cruise_2)
            polar = ac.polar.strike.clean;
            TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, polar.CD0, getK(ac, polar), ac.strike.Wfracs(8), Tfrac);
        elseif isequal(con_fun, @ceiling)
            polar = ac.polar.strike.clean;
            TW = ceiling(WS, ac.initial.M_cruise, ac.initial.h_ceiling, polar.CD0, getK(ac, polar), ac.strike.Wfracs(3), Tfrac);
        elseif isequal(con_fun, @seroc_to)
            polar = ac.polar.strike.full_gear;
            TW = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, polar.CD0, getK(ac, polar), true, true, ac.initial.num_eng, true, ac.strike.Wfracs(1), Tfrac);
        elseif isequal(con_fun, @seroc_ap)
            Wfrac_land_strike = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ ac.strike.W0;
            polar = ac.polar.strike.full_gear;
            TW = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, polar.CD0, getK(ac, polar), true, true, ac.initial.num_eng, true, Wfrac_land_strike, Tfrac);
        elseif isequal(con_fun, @climb_1)
            polar = ac.polar.strike.clean;
            TW = climb_rate(WS, 2.54, ac.initial.V_climb, 0, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.strike.Wfracs(2), Tfrac);
        elseif isequal(con_fun, @climb_2)
            polar = ac.polar.strike.clean;
            TW = climb_rate(WS, 65, ac.strike.V_dash, 0, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.strike.Wfracs(6), Tfrac);
        elseif isequal(con_fun, @climb_3)
            polar = ac.polar.strike.clean;
            TW = climb_rate(WS, 2.54, ac.initial.V_climb, 0, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.strike.Wfracs(7), Tfrac);
        elseif isequal(con_fun, @takeoff)
            polar = ac.polar.strike.half_gear;
            TW = takeoff(WS, 1000, ac.initial.h_land, polar.CD0, polar.CLmax, 0.68, 0.025, ac.strike.Wfracs(1), Tfrac);
        end
        R = T0 - TW .* ac.strike.W0;
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

        ac.a2a.We = W0 .* Wfrac;
        % Modify wing weight using areal density
        ac.a2a.We = ac.a2a.We + sigma_wing .* (S - ac.initial.Sref);
        % Modify engine weight using maximum thrust
        ac.a2a.We = ac.a2a.We + (get_Weng(T0) - get_Weng(ac.initial.T_max));

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