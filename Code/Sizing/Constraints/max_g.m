function WS = max_g(Nz, V, h, CLmax, Wfrac)
% MAX_G  Caculates the required wing loading for a desired max load factor.
%   [WS] = max_g(Nz, V, h, CLmax, Wfrac) calculates TWR for a dash speed
%   and altitude.

[~, ~, ~, rho] = atmoscoesa(h);
q = 0.5 .* rho .* V.^2;

WS = q.*CLmax ./ Nz;

% Convert to takeoff wing loading
WS = WS ./ Wfrac;
