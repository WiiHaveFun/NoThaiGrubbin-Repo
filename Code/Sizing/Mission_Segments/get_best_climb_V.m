function V = get_best_climb_V(ac, Wfrac_1, W0, h, polar, is_max)
% CLIMB_REF_WFRAC  Calculates weight fraction and distance travelled during
% a climb.
%   [Wfrac_2, dx] = CLIMB_REF_WFRAC() calculates the weight fraction and
%   distance travelled during a climb.

options = optimoptions("fsolve", "Display", "none");

% Takeoff wing loading, TWR, thrust
WS0 = W0 ./ ac.initial.Sref; 
if is_max
    T0 = ac.initial.T_max;
else
    T0 = ac.initial.T_mil;
end
TW0 = T0 ./ W0;

CD0 = polar.CD0;
K = 1 ./ (pi .* ac.initial.AR .* polar.e);

% Convert to climb start values
WS = WS0 .* Wfrac_1;
TW = TW0 ./ Wfrac_1;

[~, ~, ~, rho] = atmoscoesa(h);

% Velocity for best rate of climb at beginning and end of subsegment
% Assume change in WS and TW is small
V = sqrt(WS ./ (3.*rho.*CD0) .* (TW + sqrt((TW).^2 + 12.*CD0.*K)));
V = fsolve(@(V) best_V_residual(V, WS, TW, h, CD0, K, is_max), V, options);
end

function R = best_V_residual(V, WS, TW, h, CD0, K, is_max)
    % Calculate TWR with thrust fraction correction
    [~, a, ~, rho] = atmoscoesa(h);
    TW = TW .* get_thrust_frac(V./a, h, 1.08, is_max, false);

    % Residual is difference between velocity and velocity for best rate of
    % climb
    R = V - sqrt(WS ./ (3.*rho.*CD0) .* (TW + sqrt((TW).^2 + 12.*CD0.*K)));
end