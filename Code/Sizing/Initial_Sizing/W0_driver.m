%% Plot options
fontsize = 10;
width = 5;
height = 3;

%%

ac = aircraft();

n = 15;
a2a_R = linspace(700, 1000, n) .* 1852; 
a2a_t_combat = linspace(2, 5, n) .* 60;

[a2a_R, a2a_t_combat] = meshgrid(a2a_R, a2a_t_combat);

W0 = zeros(n);

% Wfrac_reg.A = 0.8570 .* 0.224809.^-0.0557;
% Wfrac_reg.C = -0.0557;

Wfrac_reg.A = 2.3400 .* 0.224809.^-0.1300;
Wfrac_reg.C = -0.1300;

for i = 1:n
    for j = 1:n
        ac.a2a.R = a2a_R(i, j);
        ac.a2a.t_combat = a2a_t_combat(i, j);
        [ac] = iterate_W0(ac, Wfrac_reg, @a2a_Ffrac);
        W0(i, j) = ac.a2a.W0;
    end
end

%%

figure(1);
clf;
contour(a2a_R./1852, a2a_t_combat./60, W0./4.44822, 4e4:1e4:15e4, "-k", "ShowText", "on");

grid on;

xlabel("Combat radius (nm)", "Interpreter", "latex", "FontSize", fontsize);
ylabel("Combat time (min)", "Interpreter", "latex", "FontSize", fontsize);

set(gca, 'TickLabelInterpreter', 'latex');
set(gcf, "Units", "Inches", "Position", [9.5 6 width height]);

text(750, 2.8, "$W_0$", "Interpreter", "latex", "FontSize", fontsize)

set(gcf, 'PaperUnits', 'inches', 'PaperPosition', [0 0 width height]);
saveas(gcf, "a2a_weight.svg");

%%
clc
ac = aircraft();

% Wfrac_reg.A = 0.8570 .* 0.224809.^-0.0557;
% Wfrac_reg.C = -0.0557;

% Wfrac_reg.A = 2.3400 .* 0.224809.^-0.1300;
% Wfrac_reg.C = -0.1300;

Wefrac_reg = empty_weight_frac_reg("Raymer");

[ac] = iterate_W0(ac, Wefrac_reg, @a2a_Ffrac);
disp(ac.a2a.W0./4.44822);
% disp(ac.a2a.Wfracs);
% disp(ac.a2a.segments);

[ac] = iterate_W0(ac, Wefrac_reg, @strike_Ffrac);
disp(ac.strike.W0./4.44822);
% disp(ac.strike.Wfracs);
% disp(ac.strike.segments);

%%
clc
ac = aircraft();

T0 = ac.initial.T_max;
S = 957 .* 0.092903;
[ac] = iterate_W0_TS(ac, Wefrac_reg, @a2a_Ffrac, T0, S);
disp(ac.a2a.W0./4.44822);
disp(ac.a2a.We./4.44822);
disp(ac.polar.clean);