function W_fuselage = Weight_Fuselage(Wo, W_fuel, n_z, L, D, width_fus)
% all units in british units,  ft, ft^2, lb

%K_dwf = constant for delta wing aircraft
% width_fus = total structural width of the fuselage
% L = structural length of fuselage, excludes radome cowling and tail cap;
% D = structural depth of fuselage; 
%n_z = vertical load factor
%W_fuel = fuel weight at takeoff
%Wo = takeoff weight

K_dwf = 1; %from raymer
W_dg = Wo - 0.4*W_fuel; % From raymer
N_z = 1.5*n_z; % 1.5 * vertical load factor
K_comp = 0.95; % from raymer 15.4 for composites
K_carrier = 1.3; % from raymer 15.4 for carrier based aircraft
W_fuselage = K_carrier*K_comp*0.499*K_dwf*W_dg^(0.35)*N_z^(0.25)*L^(0.5)*D^(0.849)*width_fus^(0.685); 

end