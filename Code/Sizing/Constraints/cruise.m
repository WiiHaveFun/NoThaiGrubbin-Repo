function TW = cruise(WS, V, h, CD0, K, Wfrac, Tfrac)
% CRUISE  Calculates the required TWR for cruise.
%   [TW] = CRUISE(WS, V, h, CD0, K, Wfrac, Tfrac)

% Convert to wing loading at mission segment start
WS = WS .* Wfrac;

[~, ~, ~, rho] = atmoscoesa(h);
q = 0.5 .* rho .* V.^2;

% Cruise constraint
TW = q.*CD0 ./ WS + WS .* (K./q);
% Convert to SLS TWR
TW = TW .* Wfrac ./ Tfrac;