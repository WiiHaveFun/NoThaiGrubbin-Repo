function d = get_climb_dist(angle, altitude)
% GET_CLIMB_DIST  Calculates the distance traveled during a climb segment.
%   d = GET_CLIMB_DIST(V_climb, climb_rate, angle, altitude) calculate the 
%   distance traveled during a climb segment.

d = altitude ./ tan(angle);
end

