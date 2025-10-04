function mu = sutherlands(T)
    T0  = 288.15;
    mu0 = 1.789e-5;
    S   = 110;
    mu = mu0 .* (T./T0).^(3/2) .* (T0 + S)./(T + S);
end