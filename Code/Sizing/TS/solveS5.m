function [S, x] = solveS5(ac, T0, mission_fun, con_fun, Tfrac, x0)



options = optimoptions("fsolve", "Display", "final");
if isempty(x0)
    x0 = [1; 0.5];
end
[x, ~, flag, ~] = fsolve(@(x) residual(x, ac, T0, mission_fun, con_fun, Tfrac), x0, options);
if flag <= 0
    S = NaN;
    % S = x(1) .* ac.initial.Sref;
else
    S = x(1) .* ac.initial.Sref;
end
end

function R = residual(x, ac, T0, mission_fun, con_fun, Tfrac)
    R = zeros(2, 1);
    S = x(1) .* ac.initial.Sref;

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
    
    if isequal(mission_fun, @a2a_ref_Ffrac)
        W0 = x(2) .* ac.a2a.W0;

        [R(1), ac] = W0_residual(ac, mission_fun, T0, S, W0);
        [~, ac.a2a.Wfracs, ac.a2a.segments] = mission_fun(ac);
    elseif isequal(mission_fun, @strike_ref_Ffrac)
        W0 = x(2) .* ac.strike.W0;
        
        [R(1), ac] = W0_residual(ac, mission_fun, T0, S, W0);
        [~, ac.strike.Wfracs, ac.strike.segments] = mission_fun(ac);
    end

    R(2) = S_residual(ac, T0, S, mission_fun, con_fun, Tfrac);
end

function R = S_residual(ac, T0, S, mission_fun, con_fun, Tfrac)
    if isequal(mission_fun, @a2a_ref_Ffrac)
        if isequal(con_fun, @max_g)
            polar = ac.polar.clean;
            WS = max_g(ac.a2a.max_g, ac.a2a.max_g_V, ac.a2a.h_combat, polar.get_CLmax(), ac.a2a.Wfracs(6));
            % polar = ac.polar.a2a.clean;
            % WS = max_g(ac.a2a.max_g, ac.a2a.max_g_V, ac.a2a.h_combat, polar.CLmax, ac.a2a.Wfracs(6));
        elseif isequal(con_fun, @landing)
            Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
            polar = ac.polar.landing;
            WS = landing(ac.initial.d_land, ac.initial.h_land, polar.get_CLmax(), Wfrac_land_a2a);
            % polar = ac.polar.a2a.full_gear;
            % WS = landing(2000, ac.initial.h_land, polar.CLmax, Wfrac_land_a2a);
        elseif isequal(con_fun, @catapult2)
            TW = T0 ./ ac.a2a.W0;
            [~, a, ~, ~] = atmoscoesa(0);
            polar = ac.polar.catapult;
            CD0 = polar.get_CD0(0, ac.pt.seroc_to_V./a);
            K = polar.get_K(ac.pt.seroc_to_V./a);
            Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
            WS = catapult2(TW, ac.a2a.W0, CD0, K, polar.get_CLmax(), ac.a2a.Wfracs(1), Tfrac);
            % polar = ac.polar.a2a.full_gear;
            % WS = catapult2(TW, ac.a2a.W0, polar.CD0, getK(ac, polar), polar.CLmax, ac.a2a.Wfracs(1), Tfrac);
        elseif isequal(con_fun, @recovery)
            Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
            polar = ac.polar.approach;
            WS = recovery(ac.a2a.W0, polar.get_CLmax(), Wfrac_land_a2a);
            % polar = ac.polar.a2a.full_gear;
            % WS = recovery(ac.a2a.W0, polar.CLmax, Wfrac_land_a2a);
        end
        R = S - ac.a2a.W0 ./ WS;
    elseif isequal(mission_fun, @strike_ref_Ffrac)
        if isequal(con_fun, @max_g)
            polar = ac.polar.clean;
            WS = max_g(ac.strike.max_g, ac.strike.max_g_V, ac.strike.h_combat, polar.get_CLmax(), ac.strike.Wfracs(6));
            % polar = ac.polar.strike.clean;
            % WS = max_g(ac.strike.max_g, ac.strike.max_g_V, ac.strike.h_combat, polar.CLmax, ac.strike.Wfracs(6));
        elseif isequal(con_fun, @landing)
            Wfrac_land_strike = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ ac.strike.W0;
            polar = ac.polar.landing;
            WS = landing(ac.initial.d_land, ac.initial.h_land, polar.get_CLmax(), Wfrac_land_strike);
            % polar = ac.polar.strike.full_gear;
            % WS = landing(2000, ac.initial.h_land, polar.CLmax, Wfrac_land_strike);
        elseif isequal(con_fun, @catapult2)
            TW = T0 ./ ac.strike.W0;
            [~, a, ~, ~] = atmoscoesa(0);
            polar = ac.polar.catapult;
            CD0 = polar.get_CD0(0, ac.pt.seroc_to_V./a);
            K = polar.get_K(ac.pt.seroc_to_V./a);
            Tfrac = get_thrust_frac(0, 0, 1.08, true, true);
            WS = catapult2(TW, ac.strike.W0, CD0, K, polar.get_CLmax(), ac.strike.Wfracs(1), Tfrac);
            % polar = ac.polar.strike.full_gear;
            % WS = catapult2(TW, ac.strike.W0, polar.CD0, getK(ac, polar), polar.CLmax, ac.strike.Wfracs(1), Tfrac);
        elseif isequal(con_fun, @recovery)
            Wfrac_land_strike = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ ac.strike.W0;
            polar = ac.polar.approach;
            WS = recovery(ac.strike.W0, polar.get_CLmax(), Wfrac_land_strike);
            % polar = ac.polar.strike.full_gear;
            % WS = recovery(ac.strike.W0, polar.CLmax, Wfrac_land_strike);
        end
        R = S - ac.strike.W0 ./ WS;
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
