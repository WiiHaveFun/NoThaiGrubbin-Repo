%% F-18E/F Validation, Air-to-air
clc
ac = aircraft();
ac.initial.b = 44.9 .* 0.3048;
ac.initial.AR = 3.99;
ac.a2a.W_pay = 1544 .* 4.44822;
ac.initial.T_max = 2 .* 21946 .* 4.44822;
ac.initial.TSFC_wet = 1.844 ./ 3600;
ac.initial.T_mil = 2 .* 14447 .* 4.44822;
ac.initial.TSFC_dry = 0.82 ./ 3600;
ac.initial.Sref = 500 .* 0.092903;
ac.initial.taper = 0.4;
ac.initial.sweep_c4 = deg2rad(22.3);
ac.initial.sweep_le = deg2rad(30);
ac.initial.MAC = 13.10 .* 0.3048;

ac.initial.fus_width_HT = 6 .* 0.3048;

ac.sup.Amax = 55 .* 0.092903;

ac.a2a.turn_rate = deg2rad(8);
ac.a2a.R = 475 .* 1852;
ac.a2a.M_dash = 1.6;
ac.a2a.t_combat = 2 .* 60; 

ac = init_polars(ac);

[ac] = iterate_W0_TS_ref(ac, @a2a_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);
disp(ac.a2a.W0./4.44822);

%% F-18E/F Validation, Strike
ac.strike.W_pay = 5422 .* 4.44822;
ac.strike.R = 388 .* 1852;
ac.strike.M_dash = 0.9;
ac.strike.V_dash = getV(0, ac.strike.M_dash);
ac.strike.R_combat = 100 .* 1852;
ac.strike.t_combat = ac.strike.R_combat ./ ac.strike.V_dash;

ac.initial.num_drop_tanks = 3;

ac = init_polars(ac);

[ac] = iterate_W0_TS_ref(ac, @strike_ref_Ffrac, ac.initial.T_max, ac.initial.Sref);
disp(ac.strike.W0./4.44822)