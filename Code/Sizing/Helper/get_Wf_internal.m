function Wf_internal = get_Wf_internal(We)
% GET_WF_INTERNAL  Predicts the internal fuel weight from empty weight.
%   Wf_internal = GET_WF_INTERNAL(We) predicts the internal fuel weight
%   from empty weight.

p = [0.4562, -476.5110];
Wf_internal = polyval(p, We ./ 4.44822) .* 4.44822;
end
