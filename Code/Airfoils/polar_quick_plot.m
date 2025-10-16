%% Plot options
fontsize = 10;
width = 5.5;
height = 3.5;

%% Polars
data1 = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/opt_pdr/Re_MAC/polar.csv");
data2 = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/naca_pdr/Re_MAC/polar.csv");

figure(1);
clf;
plot(data1(:, 3), data1(:, 2));
hold on;
plot(data2(:, 3), data2(:, 2));
yline(0.5547, "-k");
% yline(0.5547+0.1, "-b");
% yline(0.5547-0.1, "-b");

text(0.025, 0.5547-0.1, "Design Cruise $C_l$", "Interpreter", "latex", "FontSize", fontsize);

xlabel("$C_d$", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$C_l$", "Interpreter", "latex", "FontSize", fontsize);

grid on;

set(gca, 'TickLabelInterpreter', 'latex');
set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221,6.861111111111111,width,height]);
legend("Optimized Airfoil", "NACA 65-206", "Location", "southeast", "Interpreter", "Latex", "Fontsize", fontsize);

xlim([0, 0.04])

saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/airfoil_polar.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/airfoil_polar.png", "Resolution", 300);

% figure(2);
% clf;
% plot(data1(:, 1), data1(:, 2));
% hold on;
% plot(data2(:, 1), data2(:, 2));
% yline(0.5547, "-g");
% yline(0.5547+0.1, "-b");
% yline(0.5547-0.1, "-b");
% 
% grid on;

%% Design Cl interp

opt_cl = interp1(data1(:, 2), data1(:, 3), 0.5547);
og_cl = interp1(data2(:, 2), data2(:, 3), 0.5547);


%% Cp
data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/opt_5pt/output_4Re/airfoil_0.69_024_slices.dat");
data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/opt_5pt/output_4Re/airfoil_0.85_025_slices.dat");
% data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/opt_5pt/output_4Re/airfoil_1.00_026_slices.dat");

x = data(4:4+299, 1);
y = data(4:4+299, 2);
cp = data(4:4+299, 10);

figure(3);
scatter(x, -cp);