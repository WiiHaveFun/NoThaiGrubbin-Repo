function WS = landing(Sfl, h, CLmax, Wfrac)
% LANDING  
%   [WS] = LANDING(Nz, V, h, CLmax, Wfrac) calculates TWR for a dash speed
%   and altitude.

[~, ~, ~, rho] = atmoscoesa(h);
rho_imp = rho .* 0.00194032; % to slug/ft^3
Sfl_imp = Sfl .* 3.28084;

WS_imp = 1.68781.^2 .* Sfl_imp.*rho_imp.*CLmax ./ (2.*0.3.*1.2.^2);
WS = WS_imp ./ 0.020885;

% Convert to takeoff wing loading
WS = WS ./ Wfrac;
