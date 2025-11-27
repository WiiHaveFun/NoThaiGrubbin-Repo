function [T0, x] = solveT5(ac, S, mission_fun, con_fun, Tfrac, x0)

% New wing area
ac.initial.Sref = S;
ac.initial.AR = ac.initial.b.^2 / ac.initial.Sref;
% Refined polars (re-initialization)
ac.polar.clean = drag_polar(ac, ...                                 % Fuel tanks only if present for all polars
                            "no", false, true, false);  
ac.polar.catapult = drag_polar(ac, ...                              % Full flaps, gear deployed
                            "full", true, true, false);  
ac.polar.approach = drag_polar(ac, ...                              % Half flaps, gear deployed, hook deployed
                            "half", true, true, true);  
ac.polar.approach_nogear = drag_polar(ac, ...                       % Half flaps, gear deployed, hook deployed
                            "half", false, true, true);  
ac.polar.takeoff = drag_polar(ac, ...                               % Half flaps, gear deployed
                            "half", true, true, false);  
ac.polar.takeoff_nogear = drag_polar(ac, ...                        % Half flaps, gear deployed
                            "half", false, true, false);  
ac.polar.landing = drag_polar(ac, ...                               % Full flaps, gear deployed
                            "full", true, true, false);   
% Cruise spline
ac.polar.cruise_pp = generate_cruise_spline(ac, ac.polar.clean);

options = optimoptions("fsolve", "Display", "final");
if isempty(x0)
    x0 = [1.0; 1.0];
end
[x, ~, flag, ~] = fsolve(@(x) residual(x, ac, S, mission_fun, con_fun, Tfrac), x0, options);
if flag <= 0
    T0 = NaN;
    % T0 = x(1) .* ac.initial.T_max;
else
    T0 = x(1) .* ac.initial.T_max;
end
end

function R = residual(x, ac, S, mission_fun, con_fun, Tfrac)
    R = zeros(2, 1);
    T0 = x(1) .* ac.initial.T_max;
    if isequal(mission_fun, @a2a_ref_Ffrac)
        W0 = x(2) .* ac.a2a.W0;
        [R(1), ac] = W0_residual(ac, mission_fun, T0, S, W0);
        [~, ac.a2a.Wfracs, ac.a2a.segments] = mission_fun(ac);
    elseif isequal(mission_fun, @strike_ref_Ffrac)
        W0 = x(2) .* ac.strike.W0;
        [R(1), ac] = W0_residual(ac, mission_fun, T0, S, W0);
        [~, ac.strike.Wfracs, ac.strike.segments] = mission_fun(ac);
    end
    
    R(2) = T0_residual(ac, T0, S, mission_fun, con_fun, Tfrac);
end

function R = T0_residual(ac, T0, S, mission_fun, con_fun, Tfrac)
    if isequal(mission_fun, @a2a_ref_Ffrac)
        WS = ac.a2a.W0 ./ S;
        if isequal(con_fun, @dash)
            polar = ac.polar.clean;
            Tfrac = get_thrust_frac(ac.a2a.M_dash, ac.a2a.h_dash, 1.08, true, false);
            CD0 = polar.get_CD0(ac.a2a.h_dash, ac.a2a.M_dash);
            K = polar.get_K(ac.a2a.M_dash);
            TW = dash(WS, ac.a2a.M_dash, ac.a2a.h_dash, CD0, K, ac.a2a.Wfracs(4), Tfrac);
            % polar = ac.polar.a2a.clean;
            % TW = dash(WS, ac.a2a.M_dash, ac.a2a.h_dash, 2.*polar.CD0, 2.*getK(ac, polar), ac.a2a.Wfracs(4), Tfrac);
        elseif isequal(con_fun, @turn_rate_ref)
            polar = ac.polar.clean;
            TW = turn_rate_ref(WS, ac.a2a.turn_rate, 2.*ac.a2a.h_combat, polar, ac.a2a.Wfracs(6), []);
            % TW = turn_rate(WS, ac.a2a.turn_rate, 2.*ac.a2a.h_combat, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(6), []);
        elseif isequal(con_fun, @cruise_1)
            polar = ac.polar.clean;
            CD0 = polar.get_CD0(ac.initial.h_cruise, ac.initial.M_cruise);
            K = polar.get_K(ac.initial.M_cruise);
            Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
            TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, CD0, K, ac.a2a.Wfracs(3), Tfrac);
            % polar = ac.polar.a2a.clean;
            % TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(3), Tfrac);
        elseif isequal(con_fun, @cruise_2)
            polar = ac.polar.clean;
            CD0 = polar.get_CD0(ac.initial.h_cruise, ac.initial.M_cruise);
            K = polar.get_K(ac.initial.M_cruise);
            Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
            TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, CD0, K, ac.a2a.Wfracs(8), Tfrac);
            % polar = ac.polar.a2a.clean;
            % TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(8), Tfrac);
        elseif isequal(con_fun, @ceiling)
            polar = ac.polar.clean;
            CD0 = polar.get_CD0(ac.initial.h_ceiling, ac.initial.M_cruise);
            K = polar.get_K(ac.initial.M_cruise);
            Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
            TW = ceiling(WS, ac.initial.M_cruise, ac.initial.h_ceiling, CD0, K, ac.a2a.Wfracs(3), Tfrac);
            % polar = ac.polar.a2a.clean;
            % TW = ceiling(WS, ac.initial.M_cruise, ac.initial.h_ceiling, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(3), Tfrac);
        elseif isequal(con_fun, @seroc_to)
            polar = ac.polar.catapult;
            [~, a, ~, ~] = atmoscoesa(0);
            CD0 = polar.get_CD0(0, ac.pt.seroc_to_V./a);
            K = polar.get_K(ac.pt.seroc_to_V./a);
            Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
            TW = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, CD0, K, true, true, ac.initial.num_eng, true, ac.a2a.Wfracs(1), Tfrac);
            % polar = ac.polar.a2a.full_gear;
            % TW = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, polar.CD0, getK(ac, polar), true, true, ac.initial.num_eng, true, ac.a2a.Wfracs(1), Tfrac);
        elseif isequal(con_fun, @seroc_ap)
            Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
            [~, a, ~, ~] = atmoscoesa(0);
            polar = ac.polar.approach;
            CD0 = polar.get_CD0(0, ac.pt.seroc_ap_V./a);
            K = polar.get_K(ac.pt.seroc_to_V./a);
            Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
            TW = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, CD0, K, true, true, ac.initial.num_eng, true, Wfrac_land_a2a, Tfrac);
            % polar = ac.polar.a2a.full_gear;
            % TW = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, polar.CD0, getK(ac, polar), true, true, ac.initial.num_eng, true, Wfrac_land_a2a, Tfrac);
        elseif isequal(con_fun, @climb_1)
            polar = ac.polar.clean;
            [V, ~] = get_best_climb_V(ac, ac.a2a.Wfracs(2), ac.a2a.W0, 0, polar, false);
            [~, a, ~, ~] = atmoscoesa(0);
            CD0 = polar.get_CD0(0, V./a);
            K = polar.get_K(V./a);
            Tfrac = get_thrust_frac(V./a, 0, 1.08, false, false);
            TW = climb_rate(WS, ac.a2a.climb_rate, V, 0, CD0, K, false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(2), Tfrac);
            % polar = ac.polar.a2a.clean;
            % TW = climb_rate(WS, 2.54, ac.initial.V_climb, 0, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(2), Tfrac);
        elseif isequal(con_fun, @climb_2)
            polar = ac.polar.clean;
            [~, a, ~, ~] = atmoscoesa(ac.a2a.h_combat);
            [V, ~] = get_best_climb_V(ac, ac.a2a.Wfracs(7), ac.a2a.W0, ac.a2a.h_combat, polar, false);
            CD0 = polar.get_CD0(ac.a2a.h_combat, V./a);
            K = polar.get_K(V./a);
            Tfrac = get_thrust_frac(V./a, ac.a2a.h_combat, 1.08, false, false);
            TW = climb_rate(WS, ac.a2a.climb_rate, V, ac.a2a.h_combat, CD0, K, false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(7), Tfrac);
            % polar = ac.polar.a2a.clean;
            % TW = climb_rate(WS, 2.54, ac.initial.V_climb, ac.a2a.h_combat, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(7), Tfrac);
        elseif isequal(con_fun, @takeoff)
            polar = ac.polar.takeoff;
            [~, a, ~, ~] = atmoscoesa(ac.initial.h_land);
            CD0 = polar.get_CD0(ac.initial.h_land, ac.pt.seroc_to_V./a);
            K = polar.get_K(ac.pt.seroc_to_V./a);
            Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
            TW = takeoff(WS, ac.initial.d_land, ac.initial.h_land, CD0, polar.get_CLmax(), 0.68, 0.025, ac.a2a.Wfracs(1), Tfrac);
            % polar = ac.polar.a2a.half_gear;
            % TW = takeoff(WS, 1000, ac.initial.h_land, polar.CD0, polar.CLmax, 0.68, 0.025, ac.a2a.Wfracs(1), Tfrac);
        end
        R = T0 - TW .* ac.a2a.W0;
    elseif isequal(mission_fun, @strike_ref_Ffrac)
        WS = ac.strike.W0 ./ S;
        if isequal(con_fun, @dash)
            polar = ac.polar.clean;
            CD0 = polar.get_CD0(ac.strike.h_combat, ac.strike.M_dash);
            K = polar.get_K(ac.strike.M_dash);
            Tfrac = get_thrust_frac(ac.strike.M_dash, ac.strike.h_combat, 1.08, true, false);
            TW = dash(WS, ac.strike.M_dash, ac.strike.h_combat, CD0, K, ac.strike.Wfracs(5), Tfrac);
            % polar = ac.polar.strike.clean;
            % TW = dash(WS, ac.strike.M_dash, ac.strike.h_combat, polar.CD0, getK(ac, polar), ac.strike.Wfracs(5), Tfrac);
        elseif isequal(con_fun, @cruise_1)
            polar = ac.polar.clean;
            CD0 = polar.get_CD0(ac.initial.h_cruise, ac.initial.M_cruise);
            K = polar.get_K(ac.initial.M_cruise);
            Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
            TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, CD0, K, ac.strike.Wfracs(3), Tfrac);
            % polar = ac.polar.strike.clean;
            % TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, polar.CD0, getK(ac, polar), ac.strike.Wfracs(3), Tfrac);
        elseif isequal(con_fun, @cruise_2)
            polar = ac.polar.clean;
            CD0 = polar.get_CD0(ac.initial.h_cruise, ac.initial.M_cruise);
            K = polar.get_K(ac.initial.M_cruise);
            Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_cruise, 1.08, false, false);
            TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, CD0, K, ac.strike.Wfracs(8), Tfrac);
            % polar = ac.polar.strike.clean;
            % TW = cruise(WS, ac.initial.V_cruise, ac.initial.h_cruise, polar.CD0, getK(ac, polar), ac.strike.Wfracs(8), Tfrac);
        elseif isequal(con_fun, @ceiling)
            polar = ac.polar.clean;
            CD0 = polar.get_CD0(ac.initial.h_ceiling, ac.initial.M_cruise);
            K = polar.get_K(ac.initial.M_cruise);
            Tfrac = get_thrust_frac(ac.initial.M_cruise, ac.initial.h_ceiling, 1.08, true, false);
            TW = ceiling(WS, ac.initial.M_cruise, ac.initial.h_ceiling, CD0, K, ac.strike.Wfracs(3), Tfrac);
            % polar = ac.polar.strike.clean;
            % TW = ceiling(WS, ac.initial.M_cruise, ac.initial.h_ceiling, polar.CD0, getK(ac, polar), ac.strike.Wfracs(3), Tfrac);
        elseif isequal(con_fun, @seroc_to)
            polar = ac.polar.catapult;
            [~, a, ~, ~] = atmoscoesa(0);
            CD0 = polar.get_CD0(0, ac.pt.seroc_to_V./a);
            K = polar.get_K(ac.pt.seroc_to_V./a);
            Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
            TW = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, CD0, K, true, true, ac.initial.num_eng, true, ac.strike.Wfracs(1), Tfrac);
            % polar = ac.polar.strike.full_gear;
            % TW = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, polar.CD0, getK(ac, polar), true, true, ac.initial.num_eng, true, ac.strike.Wfracs(1), Tfrac);
        elseif isequal(con_fun, @seroc_ap)
            Wfrac_land_strike = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ ac.strike.W0;
            polar = ac.polar.approach;
            [~, a, ~, ~] = atmoscoesa(0);
            CD0 = polar.get_CD0(0, ac.pt.seroc_ap_V./a);
            K = polar.get_K(ac.pt.seroc_to_V./a);
            Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
            TW = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, CD0, K, true, true, ac.initial.num_eng, true, Wfrac_land_strike, Tfrac);
            % polar = ac.polar.strike.full_gear;
            % TW = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, polar.CD0, getK(ac, polar), true, true, ac.initial.num_eng, true, Wfrac_land_strike, Tfrac);
        elseif isequal(con_fun, @climb_1)
            polar = ac.polar.clean;
            [~, a, ~, ~] = atmoscoesa(0);
            [V, ~] = get_best_climb_V(ac, ac.strike.Wfracs(2), ac.strike.W0, 0, polar, false);
            CD0 = polar.get_CD0(0, V./a);
            K = polar.get_K(V./a);
            Tfrac = get_thrust_frac(V./a, 0, 1.08, false, false);
            TW = climb_rate(WS, ac.strike.climb_rate, V, 0, CD0, K, false, false, ac.initial.num_eng, false, ac.strike.Wfracs(2), Tfrac);
            % polar = ac.polar.strike.clean;
            % TW = climb_rate(WS, 2.54, ac.initial.V_climb, 0, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.strike.Wfracs(2), Tfrac);
        elseif isequal(con_fun, @climb_2)
            polar = ac.polar.clean;
            CD0 = polar.get_CD0(0, ac.strike.M_dash);
            K = polar.get_K(ac.strike.M_dash);
            Tfrac = get_thrust_frac(ac.strike.M_dash, 0, 1.08, false, false);
            TW = climb_rate(WS, ac.strike.climb_rate_combat, ac.strike.V_dash, 0, CD0, K, false, false, ac.initial.num_eng, false, ac.strike.Wfracs(6), Tfrac);
            % polar = ac.polar.strike.clean;
            % TW = climb_rate(WS, 65, ac.strike.V_dash, 0, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.strike.Wfracs(6), Tfrac);
        elseif isequal(con_fun, @climb_3)
            polar = ac.polar.clean;
            [~, a, ~, ~] = atmoscoesa(0);
            [V, ~] = get_best_climb_V(ac, ac.strike.Wfracs(7), ac.strike.W0, 0, polar, false);
            CD0 = polar.get_CD0(0, V./a);
            K = polar.get_K(V./a);
            Tfrac = get_thrust_frac(V./a, 0, 1.08, false, false);
            TW = climb_rate(WS, ac.strike.climb_rate, V, 0, CD0, K, false, false, ac.initial.num_eng, false, ac.strike.Wfracs(7), Tfrac);
            % polar = ac.polar.strike.clean;
            % TW = climb_rate(WS, 2.54, ac.initial.V_climb, 0, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.strike.Wfracs(7), Tfrac);
        elseif isequal(con_fun, @takeoff)
            polar = ac.polar.takeoff;
            [~, a, ~, ~] = atmoscoesa(ac.initial.h_land);
            CD0 = polar.get_CD0(ac.initial.h_land, ac.pt.seroc_to_V./a);
            % K = polar.get_K(ac.pt.seroc_to_V./a);
            Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
            TW = takeoff(WS, ac.initial.d_land, ac.initial.h_land, CD0, polar.get_CLmax(), 0.68, 0.025, ac.strike.Wfracs(1), Tfrac);
            % polar = ac.polar.strike.half_gear;
            % TW = takeoff(WS, 1000, ac.initial.h_land, polar.CD0, polar.CLmax, 0.68, 0.025, ac.strike.Wfracs(1), Tfrac);
        end
        R = T0 - TW .* ac.strike.W0;
    end
end

function [R, ac] = W0_residual(ac, mission_fun, T0, S, W0)
    if isequal(mission_fun, @a2a_ref_Ffrac)
        ac.a2a.W0 = W0;

        [Ffrac, ~, ~] = mission_fun(ac);
        ac.a2a.Wf = W0 .* Ffrac;
        ac.a2a.We = empty_weight(ac, mission_fun);

        % Modify engine weight using maximum thrust
        ac.a2a.We = ac.a2a.We + (get_Weng(T0) - get_Weng(ac.initial.T_max));

        R = W0 - (ac.a2a.W_crew + ac.a2a.W_pay) - ac.a2a.We - ac.a2a.Wf;
    elseif isequal(mission_fun, @strike_ref_Ffrac)
        ac.strike.W0 = W0;

        [Ffrac, ~, ~] = mission_fun(ac);
        ac.strike.Wf = W0 .* Ffrac;
        ac.strike.We = empty_weight(ac, mission_fun);

        % Modify engine weight using maximum thrust
        ac.strike.We = ac.strike.We + (get_Weng(T0) - get_Weng(ac.initial.T_max));
        
        R = W0 - (ac.strike.W_crew + ac.strike.W_pay) - ac.strike.We - ac.strike.Wf;
    end
end