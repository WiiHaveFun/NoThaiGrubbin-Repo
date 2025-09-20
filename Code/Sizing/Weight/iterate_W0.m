function [ac] = iterate_W0(ac, Wfrac_reg, mission_fun)
% ITERATE_W0  Iteratively calculates takeoff weight for a mission.
%   [ac, W0] = ITERATE_W0(ac, Wfrac_fun, mission_fun) calculates takeoff weight.

options = optimoptions("fsolve", "Display", "none");

epsilon = 1e-6; % Tolerance
diff = 2 .* epsilon;

if isequal(mission_fun, @a2a_Ffrac)
    ac.a2a.W0 = fsolve(@(W0) W0_residual(ac, Wfrac_reg, mission_fun, W0), ac.a2a.W0, options);
    ac.a2a.We = ac.a2a.W0 .* (Wfrac_reg.A .* ac.a2a.W0.^Wfrac_reg.C);
    [Ffrac, ac.a2a.Wfracs, ac.a2a.segments] = mission_fun(ac);
    ac.a2a.Wf = ac.a2a.W0 .* Ffrac;
elseif isequal(mission_fun, @strike_Ffrac)
    ac.strike.W0 = fsolve(@(W0) W0_residual(ac, Wfrac_reg, mission_fun, W0), ac.strike.W0, options);
    ac.strike.We = ac.strike.W0 .* (Wfrac_reg.A .* ac.strike.W0.^Wfrac_reg.C);
    [Ffrac, ac.strike.Wfracs, ac.strike.segments] = mission_fun(ac);
    ac.strike.Wf = ac.strike.W0 .* Ffrac;
else
    fprintf("Error. Invalid mission function.\n");
end
end

function R = W0_residual(ac, Wfrac_reg, mission_fun, W0)
    if isequal(mission_fun, @a2a_Ffrac)
        ac.a2a.W0 = W0;
        Wfrac = Wfrac_reg.A .* ac.a2a.W0.^Wfrac_reg.C;
        [Ffrac, ~, ~] = mission_fun(ac);
        R = W0 - (ac.a2a.W_crew + ac.a2a.W_pay) - W0.*(Wfrac + Ffrac);
    elseif isequal(mission_fun, @strike_Ffrac)
        ac.strike.W0 = W0;
        Wfrac = Wfrac_reg.A .* ac.strike.W0.^Wfrac_reg.C;
        [Ffrac, ~, ~] = mission_fun(ac);
        R = W0 - (ac.strike.W_crew + ac.strike.W_pay) - W0.*(Wfrac + Ffrac);
    end
end