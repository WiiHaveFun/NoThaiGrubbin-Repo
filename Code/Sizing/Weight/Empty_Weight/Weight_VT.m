function W_VT = Weight_VT(Wo, W_fuel, n_z, S_vt, M, L_t, S_r, AR_vt, lambda_vt, sweep_vt)

% all units in british units,  ft, ft^2, lb

%K_rht = rolling horizontal tail coefficient
%H_t/H_v = 0 for conventional tail
%n_z = limit load
%S_vt = vertical tail area
%M = Mach number (design maximum)
%L_t = tail length (wing quarter MAC to tail quarter MAC)
%S_r = rudder area
%AR_vt = aspect ratio of vertical tail
%lambda_vt = taper ratio of vertical tail
%sweep_vt = quarter chord sweep of vertical tail (radians)

K_rht = 1.047; %raymer
H_t_H_v = 0; %raymer 
W_dg = Wo - 0.4*W_fuel; % From raymer
N_z = 1.5*n_z; % 1.5 * vertical load factor
K_comp = 0.88; %raymer advanced composites table 15.4

W_VT = K_comp*0.452*K_rht*(1+H_t_H_v)^(0.5)*(W_dg*N_z)^(0.488)*S_vt^(0.718)...
    *M^(0.341)*L_t^(-1.0)*(1+S_r/S_vt)^(0.348)*AR_vt^(0.223)*(1+lambda_vt)^(0.25)...
    *cos(sweep_vt)^(-0.323); 

end