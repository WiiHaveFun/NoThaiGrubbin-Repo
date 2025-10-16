%% Plot options
fontsize = 10;
width = 5.5;
height = 3.5;

%% Quick plot foil
% data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/airfoil_opt/output_5pt/fc0_076_slices.dat");
data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/airfoil_opt/output_pdr/fc0_062_slices.dat");
x = data(4:4+299, 1) ./ 4.70868;
y = data(4:4+299, 2) ./ 4.70868;
cp = data(4:4+299, 10);
figure(1);
clf;
plot(x, y);
grid on

xlabel("x/c", "Interpreter", "latex", "FontSize", fontsize);
ylabel("t/c", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');
set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221,6.861111111111111,width,height])

pbaspect([10 4 1]);
axis([0, 1, -0.2, 0.2])

figure(2);
clf;
plot(x, cp);
grid on

set(gca, "YDir", "reverse");
xlabel("x/c", "Interpreter", "latex", "FontSize", fontsize);
ylabel("$c_p$", "Interpreter", "latex", "FontSize", fontsize);
set(gca, 'TickLabelInterpreter', 'latex');
set(gcf, 'Units', 'Inches', 'OuterPosition', [8.097222222222221,6.861111111111111,width,height])

saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/cp_opt.svg");

data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/airfoil_opt/output_pdr/fc0_000_slices.dat");
x = data(4:4+299, 1) ./ 4.70868;
y = data(4:4+299, 2) ./ 4.70868;
cp = data(4:4+299, 10);
% 
% hold on;
% plot(x, -cp);

figure(1);
hold on;
plot(x, y, "-");
% xline(0.0015)

% data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/airfoil_opt/output_5pt/fc0_076_slices.dat");
% x = data(4:4+299, 1);
% y = data(4:4+299, 2);
% plot(x, y, "-");

legend("Optimized Airfoil", "NACA 65-206", "Location", "southeast", "Interpreter", "latex", "Fontsize", fontsize);
saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/airfoil_opt.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/airfoil_opt.png", "Resolution", 300);

%% Airfoil animation

% Original airfoil
data_og = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/airfoil_opt/output/fc0_000_slices.dat");
x_og = data_og(4:4+299, 1);
y_og = data_og(4:4+299, 2);

% Folder containing the data
dataFolder = "/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/airfoil_opt/output/";

% Number of airfoil iterations
numFiles = 139;  % <-- change this to the total number of files you have

% Number of points per airfoil
numPoints = 299;  % same as in your example

figure(1);
clf;
hold on;
grid on;
axis equal;
xlabel('x');
ylabel('y');
title('Airfoil Iterations');

for i = 0:1:numFiles
    % Construct file name with zero-padded index
    fileName = sprintf('fc0_%03d_slices.dat', i);
    filePath = fullfile(dataFolder, fileName);
    
    % Read the data
    data = readmatrix(filePath);
    x = data(4:4+numPoints, 1);
    y = data(4:4+numPoints, 2);
    
    % Clear previous plot and plot current airfoil
    clf;
    plot(x./4.70868, y./4.70868, 'b');
    hold on;
    plot(x_og./4.70868, y_og./4.70868, 'k');
    grid on;
    pbaspect([10 2 1]);
    axis([0, 1, -0.1, 0.1])
    % axis equal;
    
    xlabel('x');
    ylabel('y');
    title(sprintf('Airfoil Iteration %03d', i));
    
    drawnow;
    pause(0.005);  % pause between frames
end

%% Get final airfoil and save

%% Save x and y to space-delimited file
MAC = 4.70868;

outputFile = "/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/opt_pdr/opt_pdr.dat";  % or .txt

data = readmatrix("/Users/michaelchen/UMich/Class/F25/Aero_481/ae481_docker/airfoil_opt/output/fc0_062_slices.dat");
x = data(4:4+299, 1) ./ MAC;
y = data(4:4+299, 2) ./ MAC;

data = [x(:), y(:)];
writematrix(data, outputFile, 'Delimiter', ' ');
