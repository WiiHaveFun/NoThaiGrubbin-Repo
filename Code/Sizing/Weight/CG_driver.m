%% Plot options
set(groot, 'defaultAxesTickLabelInterpreter','latex');
set(groot, 'defaultLegendInterpreter','latex');
set(0,'defaultTextInterpreter','latex');
fontsize = 10;
width = 4;
height = 4;

%% Weights and weight fractions
ac = aircraft();
ac.initial.T_max = ac.initial.T_max*0.9;
ac.initial.T_mil = ac.initial.T_mil*0.9;

[ac] = iterate_W0_TS_ref(ac, @a2a_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS_ref(ac, @strike_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);

%% CG Excursion Plot
% A2A
W_a2a = ac.a2a.W0 .* ac.a2a.Wfracs;
Wf_a2a = ac.a2a.Wf - (ac.a2a.W0 .* (1 - ac.a2a.Wfracs));
W_a2a_drop = ac.a2a.W0 .* ac.a2a.Wfracs;
W_a2a_drop(7:end) = W_a2a_drop(7:end) - ac.a2a.W_pay;

gear_down = false(size(W_a2a));
gear_down(1) = true;
gear_down(end-1:end) = true;

pay_drop = false(size(W_a2a));
pay_drop(7:end) = true;

SM_a2a = get_sm(ac, W_a2a, Wf_a2a, gear_down, false(size(W_a2a)), true);
SM_a2a_drop = get_sm(ac, W_a2a_drop, Wf_a2a, gear_down, pay_drop, true);

% Strike
W_strike = ac.strike.W0 .* ac.strike.Wfracs;
Wf_strike = ac.strike.Wf - (ac.strike.W0 .* (1 - ac.strike.Wfracs));
W_strike_drop = ac.strike.W0 .* ac.strike.Wfracs;
W_strike_drop(7:end) = W_strike_drop(7:end) - ac.strike.W_pay;

gear_down = false(size(W_strike));
gear_down(1) = true;
gear_down(end-1:end) = true;

pay_drop = false(size(W_strike));
pay_drop(7:end) = true;

SM_strike = get_sm(ac, W_strike, Wf_strike, gear_down, false(size(W_strike)), false);
SM_strike_drop = get_sm(ac, W_strike_drop, Wf_strike, gear_down, pay_drop, false);

figure(1);
clf;
plot(SM_a2a.*100, W_a2a./4.44822, ".-k");
hold on;
plot(SM_a2a_drop.*100, W_a2a_drop./4.44822, ".--k");

boundaryline([0, 0], [3e4, 6.2e4], "FlipBoundary", "on");
boundaryline([8.924, 8.924], [3e4, 6.2e4], "FlipBoundary", "off");

text(SM_a2a(1).*100, W_a2a(1)./4.44822, "~~~Launch", "HorizontalAlignment", "left");
text(SM_a2a(2).*100, W_a2a(2)./4.44822, "~~~Gear up", "HorizontalAlignment", "left");
text(SM_a2a(6).*100, W_a2a(6)./4.44822, "~~~Combat", "HorizontalAlignment", "left");
text(SM_a2a_drop(7).*100, W_a2a_drop(7)./4.44822, "Payload used~~~", "HorizontalAlignment", "right");
text(SM_a2a_drop(end-1).*100, W_a2a_drop(end-1)./4.44822, ["Gear down~~~", "Recovery~~~"], "HorizontalAlignment", "right");

text(7, 6e4, "Air-to-Air", "HorizontalAlignment", "center");

xlim([-1, 10]);
ylim([3e4, 6.2e4]);
xlabel("\%SM");
ylabel("$W$ (lb)");

grid on;

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);
saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CG_a2a.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CG_a2a.png", "Resolution", 1000);

figure(2);
clf;
plot(SM_strike.*100, W_strike./4.44822, ".-k");
hold on;
plot(SM_strike_drop.*100, W_strike_drop./4.44822, ".--k");

text(SM_strike(1).*100, W_strike(1)./4.44822, "~~~Launch", "HorizontalAlignment", "left");
text(SM_strike(2).*100, W_strike(2)./4.44822, "~~~Gear up", "HorizontalAlignment", "left");
text(SM_strike(6).*100, W_strike(6)./4.44822, "~~~Combat", "HorizontalAlignment", "left");
text(SM_strike_drop(7).*100, W_strike_drop(7)./4.44822, "Payload used~~~", "HorizontalAlignment", "right");
text(SM_strike_drop(end-1).*100, W_strike_drop(end-1)./4.44822, ["Gear down~~~", "Recovery~~~"], "HorizontalAlignment", "right");

text(7, 6e4, "Strike");

boundaryline([0, 0], [3e4, 6.2e4], "FlipBoundary", "on");
boundaryline([8.924, 8.924], [3e4, 6.2e4], "FlipBoundary", "off");
xlim([-1, 10]);
ylim([3e4, 6.2e4]);
xlabel("\%SM");
ylabel("$W$ (lb)", "HorizontalAlignment", "center");

grid on;

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);
saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CG_strike.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CG_strike.png", "Resolution", 1000);

%% CG Loading Plot
[xcg_a2a_load, W_a2a_load] = load_SM(ac, true);
[xcg_strike_load, W_strike_load] = load_SM(ac, false);

figure(3);
clf;
idx = 5;
plot(xcg_a2a_load(idx, :)./0.3048, W_a2a_load(idx, :)./4.44822, ".-k", "LineWidth", 1);
hold on;
idx = 3;
plot(xcg_a2a_load(idx, :)./0.3048, W_a2a_load(idx, :)./4.44822, ".--k");
% plot(SM_a2a_load'.*100, W_a2a_load'./4.44822, ".--k");

idx = 5;
plot(xcg_strike_load(idx, :)./0.3048, W_strike_load(idx, :)./4.44822, ".--b");
% plot(SM_strike_load'.*100, W_strike_load'./4.44822, ".--b");
idx = 3;
% plot(SM_strike_load(idx, :).*100, W_strike_load(idx, :)./4.44822, ".-b");
plot(xcg_strike_load(idx, :)./0.3048, W_strike_load(idx, :)./4.44822, ".-b", "LineWidth", 1);

% text(xcg_a2a_load(5, 2)./0.3048, W_a2a_load(5, 2)./4.44822, "~~~~~~~~~~Most aft", "HorizontalAlignment", "left");
% text(xcg_strike_load(3, 3)./0.3048, W_strike_load(3, 3)./4.44822, "Most fore~~~~", "HorizontalAlignment", "right");
text(xcg_a2a_load(5, end)./0.3048, W_a2a_load(5, end)./4.44822, "Air-to-air", "HorizontalAlignment", "center", "VerticalAlignment", "bottom");
text(xcg_strike_load(3, end)./0.3048, W_strike_load(3, end)./4.44822, "Strike", "HorizontalAlignment", "center", "VerticalAlignment", "bottom");

boundaryline([309.68, 309.68]./12, [3e4, 6.5e4], "FlipBoundary", "on");
boundaryline([321.679, 321.679]./12, [3e4, 6.5e4], "FlipBoundary", "off");
xlim([25.6, 27]);
ylim([3e4, 6.5e4]);
xlabel("$x_{CG}$ (ft from nose)");
ylabel("$W$ (lb)", "HorizontalAlignment", "center");

grid on;

set(gcf, 'Units', 'Inches', 'Position', [8.097222222222221,6.861111111111111,width,height]);

saveas(gcf, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CG_load.svg");
exportgraphics(gca, "/Users/michaelchen/UMich/Class/F25/Aero_481/Figures/CG_load.png", "Resolution", 1000);

%% Functions
function SM = get_sm(ac, W, Wf, gear_down, pay_drop, a2a)
    % ["Empty", "Empty Gear Up", "Crew", "Wing Tanks", "V-Stab Tanks", "Fuselage Tanks", "A2A", "Strike"];

    x_cg = zeros(size(W));
    for i=1:length(W)
        [F_wing, F_VT, F_fus] = fuel_dist(Wf(i));
        if a2a
            if gear_down(i)
                x_vec = [26.10117956, 11.36666667, 27.17825, 37.54308333, 26.66325, 24.75] .* 0.3048;
            else
                x_vec = [25.92407504, 11.36666667, 27.17825, 37.54308333, 26.66325, 24.75] .* 0.3048;
            end

            if pay_drop(i)
                W_vec = [ac.a2a.We, ac.a2a.W_crew, F_wing, F_VT, F_fus, 0];
            else
                W_vec = [ac.a2a.We, ac.a2a.W_crew, F_wing, F_VT, F_fus, ac.a2a.W_pay];
            end

            x_cg(i) = sum(W_vec .* x_vec) ./ sum(W_vec);
        else
            if gear_down(i)
                x_vec = [26.10117956, 11.36666667, 27.17825, 37.54308333, 26.66325, 24.8125] .* 0.3048;
            else
                x_vec = [25.92407504, 11.36666667, 27.17825, 37.54308333, 26.66325, 24.8125] .* 0.3048;
            end

            if pay_drop(i)
                W_vec = [ac.strike.We, ac.strike.W_crew, F_wing, F_VT, F_fus, 0];
            else
                W_vec = [ac.strike.We, ac.strike.W_crew, F_wing, F_VT, F_fus, ac.strike.W_pay];
            end

            x_cg(i) = sum(W_vec .* x_vec) ./ sum(W_vec);
        end
    end

    SM = (ac.initial.sub_NP - x_cg) ./ ac.initial.MAC;
end

function [x_cg, W] = load_SM(ac, a2a)
    idx = perms([2, 3, 4]);
    idx = [ones(length(idx), 1), idx];

    if a2a
        [F_wing, F_VT, F_fus] = fuel_dist(ac.a2a.Wf);
        xF = [27.17825, 37.54308333, 26.66325] .* 0.3048;
        xCGF = sum([F_wing, F_VT, F_fus] .* xF) ./ ac.a2a.Wf;

        W = [ac.a2a.We, ac.a2a.Wf, ac.a2a.W_crew, ac.a2a.W_pay];
        x = [26.10117956, 0, 11.36666667, 24.75] .* 0.3048;
        x(2) = xCGF;
    else
        [F_wing, F_VT, F_fus] = fuel_dist(ac.strike.Wf);
        xF = [27.17825, 37.54308333, 26.66325] .* 0.3048;
        xCGF = sum([F_wing, F_VT, F_fus] .* xF) ./ ac.strike.Wf;

        W = [ac.strike.We, ac.strike.Wf, ac.strike.W_crew, ac.strike.W_pay];
        x = [26.10117956, 0, 11.36666667, 24.8125] .* 0.3048;
        x(2) = xCGF;
    end

    x_cg = cumsum(W(idx) .* x(idx), 2) ./ cumsum(W(idx), 2);
    % SM = (ac.initial.sub_NP - x_cg) ./ ac.initial.MAC;
    W = cumsum(W(idx), 2);
end


function [F_wing, F_VT, F_fus] = fuel_dist(Wf)
    Wf_max = [4648.902868, 1149.620232, 21162.08822] * 4.44822;
    if Wf < Wf_max(3)
        F_wing = 0;
        F_VT = 0;
        F_fus = Wf;
    elseif Wf >= Wf_max(3) && Wf < Wf_max(3) + Wf_max(2)
        F_wing = 0;
        F_VT = Wf - Wf_max(3);
        F_fus = Wf_max(3);
    elseif Wf >= Wf_max(1) + Wf_max(2)
        F_wing = Wf - Wf_max(2) - Wf_max(3);
        F_VT = Wf_max(2);
        F_fus = Wf_max(3);
    end
end