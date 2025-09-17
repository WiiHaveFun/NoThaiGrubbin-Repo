%% Load datapoints and image
pos = load("arrestment_points.mat").pos;

img_file = "/Users/michaelchen/UMich/Class/F25/Aero_481/Misc/arrestment.png";
img = imread(img_file);
img = img(end:-1:1, :, :);

%% Fit function
p = polyfit(pos(:, 2), pos(:, 1), 2);
save("arrestment_p.mat", "p");

%% Plot
xmin = 60;
xmax = 160;
ymin = 0;
ymax = 70000;

W = linspace(40000, 70000, 100);

figure(1);
clf;
imagesc([xmin xmax], [ymin ymax], img);
hold on;
plot(polyval(p, W), W, "-b", "LineWidth", 1);

set(gca, 'YDir', 'normal');