function [ac] = iterate_W0(ac, Wfrac_reg, mission_fun)
% ITERATE_W0  Iteratively calculates takeoff weight for a mission.
%   [ac, W0] = ITERATE_W0(ac, Wfrac_fun, mission_fun) calculates takeoff weight.

epsilon = 1e-6; % Tolerance
diff = 2 .* epsilon;

ac.initial.W0 = fsolve(@(W0) W0_residual(ac, Wfrac_reg, mission_fun, W0), ac.initial.W0);
ac.initial.We = ac.initial.W0 .* (Wfrac_reg.A .* ac.initial.W0.^Wfrac_reg.C);
ac.initial.Wf = ac.initial.W0 .* (mission_fun(ac));
end

function R = W0_residual(ac, Wfrac_reg, mission_fun, W0)
    ac.initial.W0 = W0;
    Wfrac = Wfrac_reg.A .* ac.initial.W0.^Wfrac_reg.C;
    Ffrac = mission_fun(ac);
    R = W0 - (ac.initial.W_crew + ac.initial.W_pay) - W0.*(Wfrac + Ffrac);
end