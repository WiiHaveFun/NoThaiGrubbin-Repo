function W_flightcontrols = Weight_flightControls(M, S_cs, N_s,N_c)

% M = design maximum mach number
% S_cs = total area of control surfaces (wing+tails)
% N_s = number of flight control systems
% N_c = number of crew

W_flightcontrols = 36.28*M^(0.003)*S_cs^(0.489)*N_s^(0.484)*N_c^(0.127); %flight controls

end