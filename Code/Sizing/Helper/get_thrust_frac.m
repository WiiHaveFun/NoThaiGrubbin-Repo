function Tfrac = get_thrust_frac(M, h, TR, is_max)



[T, ~, P, ~] = atmoscoesa(h);
[Tstd, ~, Pstd, ~] = atmoscoesa(0);

theta = T ./ Tstd;
delta = P ./ Pstd;

g = 1.4;
theta0 = theta.*(1 + (g-1)./2.*M.^2);
delta0 = delta.*(1 + (g-1)./2.*M.^2).^(g./(g-1));

if is_max
    if theta0 <= TR
        Tfrac = delta0;
    else
        Tfrac = delta0 .* (1 - 3.5.*(theta0 - TR)./theta0);
    end
else
    if theta0 <= TR
        Tfrac = 0.6.*delta0;
    else
        Tfrac = 0.6.*delta0 .* (1 - 3.8.*(theta0 - TR)./theta0);
    end
end