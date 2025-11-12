ac = aircraft();
ac.initial.T_max = ac.initial.T_max*0.9;
ac.initial.T_mil = ac.initial.T_mil*0.9;

% TODO enforce identical polars or separate polars by mission
% [ac] = iterate_W0_TS(ac, Wefrac_reg, @a2a_Ffrac, ac.initial.T_max, ac.initial.Sref);
tic
[ac] = iterate_W0_TS_ref(ac, @a2a_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS_ref(ac, @strike_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);
toc
% [ac] = iterate_W0_TS(ac, Wefrac_reg, @strike_Ffrac, ac.initial.T_max, ac.initial.Sref);

% Wfrac_1 = 1.0;
% W0 = ac.a2a.W0;
% h0 = 0;
% h1 = 12000;
% polar = ac.polar.clean;
% is_max = false;
% 
% %%
% pp = generate_cruise_spline(ac, polar);
% 
% %%
% h1 = get_cruise_start_h(ac, Wfrac_1, W0, h0, polar, is_max, pp);
% 
% %%
% tic
% [Wfrac_2, dx] = climb_ref_Wfrac(ac, Wfrac_1, W0, h0, h1, polar, is_max)
% toc
% 
% %%
% tic
% R = ac.a2a.R - dx;
% [Wfrac_3, h2, h3] = cruiseclimb_Wfrac(ac, 1, W0, R, polar, pp)
% toc
% 
% %%
% V1 = get_best_climb_V(ac, Wfrac_1, W0, h, polar, is_max)
% [Wfrac_2, dx] = accelerate_Wfrac(ac, Wfrac_1, 75, V1, W0, 0, polar, is_max)
% 
% [~, a, ~, ~] = atmoscoesa(ac.a2a.h_dash);
% polar2 = polar;
% polar2.CD0 = polar2.CD0 .* 2;
% polar2.e = polar2.e ./ 2;
% [Wfrac_2, dx] = accelerate_Wfrac(ac, Wfrac_1, ac.initial.M_cruise.*a, ac.a2a.M_dash.*a, W0, ac.a2a.h_dash, polar2, true)
