function TW = turn_rate(WS, psidot, h, CD0, K, Wfrac, Tfrac)
% TURN_RATE  Calculates the required TWR for a turn rate.
%   [TW] = TURN_RATE(WS, M, h)

g = 9.81;

% Convert to wing loading at mission segment start
WS = WS .* Wfrac;

[~, ~, ~, rho] = atmoscoesa(h);

options = optimoptions("fsolve", "Display", "none");
TW = zeros(size(WS));
for i = 1:length(WS)
    out = fsolve(@(x) turn_rate_fun(x, WS(i)), [1, 50], options);
    TW(i) = out(1);
end

% Convert to SLS TWR
TW = TW .* Wfrac ./ Tfrac;

function R = turn_rate_fun(x, ws)
    tw = x(1);
    v = x(2);
    q = 0.5 .* rho .* v.^2;

    n = sqrt((psidot.*v./g).^2 + 1);
    R(1) = -tw + q.*CD0 ./ ws + ws .* (n.^2.*K ./ q);
    R(2) = -ws + q./n .* sqrt(CD0./K);
end
end

