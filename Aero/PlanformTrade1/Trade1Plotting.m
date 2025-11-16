clear; close all; clc;

% Data
taper = [0.27 0.28 0.29 0.3 0.31 0.32];
sweep = [26 27 28 29 30 31];
LD = [
    13.97298415 13.97934445 13.98496153 13.98614150 13.98591101 13.98503784;
    13.98073204 13.98815756 13.99155799 13.99277437 13.99261426 13.99177554;
    13.98721870 13.99352136 13.99681844 13.99792977 13.99766357 13.99675361;
    13.99004086 13.99627544 13.99950315 14.00171045 14.00059596 13.99986229;
    13.98242363 13.98893364 13.99244034 13.99376278 13.99367325 13.99294031;
    13.98351634 13.99016850 13.99378172 13.99521035 13.99526204 13.99459955
];

% Plot 2D heatmap
figure;
surf(sweep, taper, LD, 'EdgeColor', 'none');   % no grid lines
view(2);                                       % top-down view
colormap(turbo);
colorbar;

% Labels and formatting
xlabel('$\Delta_{c/4}$ (deg)', 'Interpreter', 'latex', 'FontSize', 10);
ylabel('$\lambda$', 'Interpreter', 'latex', 'FontSize', 10);
title('L/D vs Sweep and Taper Ratio', 'Interpreter', 'latex', 'FontSize', 10);

% Figure size
set(gcf, 'Units', 'inches', 'Position', [2 2 6.5 3.5]);
%shading interp; 