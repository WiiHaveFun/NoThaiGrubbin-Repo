function [WSc, TWc] = catapult(WS, TW, W, CD0, K, CLmax, Wfrac, Tfrac)
% CATAPULT  Caculates the required TWR and wing loading for catapult
% launch.
%   [WS] = recovery(W, CLmax, Wfrac) 
load("catapult_p.mat");

[~, ~, P, ~] = atmoscoesa(0);
R = 287;
T = 305.2611; % Tropical day (89.8 F)
rho = P ./ (R .* T);

% Convert to TWR and wing loading at mission segment start
TW = TW ./ Wfrac .* Tfrac;
WS = WS .* Wfrac;

[WSm, TWm] = meshgrid(WS, TW);

V2 = sqrt(2.*WSm ./ (rho.*0.9.*CLmax));

A = 0.5.*rho.*CD0;
B = (0.065-TWm).*WSm;
C = 2.*K./rho .* WSm.^2;
discriminant = B.^2 - 4.*A.*C;
y1 = (-B + sqrt(discriminant)) ./ (2.*A);
y2 = (-B - sqrt(discriminant)) ./ (2.*A);
% valid = (discriminant >= 0) & (y1 >= 0) & (y2 >= 0);
V_candidates = cat(3, sqrt(y1), -sqrt(y1), ...
                   sqrt(y2), -sqrt(y2));
V_candidates(imag(V_candidates) ~= 0) = NaN;
V_candidates(V_candidates <= 0) = NaN;
V3 = min(V_candidates, [], 3, "omitnan");

V = max(V2, V3, "includenan");
Wm = polyval(p, V./0.514444) .* 1000 .* 4.44822;
M = contourc(WS, TW, Wm, [W, W]);
num_vert = M(2, 1);

% Convert to takeoff TWR and wing loading
TWc = M(2, 2:2+num_vert) .* Wfrac ./ Tfrac;
WSc = M(1, 2:2+num_vert) ./ Wfrac;
end
