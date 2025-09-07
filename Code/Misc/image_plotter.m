img_file = "/Users/michaelchen/UMich/Class/F25/Aero_481/Misc/sub_LD.png";
img = imread(img_file);
img = img(end:-1:1, :, :);

xmin = 0;
xmax = 1;
ymin = 8;
ymax = 24;

figure(1);
clf;
imagesc([xmin xmax], [ymin ymax], img);
hold on;

set(gca, 'YDir', 'normal');

%%
roi = drawpolyline;
pos = roi.Position;
save("sub_LD_points_AR_10", "pos");