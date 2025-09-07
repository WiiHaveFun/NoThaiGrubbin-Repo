function Wf = combat_Wf(c, T, t)
% COMBAT_WF  Calculates the weight of fuel for a combat segment.
%   Wf = COMBAT_WF(c, T, t) calculates the combat fuel weight.

Wf = c .* T .* t;