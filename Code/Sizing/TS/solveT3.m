function T0 = solveT3(ac, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, Tfrac)

epsilon = 1;
T0 = ac.initial.T_max;
i = 0;
while true
    [ac, flag] = iterate_W0_TS(ac, Wfrac_reg, mission_fun, T0, S);
    if flag <= 0
        disp("W0 failed");
    end

    WS = ac.a2a.W0 ./ S;
    if isequal(con_fun, @dash)
        polar = ac.polar.a2a.clean;
        TW = con_fun(WS, ac.a2a.M_dash, ac.a2a.h_dash, 2.*polar.CD0, 2.*getK(ac, polar), ac.a2a.Wfracs(Wfrac_idx), Tfrac);
    elseif isequal(con_fun, @turn_rate)
        polar = ac.polar.a2a.clean;
        TW = con_fun(WS, ac.a2a.turn_rate, 2.*ac.a2a.h_combat, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(Wfrac_idx), []);
    elseif isequal(con_fun, @cruise)
        polar = ac.polar.a2a.clean;
        TW = con_fun(WS, ac.initial.V_cruise, ac.initial.h_cruise, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(Wfrac_idx), Tfrac);
    elseif isequal(con_fun, @ceiling)
        polar = ac.polar.a2a.clean;
        TW = con_fun(WS, ac.initial.M_cruise, ac.initial.h_ceiling, polar.CD0, getK(ac, polar), ac.a2a.Wfracs(Wfrac_idx), Tfrac);
    elseif isequal(con_fun, @seroc_to)
        polar = ac.polar.a2a.full_gear;
        TW = climb_rate(WS, ac.pt.seroc_to, ac.pt.seroc_to_V, 0, polar.CD0, getK(ac, polar), true, true, ac.initial.num_eng, true, ac.a2a.Wfracs(Wfrac_idx), Tfrac);
    elseif isequal(con_fun, @seroc_ap)
        Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
        polar = ac.polar.a2a.full_gear;
        TW = climb_rate(WS, ac.pt.seroc_ap, ac.pt.seroc_ap_V, 0, polar.CD0, getK(ac, polar), true, true, ac.initial.num_eng, true, Wfrac_land_a2a, Tfrac);
    elseif isequal(con_fun, @climb_1)
        polar = ac.polar.a2a.clean;
        TW = climb_rate(WS, 10.*2.54, ac.initial.V_climb, 0, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(2), Tfrac);
    elseif isequal(con_fun, @climb_2)
        polar = ac.polar.a2a.clean;
        TW = climb_rate(WS, 10.*2.54, ac.initial.V_climb, ac.a2a.h_combat, polar.CD0, getK(ac, polar), false, false, ac.initial.num_eng, false, ac.a2a.Wfracs(7), Tfrac);
    elseif isequal(con_fun, @takeoff)
        polar = ac.polar.a2a.half_gear;
        TW = takeoff(WS, 762, 0, polar.CD0, polar.CLmax, 0.68, 0.025, ac.a2a.Wfracs(1), Tfrac);
    end

    T0new = TW .* ac.a2a.W0;
    if abs(T0new - T0) < epsilon
        break
    end
    T0 = T0new;
    i = i+1;
end
disp(i);
end