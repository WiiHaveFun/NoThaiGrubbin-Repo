function Wfrac = climb_acc_Wfrac(Mi, Mf)
% CLIMB_ACC_WFRAC  Calculates the weight fraction for climb or acceleration 
% segment.
%   Wfrac = CLIMB_ACC_WFRAC(Mi, Mf) calculates climb or acceleration weight
%   fraction.

load("climb_accelerate_p.mat", "p");
Wfrac_Mi = polyval(p, Mi);
Wfrac_Mf = polyval(p, Mf);
Wfrac = Wfrac_Mf ./ Wfrac_Mi;