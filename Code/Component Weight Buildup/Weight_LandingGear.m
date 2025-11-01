function W_landingGear = Weight_LandingGear(W_L, L_m, L_n, N_nw)

% all units in british units
%W_l = gross landing weight (aircraft)
%K_cb = cross beam gear constant
%K_tpg = tripod landing gear constant
%N_L = ultimate landing load factor
%N_gear = gear load factor
%L_m = extended length of main landing gear in INCHES
%L_n = extended nose gear length in INCHES
%N_nw = number of nose wheels
K_cb = 1.0; 
K_tpg = 1; 
N_gear = 4; %5-6 from raymer table 11.5
N_L = 1.5*N_gear; 

W_mainLG = K_cb*K_tpg*(W_L*N_L)^(0.25)*L_m^(0.973); 

W_NLG = (W_L*N_L)^(0.290)*L_n^(0.5)*N_nw^(0.973); 

K_carrier = 1.3; % raymer 15.4 carrier based
K_comp = 1; % raymer 15.4 advanced composites

W_landingGear = K_comp*K_carrier*(W_mainLG + W_NLG); 

end