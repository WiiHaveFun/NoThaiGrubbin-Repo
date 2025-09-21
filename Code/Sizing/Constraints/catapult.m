function [WSc, TWc] = catapult(WS, TW, W, CD0, K, CLmax, Wfrac, Tfrac)
% CATAPULT  Caculates the required TWR and wing loading for catapult
% launch.
%   [WS] = recovery(W, CLmax, Wfrac) 
load("catapult_p.mat", "p");

[~, ~, P, ~] = atmoscoesa(0);
R = 287;
T = 305.2611; % Tropical day (89.8 F)
rho = P ./ (R .* T);

% Convert to TWR and wing loading at mission segment start
TW = TW ./ Wfrac .* Tfrac;
WS = WS .* Wfrac;

[WSm, TWm] = meshgrid(WS, TW);

% Speed represented by 0.9 CLmax
V2 = sqrt(2.*WSm ./ (rho.*0.9.*CLmax));

% Airspeed with 0.065g longitudinal acceleration at 0 FPA
A = 0.5.*rho.*CD0;
B = (0.065-TWm).*WSm;
C = 2.*K./rho .* WSm.^2;
discriminant = B.^2 - 4.*A.*C;
y1 = (-B + sqrt(discriminant)) ./ (2.*A);
y2 = (-B - sqrt(discriminant)) ./ (2.*A);
V_candidates = cat(3, sqrt(y1), -sqrt(y1), ...
                   sqrt(y2), -sqrt(y2));
V_candidates(imag(V_candidates) ~= 0) = NaN;
V_candidates(V_candidates <= 0) = NaN;
V3 = min(V_candidates, [], 3, "omitnan");

% Multi-engine: Airspeed for minimum control with OEI
% Considered as the speed required for 200 fpm climb
% Initial analysis shows it is not constraining
% Causes the analysis to be slow because of fsolve
% Is ignored and will be validated in post
% V4 = zeros(size(WSm));
% options = optimoptions("fsolve", "Display", "none");
% for i = 1:length(WS)
%     for j = 1:length(TW)
%         V4(i, j) = fsolve(@(V) climb_velocity(V, TW(j), WS(i)), 75, options);
%     end
% end

V = max(V2, V3, "includenan");
Wm = polyval(p, V./0.514444) .* 1000 .* 4.44822;
M = contourc(WS, TW, Wm, [W, W]);
num_vert = M(2, 1);

% Convert to takeoff TWR and wing loading
TWc = M(2, 2:1+num_vert) .* Wfrac ./ Tfrac;
WSc = M(1, 2:1+num_vert) ./ Wfrac;

% function R = climb_velocity(V, TW, WS)
%     Vg = 200 ./ 196.9; % 200 ft/min to m/s
%     TW = TW ./ 2;
%     R = -Vg + V.*TW - rho.*V.^3.*CD0./(2.*WS) - 2.*K./(rho.*V).*WS;
% end
end
