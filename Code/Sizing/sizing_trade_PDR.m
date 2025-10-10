% Air to air sweep
S = 500:50:900;

n = 5;
m = 7;
l = 5;
M_dash = linspace(1.6, 1.8, n);
R = linspace(700, 1000, m);
t_combat = linspace(2, 4, l);

[M_dash_grid, R_grid, t_combat_grid] = meshgrid(M_dash, R, t_combat);

feasible_out = [];
W0_out = [];

for s_idx = 1:length(S)
    feasible = zeros(m, n, l);
    W0 = zeros(m, n, l);
    for i = 1:m
        for j = 1:n
            for k = 1:l
                fprintf("Mach: %0.2f, Radius: %0.2f nm, Combat Time: %0.2f min\n", M_dash_grid(i,j,k), R_grid(i,j,k), t_combat_grid(i,j,k));
                ac = aircraft;

                ac.initial.Sref = S(s_idx) .* 0.092903;
                ac.initial.AR = ac.initial.b.^2 ./ ac.initial.Sref;

                ac.a2a.M_dash = M_dash_grid(i,j,k);
                ac.a2a.R = R_grid(i,j,k) .* 1852;
                ac.a2a.t_combat = t_combat_grid(i,j,k) .* 60;

                [ac, feasible(i, j, k)] = check_feasible_sizing_TS(ac);
                W0(i, j, k) = ac.a2a.W0 ./ 4.44822;
                if W0(i, j, k) > 90000
                    feasible(i, j, k) = false;
                end
            end
        end
    end
    feasible_out = cat(4, feasible_out, feasible);
    W0_out = cat(4, W0_out, W0);
end

%% Plot

save("feasible_out_1.mat", "feasible_out");
save("W0_out_1.mat", "W0_out");

feasible_out_2 = feasible_out;
feasible_out_2(feasible_out_2 == 0) = NaN;

figure(3);
clf;
for s_idx = 1:length(S)
    feasible_out_s = feasible_out_2(:, :, :, s_idx);
    scatter3(M_dash_grid(:), R_grid(:), t_combat_grid(:), 1.*s_idx.^3, feasible_out_s(:).*s_idx);
    hold on;
end
xlabel("M dash");
ylabel("Combat radius");
zlabel("Combat time");
