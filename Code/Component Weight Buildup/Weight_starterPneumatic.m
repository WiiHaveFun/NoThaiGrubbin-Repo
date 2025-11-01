function W_starterPneumatic = Weight_starterPneumatic(T_e, N_en)

%Te = thrust per engine
%N_en = number of engines

W_starterPneumatic = 0.025*T_e^(0.760)*N_en^(0.72); 

end