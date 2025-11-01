function W_hydraulics = Weight_hydraulics(N_u)

%K_vsh = variable wing sweep constant
%N_u = number of hydraulic utility functions (typically 5-15)
% N_u typically 5-15, 15 high estimate

K_vsh = 1; 
W_hydraulics = 37.23*K_vsh*N_u^(0.664);

end