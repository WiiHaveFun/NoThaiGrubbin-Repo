fuel_needed_lb = 32274; % pounds
fuel_needed_gl = fuel_needed_lb/6.74; % gallons
fuel_needed_ft3 = fuel_needed_gl/7.48; %ft^3

external_fuel_gl = 2*480; % gallons
external_fuel_ft3 = external_fuel_gl/7.48; % ft^3

% wing fuel
lfus_wing = 6; %ft
lfus_endfuel = 17; %ft - limited by wingspan constraint (slightly less)
ch_fus = 127.05/12; %ft - from CAD
ch_end = 74.306/12; % ft - from CAD
chf = chord_length(lfus_wing, 17.18, -0.401); %ft
che = chord_length(lfus_endfuel, 17.18, -0.401); %ft
l = lfus_endfuel - lfus_wing; %ft
t = 0.04; % percentage chord (% airfoil thickness at 0.06, t < airfoil thickness for fuel purposes)

wing_fuel = 2*w_vt_fuel(ch_fus, ch_end, l, t, chf, che); % both wings in ft^3

vt_fuel = 2*0.9*0.3/0.4*31536.587*0.000578704; %ft^3 from CAD (in^3 from CAD, 90% of area, 0.03/0.04 for thickness considerations) 

fus_fuel_needed = fuel_needed_ft3 - external_fuel_ft3 - wing_fuel - vt_fuel; 

function chord_l = chord_length(lfus, coeff1, coeff2)
chord_l = coeff1 + coeff2*lfus; 
end