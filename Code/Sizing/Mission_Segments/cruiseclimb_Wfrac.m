function [Wfrac_2, h1, h2] = cruiseclimb_Wfrac(ac, Wfrac_1, W0, R, polar, pp)



n = 100; % Number of subsegments
dR = R ./ n;

M = ac.initial.M_cruise;

S = ac.initial.Sref;

CD0 = polar.CD0;
K = 1 ./ (pi .* ac.initial.AR .* polar.e);

c = ac.initial.TSFC_dry;

% Loop over subsegments
Wfrac_2 = 1;
for i = 1:n
    % Convert weight to cruise climb start value
    W_i = W0 .* Wfrac_1;
    % Convert weight to subsegment start value
    W_i = W_i .* Wfrac_2;

    % Get optimal cruise altitude and atmosphereic condition for current
    % weight
    h = ppval(pp, W_i);
    [~, a, ~, rho] = atmoscoesa(h);
    V = M .* a;

    % Calculate aero coefficients
    CL = 2.*W_i ./ (rho.*V.^2.*S);
    CD = CD0 + K .* CL.^2;

    % Calculate weight at end of subsegment
    W_ip1 = (-dR ./ (2./c .* sqrt(2 ./ (rho.*S)) .* sqrt(CL) ./ CD) + sqrt(W_i)).^2;

    % New weight fraction for cruise climb segment
    Wfrac_2 = Wfrac_2 .* (W_ip1 ./ W_i);

    % Store initial altitude
    if i == 1
        h1 = h;
    end
end
% Store final altitude
h2 = h;
end