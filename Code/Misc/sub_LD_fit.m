%% Load datapoints and image
pos2 = load("sub_LD_points_AR_2.mat").pos;
pos3 = load("sub_LD_points_AR_3.mat").pos;
pos4 = load("sub_LD_points_AR_4.mat").pos;
pos6 = load("sub_LD_points_AR_6.mat").pos;
pos8 = load("sub_LD_points_AR_8.mat").pos;
pos10 = load("sub_LD_points_AR_10.mat").pos;

img_file = "/Users/michaelchen/UMich/Class/F25/Aero_481/Misc/sub_LD.png";
img = imread(img_file);
img = img(end:-1:1, :, :);

%% Fit function
p2 = polyfit(pos2(:, 1), pos2(:, 2), 2);
p3 = polyfit(pos3(:, 1), pos3(:, 2), 2);
p4 = polyfit(pos4(:, 1), pos4(:, 2), 2);
p6 = polyfit(pos6(:, 1), pos6(:, 2), 2);
p8 = polyfit(pos8(:, 1), pos8(:, 2), 2);
p10 = polyfit(pos10(:, 1), pos10(:, 2), 2);

% AR = [2, 3, 4, 6, 8, 10];
% p = [p2; p3; p4; p6; p8; p10];
AR = [2, 3, 4];
p = [p2; p3; p4];
sub_LD_coeffs = p' / [AR; ones(size(AR))];
save("sub_LD_coeffs.mat", "sub_LD_coeffs");

%% Plot
xmin = 0;
xmax = 1;
ymin = 8;
ymax = 24;

M = linspace(0.0, 6, 100);

p_fit = sub_LD_coeffs * [AR; ones(size(AR))];

figure(1);
clf;
imagesc([xmin xmax], [ymin ymax], img);
hold on;
plot(M, polyval(p_fit(:, 1), M), "-k", "LineWidth", 1);
plot(M, polyval(p_fit(:, 2), M), "-k", "LineWidth", 1);
plot(M, polyval(p_fit(:, 3), M), "-k", "LineWidth", 1);
% plot(M, polyval(p_fit(:, 4), M), "-k", "LineWidth", 1);
% plot(M, polyval(p_fit(:, 5), M), "-k", "LineWidth", 1);
% plot(M, polyval(p_fit(:, 6), M), "-k", "LineWidth", 1);

set(gca, 'YDir', 'normal');