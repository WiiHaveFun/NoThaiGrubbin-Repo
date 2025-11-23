% Air-to-air mission parameter sweep
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(0,'defaultTextInterpreter','latex');
fontsize = 10;
width = 6.5;
height = 4;

%% Trade params
tic;
n = 5;
m = 5;
l = 5;
R = linspace(700, 1000, n);
t_combat = linspace(2, 4, m);
M_dash = linspace(1.6, 1.8, l);

n_span = 5;
n_AR = 5;
b = linspace(45, 60, n_span);
AR = linspace(2.7, 4, n_AR);

feasible_out = zeros(n, m, l, n_span, n_AR);
W0_out = zeros(n, m, l, n_span, n_AR);
We_out = zeros(n, m, l, n_span, n_AR);
Wf_out = zeros(n, m, l, n_span, n_AR);
cost_out = zeros(n, m, l, n_span, n_AR);

%% Run trade
parpool(5);
parfor i = 1:n
    for j = 1:m
        for k = 1:l
            for u = 1:n_span
                for v = 1:n_AR
                    ac = aircraft();
                    ac.initial.T_max = ac.initial.T_max*0.9;
                    ac.initial.T_mil = ac.initial.T_mil*0.9;
        
                    ac.a2a.R = R(i) .* 1852;
                    ac.a2a.t_combat = t_combat(j) .* 60;
                    ac.a2a.M_dash = M_dash(k);

                    ac.initial.b = b(u) .* 0.3048;
                    ac.initial.Sref = b(u).^2./AR(v) .* 0.092903;
                    ac.initial.AR = AR(v);

                    ac = init_polars(ac);

                    [ac, feasible_out(i, j, k, u, v)] = check_feasible_sizing_TS(ac);

                    W0_out(i, j, k, u, v) = ac.a2a.W0;
                    We_out(i, j, k, u, v) = ac.a2a.We;
                    Wf_out(i, j, k, u, v) = ac.a2a.Wf;

                    W0 = ac.a2a.W0 / 4.44822;
                    if W0 > 90000
                        feasible_out(i, j, k, u, v) = false;
                    end
                    cst = cost(ac);
                    cost_out(i, j, k, u, v) = cst.unit.AEP;
                end
            end
        end
    end
end

save("trade.mat", "feasible_out", "W0_out", "We_out", "Wf_out", "cost_out", "R", "t_combat", "M_dash", "b", "AR");
delete(gcp("nocreate"));
toc;

%% Post process

load("trade.mat");

[R_grid, t_grid] = ndgrid(R, t_combat);
% obj = (((R_grid - 700)./300).^1 + ((t_grid - 2)./2).^1 + ((M_dash(1)-1.6)./0.2).^1)./3 .* -log((AEP(:, :, 1)./114e6));
% obj = (((R_grid - 700)./300).^1 + ((t_grid - 2)./3).^1 + ((M_dash(1)-1.6)./0.4).^1)./3 .* (log(113e6./AEP(:, :, 1))./log(1.1));
% obj = AEP(:, :, 1);
% obj = (1 + log((114e6./AEP(:, :, 1))))
% (log((114e6./AEP(:, :, 1))))
% obj = (((R_grid - 700)./300).^1 + ((t_grid - 2)./2).^1 + ((M_dash(1)-1.6)./0.2).^1)./3 + 10.*(log((114e6./AEP(:, :, 1))));

nref = 5;
offset = 3;
R_ref = refvec(R, nref);
t_combat_ref = refvec(t_combat, nref);
M_dash_ref = refvec(M_dash, nref);

% obj = cost_out;
obj = W0_out;

figure(3);
clf;
t1 = tiledlayout(n_span, n_AR);


for i = 1:n_span
    for j = 1:n_AR
        nexttile;
        for k = 1:l
            obj_interp = interp2(R, t_combat, (obj(:, :, k, i, j))', R_ref, t_combat_ref', "makima");
            feasible_interp = interp2(R, t_combat, (feasible_out(:, :, k, i, j))', R_ref, t_combat_ref', "linear");
            
            carpet(R_ref+(k-1).*300, t_combat_ref, obj_interp./1e6, 0, nref, 'k', 'k');
            hold on;
            OC = ocontourc(R_ref+(k-1).*300, t_combat_ref, feasible_interp, 0.5*[1 1], true);
            Cconv = carpetcontourconvert(R_ref+(k-1).*300, t_combat_ref, obj_interp./1e6, 3, OC);
            h = hatchedcontours(Cconv, 'b');

            if all(feasible_out(:, :, k, i, j), "all")
                carpettext(R_ref+(k-1).*300, t_combat_ref, obj_interp./1e6, offset, 700+(k-1).*300, 4, '$All Feasible$', 0, 0.5);
            end

            if k == 1
                carpetlabel(R_ref+(k-1).*300, t_combat_ref, obj_interp./1e6, 3, nref, 1, 0, 1, 0.0 );
                carpetlabel(R_ref+(k-1).*300, t_combat_ref, obj_interp./1e6, 3, nref, 0, -1, 0, 0.0 );
            end

            title(sprintf("b = %.2f, S =  %.2f, AR = %.2f", b(i), b(i).^2./AR(j), AR(j)));
        end
    end
end

%%
figure(4);
clf;
i = 2;
j = 4;
for k = 1:l
    obj_interp = interp2(R, t_combat, (obj(:, :, k, i, j))', R_ref, t_combat_ref', "linear");
    feasible_interp = interp2(R, t_combat, (feasible_out(:, :, k, i, j))', R_ref, t_combat_ref', "linear");
    
    carpet(R_ref+(k-1).*300, t_combat_ref, obj_interp./1e6, 0, nref, 'k', 'k');
    hold on;
    OC = ocontourc(R_ref+(k-1).*300, t_combat_ref, feasible_interp, 0.5*[1 1], true);
    Cconv = carpetcontourconvert(R_ref+(k-1).*300, t_combat_ref, obj_interp./1e6, 3, OC);
    h = hatchedcontours(Cconv, 'b');

    if k == 1
        carpetlabel(R_ref+(k-1).*300, t_combat_ref, obj_interp./1e6, offset, nref, 1, 0, -50, 0.5);
        carpetlabel(R_ref+(k-1).*300, t_combat_ref, obj_interp./1e6, offset, nref, 0, -1, -75, 0.0);
    end

    title(sprintf("b = %.2f, AR = %.2f", b(i), AR(j)));
end

ylabel("Unit Cost (\$M 2025)");

carpettext(R_ref, t_combat_ref, obj_interp./1e6, offset, 750, 2.5, 'R', 0.0, -0.5);
carpettext(R_ref, t_combat_ref, obj_interp./1e6, offset, 700, 2.5, 't', -100, -2.5);

%%
figure(5);
clf;
i = 2;
j = 4;
k = 2;
obj_interp = interp2(R, t_combat, (obj(:, :, k, i, j))', R_ref, t_combat_ref', "linear");
feasible_interp = interp2(R, t_combat, (feasible_out(:, :, k, i, j))', R_ref, t_combat_ref', "linear");

carpet(R_ref, t_combat_ref, obj_interp./1e6, offset, nref, 'k', 'k');
hold on;
OC = ocontourc(R_ref, t_combat_ref, feasible_interp, 0.5*[1 1], true);
Cconv = carpetcontourconvert(R_ref, t_combat_ref, obj_interp./1e6, offset, OC);
h = hatchedcontours(Cconv, 'b');

carpetlabel(R_ref, t_combat_ref, obj_interp./1e6, offset, nref, 1, 0, 0.0, 0.25);
carpetlabel(R_ref, t_combat_ref, obj_interp./1e6, offset, nref, 0, 1, 12.5, 0.0);

title(sprintf("b = %.2f ft, AR = %.2f", b(i), AR(j)), "FontSize", fontsize);

ylabel("Unit Cost (\$M 2025)", "FontSize", fontsize);

carpettext(R_ref, t_combat_ref, obj_interp./1e6, offset, 850, 4, '$R$', 0, 0.5);
carpettext(R_ref, t_combat_ref, obj_interp./1e6, offset, 1000, 3, '$t$', 25, 0.0);

[xc, yc] = carpetconvert(R_ref, t_combat_ref, obj_interp./1e6, offset, 1000, 3);
plot(xc,yc, 'r.', 'MarkerSize', 20);

% axis([650 1050 98, 102]) % Pad them a bit.
ylim([98, 102]);

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

set(gcf, 'Renderer', 'painters');
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/carpet.pdf", "ContentType", "vector");
