ac = aircraft();
ac.initial.T_max = ac.initial.T_max*0.9;
ac.initial.T_mil = ac.initial.T_mil*0.9;
Wefrac_reg = empty_weight_frac_reg("Raymer");

% TODO enforce identical polars or separate polars by mission
[ac] = iterate_W0_TS(ac, Wefrac_reg, @a2a_Ffrac, ac.initial.T_max, ac.initial.Sref);
[ac] = iterate_W0_TS(ac, Wefrac_reg, @strike_Ffrac, ac.initial.T_max, ac.initial.Sref);

Wfrac_1 = 1.0;
W0 = ac.a2a.W0;
h0 = 0;
h1 = 12000;
polar = ac.polar.a2a.clean;
is_max = false;

%%
pp = generate_cruise_spline(ac, polar);

%%
h1 = get_cruise_start_h(ac, Wfrac_1, W0, h0, polar, is_max, pp)

%%
[Wfrac_2, dx] = climb_ref_Wfrac(ac, Wfrac_1, W0, h0, h1, polar, is_max);

%%
R = ac.a2a.R - dx;
[Wfrac_3, h2, h3] = cruiseclimb_Wfrac(ac, 1, W0, R, polar, pp);
