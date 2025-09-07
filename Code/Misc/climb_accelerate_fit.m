%% Load datapoints and image
load("climb_accelerate_points.mat");

img_file = "/Users/michaelchen/UMich/Class/F25/Aero_481/Misc/climb_accelerate_Wfrac.png";
img = imread(img_file);
img = img(end:-1:1, :, :);

%% Fit function
p = polyfit(pos(:, 1), pos(:, 2), 4);
save("climb_accelerate_p.mat", "p");

%% Plot
xmin = 0.1;
xmax = 10.0;
ymin = 0.5;
ymax = 1.0;

M = linspace(0.1, 6, 100);

figure(1);
clf;
imagesc([xmin xmax], [ymin ymax], img);
hold on;
plot(M, polyval(p, M), "-k");

set(gca, 'XScale', 'log');
set(gca, 'YDir', 'normal');