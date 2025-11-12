function pp = generate_cruise_spline(ac, polar)

options = optimoptions("fmincon", "Display", "none");

n = 20;
W = linspace(5000 .* 4.44822, 90000 .* 4.44822, n); % Linear spacing in weight

M = ac.initial.M_cruise;

S = ac.initial.Sref;

h = zeros(n, 1);
h_guess = 10000;
for i = 1:n
    h(i) = fmincon(@(h) -cruise_obj(h, M, W(i), S, polar), h_guess, 0, 0, [], [], [], [], [], options);
    h_guess = h(i);
end

pp = spline(W, h);

end

function obj = cruise_obj(h, M, W, S, polar)
    CD0 = polar.get_CD0(h, M);
    K = polar.get_K(M);

    [~, a, ~, rho] = atmoscoesa(h);

    V = M .* a;

    CL = 2.*W ./ (rho.*V.^2.*S);
    CD = CD0 + K .* CL.^2;

    obj = sqrt(1 ./ (rho.*S)) .* sqrt(CL) ./ CD;
end