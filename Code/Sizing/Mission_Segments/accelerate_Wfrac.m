function [Wfrac_2, dx] = accelerate_Wfrac(ac, Wfrac_1, V0, V1, W0, h, polar, is_max)
% CLIMB_REF_WFRAC  Calculates weight fraction and distance travelled during
% a climb.
%   [Wfrac_2, dx] = CLIMB_REF_WFRAC() calculates the weight fraction and
%   distance travelled during a climb.

g = 9.81; % Acceleration due to gravity

n = 10; % Number of subsegments
V = linspace(V0, V1, n+1); % Linear spacing in velocity

% Takeoff wing loading, TWR, thrust
if is_max
    c = ac.initial.TSFC_wet;
    T0 = ac.initial.T_max;
else
    c = ac.initial.TSFC_dry;
    T0 = ac.initial.T_mil;
end

CD0 = polar.CD0;
K = 1 ./ (pi .* ac.initial.AR .* polar.e);

[~, a, ~, rho] = atmoscoesa(h);

% Loop over subsegments
Wfrac_2 = 1;
dx = 0;
for i = 1:n
    % Convert to acceleration start values
    W = W0 .* Wfrac_1;
    % Convert to subsegment start values
    W = W .* Wfrac_2;

    % Change in energy height
    dHe = (V(i+1).^2 - V(i).^2) ./ (2.*g);

    % Get thrust with thrust fraction correction
    T = T0 .* get_thrust_frac(V(i)./a, h, 1.08, is_max, false);

    % Get drag
    % Assume L = W, Use quantities at subsegment start
    CL = 2.*W ./ (rho .* V(i).^2 .* ac.initial.Sref);
    CD = CD0 + K .* CL.^2;
    D = 0.5 .* rho .* V(i).^2 .* ac.initial.Sref .* CD;

    % New weight fraction for climb segment
    Wfrac_2 = Wfrac_2 .* exp(-c.*dHe ./ (V(i) .* (1 - D./T)));

    % Specific excess power
    Ps = (T.*V(i) - D.*V(i)) ./ W;
    % Distance travelled during subsegment
    dx = dx + dHe./Ps .* V(i);
end
end
