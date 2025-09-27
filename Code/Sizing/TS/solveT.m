function T0 = solveT(ac, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, Tfrac, varargin)



options = optimoptions("fsolve", "Display", "none");
T0 = fsolve(@(T0) T0_residual(ac, T0, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, Tfrac, varargin{:}), 1.0.*ac.initial.T_max);
end

function R = T0_residual(ac, T0, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, Tfrac, varargin)
    ac = iterate_W0_TS(ac, Wfrac_reg, @a2a_Ffrac, T0, S);

    if isequal(mission_fun, @a2a_Ffrac)
        WS = ac.a2a.W0 ./ S;
        TW = con_fun(WS, varargin{:}, ac.a2a.Wfracs(Wfrac_idx), Tfrac);
        R = T0 - TW .* ac.a2a.W0;
    elseif isequal(mission_fun, @strike_Ffrac)
        WS = ac.strike.W0 ./ S;
        TW = con_fun(WS, varargin{:}, ac.strike.Wfracs(Wfrac_idx), Tfrac);
        R = T0 - TW .* ac.strike.W0;
    end
end