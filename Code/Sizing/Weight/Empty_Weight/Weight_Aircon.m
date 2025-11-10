function W_Aircon = Weight_Aircon(W_avionics, N_c)

%N_c = number of crew
%W_avionics = installed weight of avionics given by RFP

W_uav = (W_avionics/2.117)^(1/0.933); %uninstalled avionics weight

W_Aircon = 201.6*((W_uav + 200*N_c)/1000)^(0.735);
end