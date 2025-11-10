function [CDw, dCDwdM] = wave_cd(S, Amax, l, Ewd, M, lambda_le)
% WAVE_CD  Calculates wave drag above Mach 1.2
%   CDw = WAVE_CD(S, Amax, l, Ewd, M, lambda_le)

lambda_le = rad2deg(lambda_le);

Dq_sh = 9.*pi./2 .* (Amax./l).^2;
% Dq_w = Ewd .* (1 - 0.386.*(M - 1.2).^0.57 .* (1 - pi.*lambda_le.^0.77./100)) .* Dq_sh;
Dq_w = Ewd .* (1 - 0.2.*(M - 1).^0.57 .* (1 - pi.*lambda_le.^0.77./100)) .* Dq_sh;

CDw = Dq_w ./ S;

dCDwdM = Ewd .* -0.2.*0.57.*(M - 1).^(0.57-1) .* (1 - pi.*lambda_le.^0.77./100) .* Dq_sh ./ S;
