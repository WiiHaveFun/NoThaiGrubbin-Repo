function W_engineMounts = Weight_engineMounts(N_en, T_e, n_z)

%N_en = number of engines
%T_e = maximum thrust per engine
%n_z = limit load factor

N_z = 1.5*n_z; % 1.5 * vertical load factor
K_comp_nacelle = 0.95; %raymer table 15.4 for advanced composites

W_engineMounts = K_comp_nacelle*0.013*N_en^(0.795)*(N_en*T_e)^(0.579)*N_z;

end
