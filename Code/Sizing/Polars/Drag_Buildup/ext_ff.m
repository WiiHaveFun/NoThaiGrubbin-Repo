function FF = ext_ff(l, Amax)
% EXT_FF  Calculates the form factor of a smooth external store
%   [FF] = EXT_FF(l, Amax)

f = l ./ sqrt((4./pi).*Amax);
FF = 1 + 0.35./f;
end