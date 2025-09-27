function S = solveS(ac, T0, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, varargin)



% options = optimoptions("fsolve");
S = fsolve(@(S) T0_residual(ac, T0, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, varargin{:}), ac.initial.Sref);
% options = optimoptions("fmincon", ...
%         "Display", "none", ...
%         "Algorithm", "interior-point");
% obj = @(S) T0_residual(ac, T0, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, varargin{:}).^2;
% S = fmincon(obj, ac.initial.Sref, [], [], [], [], 1e-6, [], [], options);
end

function R = T0_residual(ac, T0, S, Wfrac_reg, mission_fun, con_fun, Wfrac_idx, varargin)
    [ac, flag] = iterate_W0_TS(ac, Wfrac_reg, @a2a_Ffrac, T0, S);
    if flag <= 0
        R = 1e6;
        return
    end

    if isequal(mission_fun, @a2a_Ffrac)
        if isequal(con_fun, @recovery)
            WS = con_fun(ac.a2a.W0, varargin{:}, ac.a2a.Wfracs(Wfrac_idx));
        else
            WS = con_fun(varargin{:}, ac.a2a.Wfracs(Wfrac_idx));
        end
        R = S - ac.a2a.W0 ./ WS;
    elseif isequal(mission_fun, @strike_Ffrac)
        if isequal(con_fun, @recovery)
            WS = con_fun(ac.strike.W0, varargin{:}, ac.strike.Wfracs(Wfrac_idx));
        else
            WS = con_fun(varargin{:}, ac.strike.Wfracs(Wfrac_idx));
        end
        R = S - ac.strike.W0 ./ WS;
    end
end