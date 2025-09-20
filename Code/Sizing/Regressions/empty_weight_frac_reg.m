function Wefrac_reg = empty_weight_frac_reg(regression)
% EMPTY_WEIGHT_FRAC_REG  Returns the empty weight fraction regression struct.
%   Wefrac_reg = EMPTY_WEIGHT_FRAC_REG(regression)

switch regression
    case "Raymer"
        Wefrac_reg.A = 2.3400 .* 0.224809.^-0.1300;
        Wefrac_reg.C = -0.1300;
end