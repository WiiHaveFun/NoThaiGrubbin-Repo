AR = [3.02, 4.12, 3.83, 2.45, 3.2, 2.36];
K = [0.18, 0.117, 0.15, 0.17, 0.109, 0.16];
e = 1 ./ (pi .* AR .* K);

figure(1);
clf;
scatter(AR, K);
hold on;
plot(linspace(2, 4, 100), 1 ./ (pi .* linspace(2, 4, 100) .* mean(e)));
axis equal;
