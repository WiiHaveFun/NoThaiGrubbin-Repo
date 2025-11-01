function W_engineSection = Weight_engineSection(W_en, N_en, n_z)

%W_en = weight of individual engine
%N_en = number of engines
%n_z = limit load factor

N_z = 1.5*n_z; % 1.5 * vertical load factor
K_comp_nacelle = 0.95; %raymer table 15.4 for advanced composites

W_engineSection = K_comp_nacelle*0.01*W_en^(0.717)*N_en*N_z; 

end
