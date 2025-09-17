function TW = climb_rate(WS, Vg, V, h, CD0, K, max, OEI, Neng, Wfrac, Tfrac)
% CLIMB_RATE  Calculates the required TWR for a climb rate.
%   [TW] = CLIMB_RATE(WS, M, h)

% Convert to wing loading at mission segment start
WS = WS .* Wfrac;

[~, ~, ~, rho] = atmoscoesa(h);

% Dash constraint
TW = (Vg + rho.*V.^3.*CD0 ./ (2.*WS) + 2.*K ./ (rho.*V) .* WS) ./ V;
% Convert to SLS TWR with correction for 50 F above standard
% TODO change if constraining climbs above sea level
TW = TW .* Wfrac ./ Tfrac .* (1./0.8);
if max % max continuous thrust
    TW = TW .* (1./0.94);
end

if OEI
    TW = TW .* (Neng ./ (Neng - 1));
end
