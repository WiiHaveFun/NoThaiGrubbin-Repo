%% 1 vs. 2 crew
We_crew_1 = [18589, 29000, 21495, 23000, 14330, 34800, 26455, 22478];
W0_crew_1 = [37500, 68000, 50706, 51900, 27557, 70000, 54000, 52910];
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

xlabel("W_0 (lbf)");
ylabel("W_e/W_0")
xlim([20000, 90000]);
ylim([0, 1]);
set(gca, 'XScale', 'log');
legend(["1 crew", "2 crew"]);

saveas(gcf, "crew_fit.png");

%% 1 vs. 2 engines
We_eng_1 = [18589, 14330, 15652, 34800];
W0_eng_1 = [37500, 27557, 30864, 70000];
We_eng_2 = [29000, 21495, 23000, 31700, 43735, 32081, 39462, 39021];
W0_eng_2 = [68000, 50706, 51900, 81000, 74350, 66000, 76059, 77161];

[A, C] = fit_We_W0(W0_eng_1, We_eng_1./W0_eng_1);
coeffs_eng_1 = [C, A];

[A, C] = fit_We_W0(W0_eng_2, We_eng_2./W0_eng_2, -0.0378);
coeffs_eng_2 = [C, A];

figure(2);
clf;
scatter(W0_eng_1, We_eng_1./W0_eng_1, 50, "red");
hold on;
scatter(W0_eng_2, We_eng_2./W0_eng_2, 50, "blue");

W0_in = linspace(20000, 90000, 100);
plot(W0_in, get_weight_frac(coeffs_eng_1, W0_in), "-r");
plot(W0_in, get_weight_frac(coeffs_eng_2, W0_in), "-b");

xlabel("W_0 (lbf)");
ylabel("W_e/W_0")
xlim([20000, 90000]);
ylim([0, 1]);
set(gca, 'XScale', 'log');
legend(["1 engine", "2 engine"]);

saveas(gcf, "engine_fit.png");

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
