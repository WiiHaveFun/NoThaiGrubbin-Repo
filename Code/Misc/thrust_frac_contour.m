h = linspace(0, 15000, 100);
M = linspace(0, 2, 100);

[M, h] = meshgrid(M, h);

[T, ~, P, ~] = atmoscoesa(h);
[Tstd, ~, Pstd, ~] = atmoscoesa(0);


theta = T ./ Tstd;
delta = P ./ Pstd;

g = 1.4;
theta0 = theta.*(1 + (g-1)./2.*M.^2);
delta0 = delta.*(1 + (g-1)./2.*M.^2).^(g./(g-1));

TR = 1.08;

alpha_max = zeros(size(h));
alpha_max(theta0 <= TR) = delta0(theta0 <= TR);
alpha_max(theta0 > TR) = delta0(theta0 > TR) .* (1 - 3.5.*(theta0(theta0 > TR) - TR)./theta0(theta0 > TR));

alpha_mil = zeros(size(h));
alpha_mil(theta0 <= TR) = 0.6.*delta0(theta0 <= TR);
alpha_mil(theta0 > TR) = 0.6.*delta0(theta0 > TR) .* (1 - 3.8.*(theta0(theta0 > TR) - TR)./theta0(theta0 > TR));

figure(1);
clf;
contour(M, h, alpha_mil, linspace(0, 2.0, 21), "-k", "ShowText", "on");
hold on;
contour(M, h, alpha_max, linspace(0, 2.0, 21), "-b", "ShowText", "on")