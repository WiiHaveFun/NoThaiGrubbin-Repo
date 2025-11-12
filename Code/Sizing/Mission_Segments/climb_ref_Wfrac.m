function [Wfrac_2, dx] = climb_ref_Wfrac(ac, Wfrac_1, W0, h0, h1, polar, is_max)
% CLIMB_REF_WFRAC  Calculates weight fraction and distance travelled during
% a climb.
%   [Wfrac_2, dx] = CLIMB_REF_WFRAC() calculates the weight fraction and
%   distance travelled during a climb.

options = optimoptions("fsolve", "Display", "none");

g = 9.81; % Acceleration due to gravity

n = 5; % Number of subsegments
h = linspace(h0, h1, n+1); % Linear spacing in altitude

% Takeoff wing loading, TWR, thrust
WS0 = W0 ./ ac.initial.Sref; 
if is_max
    c = ac.initial.TSFC_wet;
    T0 = ac.initial.T_max;
else
    c = ac.initial.TSFC_dry;
    T0 = ac.initial.T_mil;
end
TW0 = T0 ./ W0;

% Loop over subsegments
Wfrac_2 = 1;
dx = 0;
for i = 1:n
    % Convert to climb start values
    WS = WS0 .* Wfrac_1;
    TW = TW0 ./ Wfrac_1;
    W = W0 .* Wfrac_1;
    % Convert to subsegment start values
    WS = WS .* Wfrac_2;
    TW = TW ./ Wfrac_2;
    W = W .* Wfrac_2;

    [~, a, ~, rho_i] = atmoscoesa(h(i));
    [~, ~, ~, rho_ip1] = atmoscoesa(h(i+1));

    % Initial guess
    % M = 0.9;
    % % Velocity for best rate of climb at beginning and end of subsegment
    % % Assume change in WS and TW is small
    % V_i = sqrt(WS ./ (3.*rho_i.*CD0) .* (TW + sqrt((TW).^2 + 12.*CD0.*K)));
    % V_ip1 = sqrt(WS ./ (3.*rho_ip1.*CD0) .* (TW + sqrt((TW).^2 + 12.*CD0.*K)));

    V_i = fsolve(@(V) best_V_residual(V, WS, TW, h(i), polar, is_max), 0.9.*a, options);
    V_ip1 = fsolve(@(V) best_V_residual(V, WS, TW, h(i+1), polar, is_max), 0.9.*a, options);
    % V_i = fzero(@(V) best_V_residual(V, WS, TW, h(i), polar, is_max), [1 2.0.*a]);
    % V_ip1 = fzero(@(V) best_V_residual(V, WS, TW, h(i+1), polar, is_max), [1 2.0.*a]);

    M = V_i ./ a;
    CD0 = polar.get_CD0(h(i), M);
    K = polar.get_K(M);

    % Change in energy height
    dHe = (h(i+1) + V_ip1.^2 ./ (2.*g)) - (h(i) + V_i.^2 ./ (2.*g));

    % Get thrust with thrust fraction correction
    T = T0 .* get_thrust_frac(V_i./a, h(i), 1.08, is_max, false);

    % Get drag
    % Assume L = W, Use quantities at subsegment start
    CL = 2.*W ./ (rho_i .* V_i.^2 .* ac.initial.Sref);
    CD = CD0 + K .* CL.^2;
    D = 0.5 .* rho_i .* V_i.^2 .* ac.initial.Sref .* CD;

    % New weight fraction for climb segment
    Wfrac_2 = Wfrac_2 .* exp(-c.*dHe ./ (V_i .* (1 - D./T)));

    % Specific excess power
    Ps = (T.*V_i - D.*V_i) ./ W;
    % Distance travelled during subsegment
    dx = dx + dHe./Ps .* V_i;
end
end

function R = best_V_residual(V, WS, TW, h, polar, is_max)
    % Calculate TWR with thrust fraction correction
    [~, a, ~, rho] = atmoscoesa(h);
    M = V./a;
    TW = TW .* get_thrust_frac(M, h, 1.08, is_max, false);

    CD0 = polar.get_CD0(h, M);
    K = polar.get_K(M);

    % Residual is difference between velocity and velocity for best rate of
    % climb
    R = V - sqrt(WS ./ (3.*rho.*CD0) .* (TW + sqrt((TW).^2 + 12.*CD0.*K)));
end