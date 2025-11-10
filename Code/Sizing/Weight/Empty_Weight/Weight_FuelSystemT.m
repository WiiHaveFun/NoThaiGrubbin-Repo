function W_FuelSystemT = Weight_FuelSystemT(V_t, V_i, V_p, N_t, N_en, T, SFC)

% fuel system and tanks
%V_t = total fuel volume, gal
%V_i = integral tanks volume, gal
%V_p = self-sealing "protected" tanks volume, gal
%N_t = number of fuel tanks
%N_en = number of engines
%T = total engine thrust, lb
%SFC = engine specific fuel consumption at max thrust lb/hr/lb

W_FuelSystemT = 7.45*V_t^(0.47)*(1+V_i/V_t)^(-0.095)*(1+V_p/V_t)*N_t^(0.066)*N_en^(0.052)*(T*SFC/1000)^(0.249); 

end