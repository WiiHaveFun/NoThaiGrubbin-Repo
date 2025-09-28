function [WS] = catapult2(TW, W, CD0, K, CLmax, Wfrac, Tfrac)
% CATAPULT  Caculates the required wing loading for catapult launch.
%   [WS] = recovery(W, CLmax, Wfrac) 
load("catapult_p2.mat", "p");

[~, ~, P, ~] = atmoscoesa(0);
R = 287;
T = 305.2611; % Tropical day (89.8 F)
rho = P ./ (R .* T);

% Convert to TWR and wing loading at mission segment start
TW = TW ./ Wfrac .* Tfrac;

% Catapult endspeed for the given weight W
V = polyval(p, W ./ 4.44822 ./ 1000) .* 0.514444;
% Required wing loading for 0.9 CLmax
WS2 = 0.5.*rho.*V.^2.*0.9.*CLmax;

% Airspeed with 0.065g longitudinal acceleration at 0 FPA
A = 2.*K ./ (rho.*V.^2);
B = 0.065 - TW;
C = 0.5.*rho.*V.^2.*CD0;
WS3 = (-B + sqrt(B.^2 - 4.*A.*C)) ./ (2.*A);
WS3(imag(WS3) ~= 0) = 0;

% Constrained by lower wing loading, converted to takeoff wing loading 
WS = min(WS2, WS3) ./ Wfrac;
end
