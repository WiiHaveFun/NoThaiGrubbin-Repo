img_file = "/Users/michaelchen/UMich/Class/F25/Aero_481/Misc/catapult.png";
img = imread(img_file);
img = img(end:-1:1, :, :);

xmin = 50;
xmax = 190;
ymin = 0;
ymax = 100;

figure(1);
clf;
imagesc([xmin xmax], [ymin ymax], img);
hold on;

set(gca, 'YDir', 'normal');

%%
roi = drawpolyline;
pos = roi.Position;
save("catapult_points", "pos");