function [ac, flag] = iterate_W0_TS_ref(ac, mission_fun, T0, S)
% ITERATE_W0  Iteratively calculates takeoff weight for a mission.
%   [ac, W0] = ITERATE_W0(ac, Wfrac_fun, mission_fun) calculates takeoff weight.

options = optimoptions("fsolve", "Display", "iter");
if isequal(mission_fun, @a2a_ref_Ffrac)
    [ac.a2a.W0, ~, flag, ~] = fsolve(@(W0) W0_residual(ac, mission_fun, T0, S, W0), ac.a2a.W0, options);
    [~, ac] = W0_residual(ac, mission_fun, T0, S, ac.a2a.W0);  
    [Ffrac, ac.a2a.Wfracs, ac.a2a.segments] = mission_fun(ac);
    ac.a2a.Wf = ac.a2a.W0 .* Ffrac;
elseif isequal(mission_fun, @strike_ref_Ffrac)
    ac.strike.W0 = fsolve(@(W0) W0_residual(ac, mission_fun, T0, S, W0), ac.strike.W0, options);
    [~, ac] = W0_residual(ac, mission_fun, T0, S, ac.strike.W0);
    [Ffrac, ac.strike.Wfracs, ac.strike.segments] = mission_fun(ac);
    ac.strike.Wf = ac.strike.W0 .* Ffrac;
else
    fprintf("Error. Invalid mission function.\n");
end
end

function [R, ac] = W0_residual(ac, mission_fun, T0, S, W0)
    sigma_wing = 44.*9.81; % kg/m^2 to N/m^2
    if isequal(mission_fun, @a2a_ref_Ffrac)        
        ac.a2a.W0 = W0;

        [Ffrac, ~, ~] = mission_fun(ac);
        ac.a2a.Wf = W0 .* Ffrac;
        ac.a2a.We = empty_weight(ac, mission_fun);
        R = W0 - (ac.a2a.W_crew + ac.a2a.W_pay) - ac.a2a.We - ac.a2a.Wf;
    elseif isequal(mission_fun, @strike_ref_Ffrac)
        ac.strike.W0 = W0;

        [Ffrac, ~, ~] = mission_fun(ac);
        ac.strike.Wf = W0 .* Ffrac;
        % ac.strike.We = empty_weight(ac, mission_fun);
        ac.strike.We = ac.a2a.We;
        R = W0 - (ac.strike.W_crew + ac.strike.W_pay) - ac.strike.We - ac.strike.Wf;
    end
end