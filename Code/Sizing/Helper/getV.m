function V = getV(h, M)
% GETV  Calculates the velocity for an altitude and Mach number.
%   V = GETV(h, M) calculates velocity for an altitude and Mach number.

[~, a, ~, ~] = atmoscoesa(h);
V = M .* a;
end

