function TW = ceiling(WS, M, h, CD0, K, Wfrac, Tfrac)
% CEILING  Calculates the required TWR for a ceiling speed and altitude.
%   [TW] = CEILING(WS, M, h) calculates TWR for a ceiling speed and altitude.

% Convert to wing loading at mission segment start
WS = WS .* Wfrac;

[~, ~, P, ~] = atmoscoesa(h);
gamma = 1.4;
q = 0.5.*gamma.*P.*M.^2;

% Ceiling constraint
TW = q .* CD0 ./ WS + WS .* (K ./ q) + 0.001;
% Convert to SLS TWR
TW = TW .* Wfrac ./ Tfrac;
