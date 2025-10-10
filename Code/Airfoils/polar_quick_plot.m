%% Polars
data1 = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/opt_5pt_3mm_newcl/output_4Re/polar.csv");
data2 = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/naca65-206/output_4Re/polar4.csv");

figure(1);
clf;
plot(data1(:, 3), data1(:, 2));
hold on;
plot(data2(:, 3), data2(:, 2));
yline(0.5573, "-g");
yline(0.5573+0.1, "-b");
yline(0.5573-0.1, "-b");

grid on;

figure(2);
clf;
plot(data1(:, 1), data1(:, 2));
hold on;
plot(data2(:, 1), data2(:, 2));
yline(0.3208, "-g");
yline(0.3208+0.1, "-b");
yline(0.3208-0.1, "-b");

grid on;

%% Cp
data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/opt_5pt/output_4Re/airfoil_0.69_024_slices.dat");
data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/opt_5pt/output_4Re/airfoil_0.85_025_slices.dat");
% data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/opt_5pt/output_4Re/airfoil_1.00_026_slices.dat");

x = data(4:4+299, 1);
y = data(4:4+299, 2);
cp = data(4:4+299, 10);

figure(3);
scatter(x, -cp);