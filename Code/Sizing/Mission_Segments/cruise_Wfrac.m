function Wfrac = cruise_Wfrac(R, V, c, LD)
% CRUISE  Calculates the weight fraction for a cruise segment.
%   Wfrac = CRUISE_WFRAC(R, V, c, LD) calculates cruise weight fraction.

Wfrac = exp(-R .* c ./ (V .* LD));