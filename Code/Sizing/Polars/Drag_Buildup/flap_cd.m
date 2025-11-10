function CDflap = flap_cd(Fflap, CfC, SfS, dflap)
% FLAP_CD  Calculates the drag coefficient of a flap
%   [CDflap] = FLAP_CD(Fflap, CfC, SfS, dflap)

CDflap = Fflap .* CfC .* SfS .* (dflap - 10);
end