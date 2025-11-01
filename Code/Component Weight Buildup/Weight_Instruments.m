function W_instruments = Weight_Instruments(N_en, N_t, N_ci)

%N_en = number of engines
%N_t = number of fuel tanks
%N_ci = number of crew equivalents

W_instruments = 8.0 + 36.37*N_en^(0.676)*N_t^(0.237) + 26.4*(1+N_ci)^(1.356); 

end