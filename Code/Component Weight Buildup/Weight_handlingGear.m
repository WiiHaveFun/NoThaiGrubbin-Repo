function W_handlingGear = Weight_handlingGear(Wo, W_fuel)

%Wo is takeoff gross weight
%W_fuel is weight of fuel to esimate flight design gross weight (from
%raymer). For a conservative estimate, W_fuel can be set to zero to set
%flight design gross weight to takeoff gross weight. 

W_handlingGear = 3.2*10^(-4)*(Wo - 0.4*W_fuel); % 3.2e-4*W_dg

end