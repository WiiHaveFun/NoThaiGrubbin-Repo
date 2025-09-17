function TW = dash(WS, M, h, CD0, K, Wfrac, Tfrac)
% DASH  Calculates the required TWR for a dash speed and altitude.
%   [TW] = DASH(WS, M, h) calculates TWR for a dash speed and altitude.

% Convert to wing loading at mission segment start
WS = WS .* Wfrac;

[~, a, ~, rho] = atmoscoesa(h);
V = M .* a;
q = 0.5 .* rho .* V.^2;

% Dash constraint
TW = q .* CD0 ./ WS + WS .* (K ./ q);
% Convert to SLS TWR
TW = TW .* Wfrac ./ Tfrac;
