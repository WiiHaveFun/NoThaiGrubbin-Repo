Wo = 16480; %lbs
Wdg = 16480; %lbs
n_z = 11/1.5; % ultimate load factor given, equation takes in limit load
Sw = 294.0;
M_designmax = 1.8; 
N_en = 1; 
AR = 3.5; 
t_c = 0.060; 
lambda = 0.250; 
sweep_c4 = 30; 
S_csw = 72; 

F_w = 4.7; 
Ah = 6.50; 
S_ht = 90.0; 

L_fus = 39; 
D_fus = 4; 
W_fus = 5.4; 

W_landing = 16480; 
N_l = 4; 
L_m = 46;
L_n = 52; 
N_nw = 1; 

Te = 16150.4; 
W_en = 1517; 
L_d = 10.7;
L_s = 2; 
D_e = 2.700; 

L_tp = 0; 
L_sh = 14; 
L_ec = 18.3; 
W_oil = 50; 

V_t = 703.3; 
V_i = 389;
V_p = 314.30; 
N_t = 3; 
SFC = 1.90; %at maximum thrust

S_cs = 94; 
N_s = 4; 
N_c = 1; 

N_u = 10; 
L_a = 25; 
N_gen = 1; 

W_avionics = 727.0^(0.933)*2.117;
W_crew = 220; 
W_payload = 840; 

%% test
% assume no fuel subtracted
W_wing = Weight_Wing(Wo, 0, n_z, Sw, AR, t_c, lambda, deg2rad(sweep_c4), S_csw);

B_h = sqrt(Ah*S_ht); 
W_HT = Weight_HT(Wo, 0, n_z, F_w, B_h, S_ht); %fine
W_fuselage = Weight_Fuselage(Wo, 0, n_z, L_fus, D_fus, W_fus); %fine

W_FuelSystemT = Weight_FuelSystemT(V_t, V_i, V_p, N_t, N_en, N_en*Te, SFC); %fine

W_equipment = Weight_Equipment(Wo, 0, M_designmax, S_cs, N_s, N_c, N_en, W_avionics, L_a, N_t); %fine

W_installedEngines = Weight_InstalledEngines(W_en, n_z, Te, N_en, L_s, L_d, D_e, L_tp, L_sh, L_ec); %fine

W_landingGear = Weight_LandingGear(W_landing, L_m, L_n, N_nw); %fine