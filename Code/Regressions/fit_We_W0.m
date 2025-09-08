function [A, C] = fit_We_W0(W0, We_W0, C_in)
% FIT_WE_WO  Fit a regression for empty weight fraction.

if exist("C_in", "var")
    C = C_in;

    x = W0.^C;
    A = We_W0 / x;
else
    p = polyfit(log(W0), log(We_W0), 1);

    C = p(1);
    A = exp(p(2));
end
end