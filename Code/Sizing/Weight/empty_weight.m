function We = empty_weight(ac, mission_fun)


if isequal(mission_fun, @a2a_ref_Ffrac)
    W0 = ac.a2a.W0 ./ 4.44822;
    Wf = ac.a2a.Wf ./ 4.44822;
    n_z = ac.a2a.max_g;
    Wl = (ac.a2a.We + 0.25.*ac.a2a.Wf + 0.5.*ac.a2a.W_pay) ./ 4.44822;
elseif isequal(mission_fun, @strike_ref_Ffrac)
    W0 = ac.strike.W0 ./ 4.44822;
    Wf = ac.strike.Wf ./ 4.44822;
    n_z = ac.strike.max_g;
    Wl = (ac.strike.We + 0.25.*ac.strike.Wf + 0.5.*ac.strike.W_pay) ./ 4.44822;
end

% Wing weight
S = ac.initial.Sref ./ 0.092903;
AR = ac.initial.AR;
tc_r = ac.initial.tc_r;
taper = ac.initial.taper;
sweep_c4 = ac.initial.sweep_c4;
S_csw = ac.initial.S_csw ./ 0.092903;
W_wing = Weight_Wing(W0, Wf, n_z, S, AR, tc_r, taper, sweep_c4, S_csw);

fus_width_HT = ac.initial.fus_width_HT ./ 0.3048;
b_HT = ac.initial.b_HT ./ 0.3048;
S_HT = ac.initial.S_HT ./ 0.092903;
W_HT = Weight_HT(W0, Wf, n_z, fus_width_HT, b_HT, S_HT);

cant_VT = ac.initial.cant_VT;
n_z_VT = cos(cant_VT) + n_z .* sin(cant_VT); % TODO change
S_VT = ac.initial.S_VT ./ 0.092903;
L_mom_VT = ac.initial.L_mom_VT ./ 0.3048;
S_rud = ac.initial.S_rud ./ 0.092903;
AR_VT = ac.initial.AR_VT;
taper_VT = ac.initial.taper_VT;
sweep_c4_VT = ac.initial.sweep_c4_VT;
M = ac.a2a.M_dash;
W_VT = 2 .* Weight_VT(W0, Wf, n_z_VT, S_VT, M, L_mom_VT, S_rud, AR_VT, taper_VT, sweep_c4_VT);

% Fuselage weight
fus_width = ac.initial.fus_width ./ 0.3048;
fus_length = ac.initial.fus_length ./ 0.3048;
fus_depth = ac.initial.fus_depth ./ 0.3048;
W_fus = Weight_Fuselage(W0, Wf, n_z, fus_length, fus_depth, fus_width);

W_eng = ac.initial.W_eng ./ 4.44822;
N_eng = ac.initial.num_eng;
W_engsec = Weight_engineSection(W_eng, N_eng, n_z);

T_max_eng = ac.initial.T_max ./ 2 ./ 4.44822;
W_engmount = Weight_engineMounts(N_eng, T_max_eng, n_z);

L_duct = ac.initial.L_duct ./ 0.3048;
D_eng = ac.initial.D_eng ./ 0.3048;
W_duct = Weight_airInduction(L_duct, L_duct, N_eng, D_eng);

L_sh = ac.initial.L_eng ./ 0.3048;
W_cooling = Weight_cooling(D_eng, L_sh, N_eng);

L_engcon = ac.initial.L_engcon ./ 0.3048;
W_engcon = Weight_engineControls(N_eng, L_engcon);

W_starter = Weight_starterPneumatic(T_max_eng, N_eng);

L_mg = ac.gear.L_mg ./ 0.3048 .* 12;
L_ng = ac.gear.L_ng ./ 0.3048 .* 12;
N_nw = ac.gear.N_nw;
W_gear = Weight_LandingGear(Wl, L_mg, L_ng, N_nw);

S_cs = ac.initial.S_cs ./ 0.092903;
N_fcs = ac.initial.num_fcs;
N_crew = ac.initial.num_crew;
W_fcon = Weight_flightControls(M, S_cs, N_fcs, N_crew);

N_tanks = ac.initial.num_int_tanks + ac.initial.num_drop_tanks;
W_instr = Weight_Instruments(N_eng, N_tanks, N_crew);

N_util = ac.initial.num_util;
W_hydr = Weight_hydraulics(N_util);

N_gen = N_eng;
L_elec = L_engcon;
W_elec = Weight_Electrical(N_crew, L_elec, N_gen);

W_av = 2500;

W_aircon = Weight_Aircon(W_av, N_crew);

W_hand = Weight_handlingGear(W0, Wf);

V_tanks = Wf ./ ac.initial.rho_f - ac.initial.num_drop_tanks .* ac.initial.V_drop_tanks ./ 0.00378541;
N_int_tanks = ac.initial.num_int_tanks;
TSFC = ac.initial.TSFC_wet .* 3600;
W_fsys = Weight_FuelSystemT(V_tanks, 0, V_tanks, N_int_tanks, N_eng, T_max_eng.*N_eng, TSFC);

W_furn = Weight_Furnishings(N_crew);

W_ext = ac.initial.W_drop_tanks ./ 4.44822 .* ac.initial.num_drop_tanks;

We = W_wing + W_HT + W_VT + W_fus + W_engsec + W_engmount + W_duct + W_cooling + ...
     W_engcon + W_starter + W_gear + W_fcon + W_instr + W_hydr + W_elec + ...
     W_av + W_aircon + W_hand + W_fsys + W_eng.*N_eng + W_furn + W_ext;

We = We .* 4.44822;

[~, W_main, W_nose] = Weight_LandingGear(Wl, L_mg, L_ng, N_nw);
install_engine = W_engsec+W_engmount+W_cooling+W_starter+W_eng.*N_eng;
everything_else = W_duct+W_engcon+W_fcon+W_instr+W_hydr+W_elec+W_av+W_aircon+W_hand+W_fsys+W_furn+W_ext;

end