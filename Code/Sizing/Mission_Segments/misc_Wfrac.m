function Wfrac = misc_Wfrac(segment)
% MISC_WFRAC  Returns weight fractions for various segments.
%   Wfrac = MISC_WFRAC(segment) returns a weight fraction for a given
%   segment.

switch segment
    case "warmup"
        Wfrac = 0.99;
    case "taxi"
        Wfrac = 0.99;
    case "takeoff"
        Wfrac = 0.99;
    case "climb"
        Wfrac = 
    case "descent"
        Wfrac = 0.99;
    case "landing"
        Wfrac = 0.995;
end