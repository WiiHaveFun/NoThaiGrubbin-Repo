function S = solveS3(ac, T0, Wfrac_reg, mission_fun, con_fun)

epsilon = 1e-2;
S = ac.initial.Sref;
i = 0;
while true
    [ac, flag] = iterate_W0_TS(ac, Wfrac_reg, mission_fun, T0, S);
    if flag <= 0
        disp("W0 failed");
    end

    if isequal(con_fun, @max_g)
        polar = ac.polar.a2a.clean;
        WS = max_g(ac.a2a.max_g, ac.a2a.max_g_V, ac.a2a.h_combat, polar.CLmax, ac.a2a.Wfracs(6));
    elseif isequal(con_fun, @landing)
        Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
        polar = ac.polar.a2a.full_gear;
        WS = landing(2000, 0, polar.CLmax, Wfrac_land_a2a);
    elseif isequal(con_fun, @recovery)
        Wfrac_land_a2a = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ ac.a2a.W0;
        polar = ac.polar.a2a.full_gear;
        WS = recovery(ac.a2a.W0, polar.CLmax, Wfrac_land_a2a);
    end

    Snew = ac.a2a.W0 ./ WS;
    if abs(Snew - S) < epsilon
        break
    end
    S = Snew;
    i = i+1;
end
disp(i);
end