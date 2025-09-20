function TW = takeoff(WS, Sg, h, CD0, CLmax, BPR, mu, Wfrac, Tfrac)
% TAKEOFF  Calculates the required TWR for a takeoff ground roll.
%   [TW] = TAKEOFF(WS, CD0, CLmax, Wfrac, Tfrac).

% Convert to wing loading at mission segment start
WS = WS .* Wfrac;

[~, ~, ~, rho] = atmoscoesa(h);
rho_imp = rho .* 0.00194032; % to slug/ft^3
Sg_imp = Sg .* 3.28084;

options = optimoptions("fsolve", "Display", "none");
TW = zeros(size(WS));
for i = 1:length(WS)
    TW(i) = fsolve(@(tw) takeoff_dist(tw, WS(i)), 0.5, options);
end

% Convert to SLS TWR
TW = TW .* Wfrac ./ Tfrac;

function R = takeoff_dist(tw, ws)
    ws_imp = ws .* 0.020885;

    k1 = 0.0447;
    k2 = 0.75 .* (5 + BPR) ./ (4 + BPR);
    
    R = -Sg_imp + k1.*ws_imp ./ (rho_imp.*(CLmax.*(k2.*tw - mu) - 0.72.*CD0));
end
end
