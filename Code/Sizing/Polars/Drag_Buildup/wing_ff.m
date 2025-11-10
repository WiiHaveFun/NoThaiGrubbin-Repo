function FF = wing_ff(xc_m, tc, M, lambda_m)
% WING_FF  Calculates the form factor of a wing, tail, strut, or pylon
%   [FF] = WING_FF(xc_m, tc, M, lambda_m)

FF = (1 + 0.6./xc_m.*tc + 100.*tc.^4) .* (1.34.*M.^0.18 .* cos(lambda_m).^0.28);
end