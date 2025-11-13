function TW = turn_rate_ref(WS, psidot, h, polar, Wfrac, Tfrac)
% TURN_RATE  Calculates the required TWR for a turn rate.
%   [TW] = TURN_RATE(WS, M, h)

g = 9.81;

% Convert to wing loading at mission segment start
WS = WS .* Wfrac;

[~, a, ~, rho] = atmoscoesa(h);

options = optimoptions("fsolve", "Display", "none");
TW = zeros(size(WS));
Tfrac = zeros(size(WS));
V = 1;
% for i = 1:length(WS)
for i = 1:length(WS)
    [out, ~, exitflag, ~] = fsolve(@(x) turn_rate_fun(x, WS(i)), [1, V], options);
    if exitflag <= 0
        % out = fsolve(@(x) turn_rate_fun(x, WS(i)), [1, 1], options);
        TW(i:end) = 3; % Kill solver early
        Tfrac(i:end) = 1;
        break
    end
    TW(i) = out(1);
    V = out(2);
    Tfrac(i) = get_thrust_frac(V./a, h, 1.08, true, false);
    if Tfrac(i) < 0
        Tfrac(i) = 0.01;
    end
end

% Convert to SLS TWR
TW = TW .* Wfrac ./ Tfrac;

function R = turn_rate_fun(x, ws)
    tw = x(1);
    v = x(2);
    q = 0.5 .* rho .* v.^2;

    M = v./a;
    CD0 = polar.get_CD0(h, M);
    K = polar.get_K(M);

    n = sqrt((psidot.*v./g).^2 + 1);
    R(1) = -tw + q.*CD0 ./ ws + ws .* (n.^2.*K ./ q);
    R(2) = -ws + q./n .* sqrt(CD0./K);
end
end

