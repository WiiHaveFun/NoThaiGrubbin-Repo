function W_cooling = Weight_cooling(D_e, L_sh, N_en)

%D_e = diameter of engine 
%L_sh = length of engine cooling shroud
%N_e = number of engines

W_en_cooling = 4.55*D_e*L_sh*N_en; 

W_oil_cooling = 37.82*N_en^(1.023); 

W_cooling = W_en_cooling + W_oil_cooling;

end