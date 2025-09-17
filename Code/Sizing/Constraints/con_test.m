WS = linspace(1,5000,100);
TW1 = turn_rate(WS, deg2rad(10), 0, 0.01, 0.1, 0.7, 0.7);
TW2 = climb_rate(WS, 1.016, 80, 0, 0.01, 0.1, false, true, 2, 1.0, 1.0);
TW3 = dash(WS, 2.0, 9144, 0.01, 0.1, 0.6, 0.7);

WS1 = max_g(9, 300, 9144, 1.2, 0.7);

figure(1);
clf;
plot(WS, TW1);
hold on;
plot(WS, TW2);
plot(WS, TW3);
xline(WS1);
ylim([0, 1.5]);