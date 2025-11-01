% use individual functions this is just for reference
function W_equipment = Weight_Equipment(Wo, W_fuel, M, S_cs, N_s, N_c, N_en, W_avionics, L_a,N_t)

% all units in british units, ft, ft^2, lb
% M = design maximum mach number
% S_cs = total area of control surfaces (wing+tails)
% N_s = number of flight control systems
% N_c = number of crew
%N_en = number of engines
%N_t = number of fuel tanks
%N_ci = number of crew equivalents
%K_vsh = variable wing sweep constant
%N_u = number of hydraulic utility functions (typically 5-15)
%K_mc = electrical failure constant
%R_kva = system electrical rating Kv*A, typically 110-160 for fighter and
%bombers
%L_a = electrical routing distance, generators to avionics to cockpit
%N_gen = number of generators, typically equals N_en
N_ci = 1; 
K_vsh = 1; 
N_u = 15; % high estimate
K_mc = 1.45; % high estimate
R_kva = 160; % high estimate
N_gen = N_en; 

W_flightcontrols = 36.28*M^(0.003)*S_cs^(0.489)*N_s^(0.484)*N_c^(0.127); 

W_instruments = 8.0 + 36.37*N_en^(0.676)*N_t^(0.237) + 26.4*(1+N_ci)^(1.356); 

W_hydraulics = 37.23*K_vsh*N_u^(0.664);

W_electrical = 172.2*K_mc*R_kva^(0.152)*N_c^(0.10)*L_a^(0.10)*N_gen^(0.091); 

W_furnishings = 217.6*N_c; %includes seats

W_uav = (W_avionics/2.117)^(1/0.933); %uninstalled avionics weight

W_aircon = 201.6*((W_uav + 200*N_c)/1000)^(0.735);

W_handlingGear = 3.2*10^(-4)*(Wo - 0.4*W_fuel); % 3.2e-4*W_dg

W_equipment = W_flightcontrols + W_instruments + W_hydraulics + W_electrical + W_furnishings + W_avionics + W_aircon + W_handlingGear; 

end