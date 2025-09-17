CD0 = 0.01;
K = 0.1;

WS = linspace(1,5000,200);
TW = linspace(0,1.5,200);
TW1 = turn_rate(WS, deg2rad(8), 6096, CD0, K, 0.7, 0.7);
TW2 = climb_rate(WS, 1.016, 80, 0, CD0, K, true, true, 2, 1.0, 1.0);
TW3 = climb_rate(WS, 2.54, 80, 0, CD0, K, true, false, 2, 1.0, 1.0);
TW4 = climb_rate(WS, 2.54, 80, 0, CD0, K, true, true, 2, 0.7, 1.0);
TW5 = dash(WS, 2.0, 9144, CD0, K, 0.6, 0.7);
TW6 = cruise(WS, 247, 12192, CD0, K, 0.9, 0.5);
TW7 = cruise(WS, 247, 12192, CD0, K, 0.4, 0.5);
[WS8, TW8] = catapult(WS, TW, 90000.*4.44822, CD0, K, 2, 1, 1);

WS1 = max_g(9, 300, 9144, 1.2, 0.7);
WS2 = recovery(90000.*4.44822, 1.6, 0.6);

figure(1);
clf;
plot(WS, TW1);
hold on;
plot(WS, TW2);
plot(WS, TW3);
plot(WS, TW4);
plot(WS, TW5);
plot(WS, TW6);
plot(WS, TW7);
plot(WS8, TW8);
xline(WS1);
xline(WS2, "b");
xlim([0, 5000]);
ylim([0, 1.5]);
