function Cf = turb_cf(h, l, M)
% TURB_CF  Calculates the turbulent skin friction coefficient
%   [CF] = TURB_CF(h, L, M)

[T, a, ~, rho] = atmoscoesa(h);
mu = sutherland(T);

V = M .* a;
Re = rho .* V .* l ./ mu;

Cf = 0.455 ./ (log10(Re).^2.58 .* (1 + 0.144.*M.^2).^0.65);
end

function mu = sutherland(T)
% T is in K, mu is in kg/m.s
Tref = 273.15; muref = 1.716e-5; S = 110.4;
mu = muref.*(T./Tref).^1.5.*(Tref+S)./(T+S);
end