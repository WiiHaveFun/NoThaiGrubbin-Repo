function W_wing = Weight_Wing(Wo, W_fuel, n_z, Sw, AR, tc_r, lambda, sweep_c4, S_csw)

% all units in british units, ft, ft^2, lb

%K_dw = constant for delta wing
%K_vs = constant for variable sweep
%W_dg = flight design gross weight, lb - 50-60% of internal fuel for
%military aircraft
%W_fuel = fuel weight at takeoff
%Wo = takeoff weight
%n_z = vertical load factor
%Sw = trapezoidal wing area
%AR = aspect ratio
%tc_r = thickness to chord ratio at root
%lambda = taper ratio
%sweep_c4 = sweep at quarter chord IN RADIANS
%S_csw = control surface area (wing-mounted, includes flaps)

W_dg = Wo - 0.4*W_fuel; % from raymer
K_dw = 1; % from raymer
K_vs = 1; % from raymer
N_z = 1.5*n_z; % 1.5 * vertical load factor
K_comp = 0.90; %raymer advanced composites table 15.4

W_wing = K_comp*0.0103*K_dw*K_vs*(W_dg*N_z)^(0.5)...
    *Sw^(0.622)*AR^(0.785)*(tc_r)^(-0.4)*(1+lambda)^(0.05)...
    *cos(sweep_c4)^(-1)*S_csw^(0.04); 

end