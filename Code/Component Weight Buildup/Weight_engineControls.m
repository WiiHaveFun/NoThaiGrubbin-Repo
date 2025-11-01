function W_engineControls = Weight_engineControls(N_en, L_ec)

%N_en = number of engines 
%L_ec = routing distance from engine front to cockpit - total if
%multi-engine

W_engineControls = 10.5*N_en^(1.008)*L_ec^(0.222); 

end