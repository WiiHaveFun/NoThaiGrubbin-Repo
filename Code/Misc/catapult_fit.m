%% Load datapoints and image
pos = load("catapult_points.mat").pos;

img_file = "/Users/michaelchen/UMich/Class/F25/Aero_481/Misc/catapult.png";
img = imread(img_file);
img = img(end:-1:1, :, :);

%% Fit function
p = polyfit(pos(:, 1), pos(:, 2), 3);
save("catapult_p.mat", "p");

%% Plot
xmin = 50;
xmax = 190;
ymin = 0;
ymax = 100;

V = linspace(125, 176, 100);

figure(1);
clf;
imagesc([xmin xmax], [ymin ymax], img);
hold on;
plot(V, polyval(p, V), "-b", "LineWidth", 1);

set(gca, 'YDir', 'normal');

%% Fit function
p = polyfit(pos(:, 2), pos(:, 1), 5);
save("catapult_p2.mat", "p");

%% Plot
xmin = 50;
xmax = 190;
ymin = 0;
ymax = 100;

W0 = linspace(40, 100, 100);

figure(1);
clf;
imagesc([xmin xmax], [ymin ymax], img);
hold on;
plot(polyval(p, W0), W0, "-b", "LineWidth", 1);

set(gca, 'YDir', 'normal');