%use individual functions this is just for reference
function W_installedEngines = Weight_InstalledEngines(W_en, n_z, T_e, N_en, L_s, L_d, D_e, L_tp, L_sh, L_ec)
% all units in british units,  ft, ft^2, lb

%W_en = weight of individual engine
%n_z = vertical load factor
%N_en = number of engines
%T = total engine thrust (both engines combined)
%W_en = weight of singular engine
% K_d (duct constant) Figure 15.3
%L_s = single duct length, part of duct where it is not split, L_s = L_d
%for no split
%De = diameter of engine
%K_vg = constant for variable geometry
%L_d = duct length
% L_tp = tail pipe length
%L_sh = length of engine cooling shroud
%L_ec = routing distance from engine front to cockpit - total if
%multi-engine
% T_e = thrust per engine 

N_z = 1.5*n_z; % 1.5 * vertical load factor
K_comp_nacelle = 0.95; %raymer table 15.4 for advanced composites
W_engineMounts = K_comp_nacelle*0.013*N_en^(0.795)*(N_en*T_e)^(0.579)*N_z; 
W_engineSection = K_comp_nacelle*0.01*W_en^(0.717)*N_en*N_z; 

if L_s/L_d <= 0.25 % from raymer
    Ls_Ld = 0.25;
else
    Ls_Ld = L_s/L_d; 
end

K_vg = 1; 
K_d = 2.75; %from figure 15.3 in Raymer square duct seems closest
K_comp_ai = 0.90; %advanced composities Raymer 15.4
W_airinduction = K_comp_ai*13.29*K_vg*L_d^(0.643)*K_d^(0.182)*N_en^(1.498)*(Ls_Ld)^(-0.373)*D_e;

W_en_struct = W_airinduction + W_engineMounts + W_engineSection; 

W_eng = N_en*W_en; 

W_tailpipe = 3.5*D_e*L_tp*N_en; 

W_eng_cooling = 4.55*D_e*L_sh*N_en; 

W_oil_cooling = 37.82*N_en^(1.023); 

W_engine_controls = 10.5*N_en^(1.008)*L_ec^(0.222); 

W_starter_pneumatic = 0.025*T_e^(0.760)*N_en^(0.72); 

W_en_prop = W_eng + W_tailpipe + W_eng_cooling + W_oil_cooling + W_engine_controls + W_starter_pneumatic; 

W_installedEngines = W_en_prop + W_en_struct; 

end