CD0 = 0.02;
K = 0.1;

WS = linspace(1,7000,200);
TW = linspace(0,1.5,200);
TW1 = turn_rate(WS, deg2rad(10), 6096, CD0, K, 0.7, 0.7);
TW2 = climb_rate(WS, 1.016, 80, 0, CD0, K, true, true, 2, 1.0, 1.0);
TW3 = climb_rate(WS, 2.54, 80, 0, CD0, K, true, false, 2, 1.0, 1.0);
TW4 = climb_rate(WS, 2.54, 80, 0, CD0, K, true, true, 2, 0.7, 1.0);
TW5 = dash(WS, 2.0, 9144, 0.02, 0.3, 0.84, 0.6);
% TW5 = dash(WS, 0.9, 0, CD0, K, 0.7, 1.0);
TW6 = cruise(WS, 247, 12192, CD0, K, 0.9, 0.29);
TW7 = cruise(WS, 247, 12192, CD0, K, 0.4, 0.29);
[WS8, TW8] = catapult(WS, TW, 90000.*4.44822, 0.1, K, 2, 1, 1);
TW9 = takeoff(WS, 1200, 0, 0.04, 1.6, 0.8, 0.25, 1.0, 1.0);
TW10 = ceiling(WS, 0.84, 15000, 0.02, 0.3, 0.7, 0.6);

WS1 = max_g(9, 300, 3048, 1.0, 0.7);
WS2 = recovery(90000.*4.44822, 1.6, 0.6);
WS3 = landing(2000, 0, 1.6, 0.8);

figure(1);
clf;
p1 = plot(WS, TW1);
hold on;
p2 = plot(WS, TW2);
p3 = plot(WS, TW3);
p4 = plot(WS, TW4);
p5 = plot(WS, TW5);
p6 = plot(WS, TW6);
p7 = plot(WS, TW7);
p8 = plot(WS8, TW8);
p9 = plot(WS, TW9);
p10 = plot(WS, TW10);
p11 = plot([WS1, WS1], [0, 1.5]);
p12 = plot([WS2, WS2], [0, 1.5], "b");
p13 = plot([WS3, WS3], [0, 1.5], "g");
xlim([0, 7000]);
ylim([0, 1.5]);

label(p1, "Turn Rate", 'slope', 'location', 'east', 'interpreter', 'latex')
label(p2, "Climb Rate", 'slope', 'location', 'east')
label(p3, "Climb Rate", 'slope', 'location', 'east')
label(p4, "Climb Rate", 'slope', 'location', 'east')
label(p5, "Dash", 'slope', 'location', 'east')
label(p6, "Cruise", 'slope', 'location', 'east')
label(p7, "Cruise", 'slope', 'location', 'east')
label(p8, "Catapult", 'slope', 'location', 'center')
label(p9, "Takeoff", 'slope', 'location', 'east')
label(p10, "Ceiling", 'slope', 'location', 'east')
label(p11, "Max g", 'slope', 'location', 'center')
label(p12, "Recovering", 'slope', 'location', 'center')
label(p13, "Landing", 'slope', 'location', 'center')
