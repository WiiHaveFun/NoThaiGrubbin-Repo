function [t_a2a_h, t_strike_h] = get_block_time(ac)
% GET_BLOCK_TIME  Calculates the block time for each mission.
%   [t_a2a, t_strike] = GET_BLOCK_TIME(ac) calculate the block
%   time for each mission (hours) and return it.

% Air-to air
t_a2a_s = 2 * (ac.a2a.R / ac.initial.V_cruise) + ac.a2a.t_combat + ac.a2a.t_loiter;
t_a2a_h = t_a2a_s / 3600;

% Strike
t_strike_s = 2 * (ac.strike.R / ac.initial.V_cruise) + ac.strike.t_combat + ac.strike.t_loiter;
t_strike_h = t_strike_s / 3600;

end