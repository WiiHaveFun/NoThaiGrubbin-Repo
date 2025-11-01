function W_electrical= Weight_Electrical(N_c, L_a, N_en)

%K_mc = electrical failure constant
%R_kva = system electrical rating Kv*A, typically 110-160 for fighter and
%bombers
%L_a = electrical routing distance, generators to avionics to cockpit
%N_gen = number of generators, typically equals N_en

K_mc = 1.45; % high estimate
R_kva = 160; % high estimate
N_gen = N_en; 

W_electrical = 172.2*K_mc*R_kva^(0.152)*N_c^(0.10)*L_a^(0.10)*N_gen^(0.091); 

end