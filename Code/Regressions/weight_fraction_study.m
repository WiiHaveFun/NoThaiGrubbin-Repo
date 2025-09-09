coeffs_raymer = [-0.13, 2.34];
coeffs_nicolai = [-0.053, 0.911];
coeffs_raymer_comp = [-0.13, 0.9.*2.34];
coeffs_nicolai_comp = [-0.053, 0.84.*0.911];

%% 1 vs. 2 crew
We_crew_1 = [18589, 29000, 21495, 23000, 14330, 34800, 26455, 22478, 29300, 43340];
W0_crew_1 = [37500, 68000, 50706, 51900, 27557, 70000, 54000, 52910, 65918, 83500];
We_crew_2 = [31700, 43735, 32081, 15652, 39462, 39021];
W0_crew_2 = [81000, 74350, 66000, 30864, 76059, 77161];

[A, C] = fit_We_W0(W0_crew_1, We_crew_1./W0_crew_1);
coeffs_crew_1 = [C, A];

[A, C] = fit_We_W0(W0_crew_2, We_crew_2./W0_crew_2);
coeffs_crew_2 = [C, A];

figure(1);
clf;
scatter(W0_crew_1, We_crew_1./W0_crew_1, 50, "red");
hold on;
scatter(W0_crew_2, We_crew_2./W0_crew_2, 50, "blue");

W0_in = linspace(20000, 90000, 100);
plot(W0_in, get_weight_frac(coeffs_crew_1, W0_in), "-r");
plot(W0_in, get_weight_frac(coeffs_crew_2, W0_in), "-b");

plot(W0_in, get_weight_frac(coeffs_raymer, W0_in), "--k");
plot(W0_in, get_weight_frac(coeffs_nicolai, W0_in), "-.k");

plot(W0_in, get_weight_frac(coeffs_raymer_comp, W0_in), "--m");
plot(W0_in, get_weight_frac(coeffs_nicolai_comp, W0_in), "-.m");

xlabel("W_0 (lbf)");
ylabel("W_e/W_0")
xlim([20000, 90000]);
ylim([0, 1]);
set(gca, 'XScale', 'log');
legend(["1 crew", "2 crew"]);

saveas(gcf, "crew_fit.png");

%% 1 vs. 2 engines
We_eng_1 = [18589, 14330, 15652, 34800, 29300];
W0_eng_1 = [37500, 27557, 30864, 70000, 65918];
We_eng_2 = [29000, 21495, 23000, 31700, 43735, 32081, 39462, 39021, 43340];
W0_eng_2 = [68000, 50706, 51900, 81000, 74350, 66000, 76059, 77161, 83500];

[A, C] = fit_We_W0(W0_eng_1, We_eng_1./W0_eng_1);
coeffs_eng_1 = [C, A];

[A, C] = fit_We_W0(W0_eng_2, We_eng_2./W0_eng_2, C);
coeffs_eng_2 = [C, A];

figure(2);
clf;
scatter(W0_eng_1, We_eng_1./W0_eng_1, 50, "red");
hold on;
scatter(W0_eng_2, We_eng_2./W0_eng_2, 50, "blue");

W0_in = linspace(20000, 90000, 100);
plot(W0_in, get_weight_frac(coeffs_eng_1, W0_in), "-r");
plot(W0_in, get_weight_frac(coeffs_eng_2, W0_in), "-b");

plot(W0_in, get_weight_frac(coeffs_raymer, W0_in), "--k");
plot(W0_in, get_weight_frac(coeffs_nicolai, W0_in), "-.k");

plot(W0_in, get_weight_frac(coeffs_raymer_comp, W0_in), "--m");
plot(W0_in, get_weight_frac(coeffs_nicolai_comp, W0_in), "-.m");

xlabel("W_0 (lbf)");
ylabel("W_e/W_0")
xlim([20000, 90000]);
ylim([0, 1]);
set(gca, 'XScale', 'log');
legend(["1 engine", "2 engine"]);

saveas(gcf, "engine_fit.png");

%% Composite vs. Non-Composite
We_comp = [29300, 21495, 43340, 23000, 32081, 34800];
W0_comp = [65918, 50706, 83500, 51900, 66000, 70000];
We_non = [18589, 29000, 31700, 43735];
W0_non = [37500, 68000, 81000, 74350];

[A, C] = fit_We_W0(W0_comp, We_comp./W0_comp, -0.053);
coeffs_comp_1 = [C, A];

[A, C] = fit_We_W0(W0_non, We_non./W0_non);
coeffs_non_2 = [C, A];

figure(1);
clf;
scatter(W0_comp, We_comp./W0_comp, 50, "red");
hold on;
scatter(W0_non, We_non./W0_non, 50, "blue");

W0_in = linspace(20000, 90000, 100);
plot(W0_in, get_weight_frac(coeffs_comp_1, W0_in), "-r");
plot(W0_in, get_weight_frac(coeffs_non_2, W0_in), "-b");

plot(W0_in, get_weight_frac(coeffs_raymer, W0_in), "--k");
plot(W0_in, get_weight_frac(coeffs_nicolai, W0_in), "-.k");

plot(W0_in, get_weight_frac(coeffs_raymer_comp, W0_in), "--m");
plot(W0_in, get_weight_frac(coeffs_nicolai_comp, W0_in), "-.m");

xlabel("W_0 (lbf)");
ylabel("W_e/W_0")
xlim([20000, 90000]);
ylim([0, 1]);
set(gca, 'XScale', 'log');
legend(["Composite", "Non-composite"]);

saveas(gcf, "composite_fit.png");

%% Composite vs. Non-Composite
We_int = [29300, 43340, 37479, 34800];
W0_int = [65918, 83500, 81571, 70000];
We_ext = [18589, 29000, 21495, 23000, 14330, 31700, 43735, 32081, 15652, 39462, 39021];
W0_ext = [37500, 68000, 50706, 51900, 27557, 81000, 74350, 66000, 30864, 76059, 77161];

[A, C] = fit_We_W0(W0_int, We_int./W0_int, -0.053);
coeffs_int = [C, A];

[A, C] = fit_We_W0(W0_ext, We_ext./W0_ext);
coeffs_ext = [C, A];

figure(1);
clf;
scatter(W0_int, We_int./W0_int, 50, "red");
hold on;
scatter(W0_ext, We_ext./W0_ext, 50, "blue");

W0_in = linspace(20000, 90000, 100);
plot(W0_in, get_weight_frac(coeffs_int, W0_in), "-r");
plot(W0_in, get_weight_frac(coeffs_ext, W0_in), "-b");

plot(W0_in, get_weight_frac(coeffs_raymer, W0_in), "--k");
plot(W0_in, get_weight_frac(coeffs_nicolai, W0_in), "-.k");

xlabel("W_0 (lbf)");
ylabel("W_e/W_0")
xlim([20000, 90000]);
ylim([0, 1]);
set(gca, 'XScale', 'log');
legend(["Internal", "External"]);

saveas(gcf, "ordinance_fit.png");

%% Fuel weight vs. Empty weight

We = [18589, 29000, 21495, 23000, 14330, 31700, 43735, 32081, 39462];
Wf = [7000, 14076, 8818.49, 11077.2, 5399.2, 13729.2, 16000, 14500, 20700];

p_fuel = polyfit(We, Wf, 1);
We_in = linspace(10000, 50000, 100);

figure(3);
clf;
scatter(We, Wf, 50);
hold on;
plot(We_in, polyval(p_fuel, We_in), "-k");

xlabel("W_e (lbf)");
ylabel("W_f (lbf)")

saveas(gcf, "fuel_fit.png");

%% Functions
function W0_We = get_weight_frac(coeffs, W0)
    W0_We = coeffs(2) .* W0 .^ coeffs(1);
end
