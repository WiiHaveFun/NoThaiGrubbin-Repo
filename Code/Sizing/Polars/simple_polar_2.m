function polar = simple_polar_2(state, W0, S, n_tanks)
% SIMPLE_POLAR  Returns a polar struct for a symmetric drag polar
%   polar = SIMPLE_POLAR(state, n_tanks) returns a polar struct for a 
%   symmetric drag polar for a specified aircraft state.

polar.CD0 = get_CD0(W0, S);
polar.e = 0.8; % maybe 0.72
polar.CLmax = 1.0;

switch state
    case "clean"
        polar.CD0 = polar.CD0 + 0;
        polar.e = polar.e + 0;
        polar.CLmax = 1.0;
    case "half_flaps"
        polar.CD0 = polar.CD0 + 0.02;
        polar.e = polar.e - 0.05;
        polar.CLmax = 1.24;
    case "half_flaps_gear"
        polar.CD0 = polar.CD0 + 0.02 + 0.025;
        polar.e = polar.e - 0.05;
        polar.CLmax = 1.24;
    case "full_flaps"
        polar.CD0 = polar.CD0 + 0.075;
        polar.e = polar.e - 0.1;
        polar.CLmax = 1.57;
    case "full_flaps_gear"
        polar.CD0 = polar.CD0 + 0.075 + 0.025;
        polar.e = polar.e - 0.1;
        polar.CLmax = 1.57;
end

polar.CD0 = polar.CD0 + n_tanks .* (0.0007 + 0.0001);
