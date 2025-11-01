function W_HT = Weight_HT(Wo, W_fuel, n_z, F_w, B_h, S_HT)

% all units in british units,  ft, ft^2, lb

%F_w = fuselage width at horizontal tail intersection
%B_h = horizontal tail span
%S_HT = horizontal tail area
%n_z = vertical load factor
%W_fuel = fuel weight at takeoff
%Wo = takeoff weight

W_dg = Wo - 0.4*W_fuel; % From raymer
N_z = 1.5*n_z; % 1.5 * vertical load factor
K_comp = 0.88; %raymer advanced composites table 15.4

W_HT = K_comp*3.316*(1 + F_w/B_h)^(-2)*(W_dg*N_z/1000)^(0.260)*S_HT^(0.806); 

end