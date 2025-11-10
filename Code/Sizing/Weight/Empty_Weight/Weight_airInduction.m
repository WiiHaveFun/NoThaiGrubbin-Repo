function W_airInduction = Weight_airInduction(L_s, L_d, N_en, D_e)

% K_d (duct constant) Figure 15.3 raymer
% L_s = single duct length, part of duct where it is not split, L_s = L_d
%for no split
%De = diameter of engine
%K_vg = constant for variable geometry
%L_d = duct length
%N_en = number of engines

if L_s/L_d <= 0.25 % from raymer
    Ls_Ld = 0.25;
else
    Ls_Ld = L_s/L_d; 
end

K_vg = 1; 
K_d = 2.75; %from figure 15.3 in Raymer square duct seems closest
K_comp_ai = 0.90; %advanced composities Raymer 15.4
W_airInduction = K_comp_ai*13.29*K_vg*L_d^(0.643)*K_d^(0.182)*N_en^(1.498)*(Ls_Ld)^(-0.373)*D_e;

end