function Wfrac = loiter_Wfrac(E, c, LD)
% LOITER_WFRAC  Calculates the weight fraction for a loiter segment.
%   Wfrac = LOITER_Wfrac(E, c, LD) calculates loiter weight fraction.

Wfrac = exp(-E .* c ./ LD);