function TW = turn_rate_ref(WS, psidot, h, polar, Wfrac, Tfrac)
% TURN_RATE  Calculates the required TWR for a turn rate.
%   [TW] = TURN_RATE(WS, M, h)

g = 9.81;

% Convert to wing loading at mission segment start
WS = WS .* Wfrac;

[~, a, ~, rho] = atmoscoesa(h);

% V = linspace(1, 600, 1000);
% for i = 1:1000
%     [Ris(i), TW(i)] = turn_rate_fun2(V(i), WS);
% end
% figure();
% plot(V./a, Ris)
% % hold on
% % plot(V./a, TW)

options = optimoptions("fsolve", "Display", "final");
options = optimoptions("fmincon", "Display", "none");
TW = zeros(size(WS));
Tfrac = zeros(size(WS));
V = 10;
% for i = 1:length(WS)
for i = 1:length(WS)
    % [out, ~, exitflag, ~] = fsolve(@(x) turn_rate_fun(x, WS(i)), [1, V], options);
    % [V, ~, exitflag, ~] = fsolve(@(x) turn_rate_fun2(x, WS(i)), 300, options);
    % if exitflag <= 0
    %     % V = fsolve(@(x) turn_rate_fun2(x, WS(i)), 1000, options);
    %     TW(i:end) = 3; % Kill solver early
    %     Tfrac(i:end) = 1;
    %     break
    % end
    % [~, TW(i)] = turn_rate_fun2(V, WS(i));
    % TW(i) = out(1);
    % V = out(2);
    % Tfrac(i) = get_thrust_frac(V./a, h, 1.08, true, false);
    % if Tfrac(i) < 0
    %     Tfrac(i) = 0.01;
    % end
    V = fmincon(@(v) turn_rate_min(v, WS(i)), V, [], [], [], [], 0, [], [], options);
    TW(i) = turn_rate_min(V, WS(i));
end

% Convert to SLS TWR
% TW = TW .* Wfrac ./ Tfrac;
TW = TW .* Wfrac;

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

function [R, tw] = turn_rate_fun2(v, ws)
    q = 0.5 .* rho .* v.^2;

    M = v./a;
    CD0 = polar.get_CD0(h, M);
    K = polar.get_K(M);

    n = sqrt((psidot.*v./g).^2 + 1);
    tw = 2.*n .* sqrt(K.*CD0);
    R = -ws + tw ./ (2.*n.^2.*K ./ q);
end

function [tw, tfrac] = turn_rate_min(v, ws)
    q = 0.5 .* rho .* v.^2;

    M = v./a;
    CD0 = polar.get_CD0(h, M);
    K = polar.get_K(M);

    n = sqrt((psidot.*v./g).^2 + 1);

    tw = q.*CD0 ./ ws + ws .* (n.^2.*K ./ q);
    tfrac = get_thrust_frac(v./a, h, 1.08, true, false);
    if tfrac < 0
        tfrac = 1e-6;
    end
    tw = tw ./ tfrac;
end
end

