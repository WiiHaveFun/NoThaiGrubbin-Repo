function WS = recovery(W, CLmax, Wfrac)
% RECOVERY  Caculates the required wing loading arrested recovery.
%   [WS] = recovery(W, CLmax, Wfrac) 

[~, ~, P, ~] = atmoscoesa(0);
R = 287;
T = 305.2611; % Tropical day (89.8 F)
rho = P ./ (R .* T);

% Add 15 knots for WOD
WS = 0.5.*rho .* (((Vmax(W.*Wfrac))./(1.05.*1.1)) + 15.*0.514444).^2 .* CLmax;

% Convert to takeoff wing loading
WS = WS ./ Wfrac;

end

function V = Vmax(W)
    load("arrestment_p.mat");
    if W < 40000 .* 4.44822 % lbf to N
        V = 145; % kts
    else
        V = polyval(p, W ./ 4.44822);
    end
    V = min(V, 145) .* 0.514444; % Ceiling for V, convert kts to m/s  
end
