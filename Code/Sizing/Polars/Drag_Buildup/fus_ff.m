function FF = fus_ff(l, Amax)
% FUS_FF  Calculates the form factor of a fuselage or a smooth canopy
%   [FF] = FUS_FF(l, Amax)

f = l ./ sqrt((4./pi).*Amax);
FF = 0.9 + 5./f.^1.5 + f./400;
end