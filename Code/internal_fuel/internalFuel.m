fuel_needed_lb = 32274; % pounds
fuel_needed_gl = fuel_needed_lb/6.74; % gallons
fuel_needed_ft3 = fuel_needed_gl/7.48; %ft^3

external_fuel_gl = 2*480; % gallons
external_fuel_ft3 = external_fuel_gl/7.48; % ft^3

% wing fuel
lfus_wing = 6; %ft
lfus_endfuel = 17.5; %ft - limited by wingspan constraint (35/2)
ch_fus = chord_length(lfus_wing, 17.18, -0.401); %ft
ch_end = chord_length(lfus_endfuel, 17.18, -0.401); %ft
l = lfus_endfuel - lfus_wing; %ft
t = 0.04; % percentage chord (% airfoil thickness at 0.06, t < airfoil thickness for fuel purposes)
ch_used = 0.58; % percentage chord from f-35 approximate length
wing_fuel = 2*w_vt_fuel(ch_fus, ch_end, l, t, ch_used); % both wings in ft^3

% vertical tail fuel
lfus = 10; %ft 
ch_fus_vt = chord_length(0, 14.27, -0.856); %ft
ch_end_vt = chord_length(0.9*lfus, 14.27, -0.856); %ft
l_vt = 0.9*lfus; % ft (90% of vt length from f-35 approximate length)
t = 0.04; 
ch_used = 0.63; % from f-35 approximate length
vt_fuel = 2*w_vt_fuel(ch_fus_vt, ch_end_vt, l_vt, t, ch_used); 

fus_fuel_needed = fuel_needed_ft3 - external_fuel_ft3 - wing_fuel - vt_fuel; 

l_fus = 50; %ft
h_fus = 7.25; %ft
w_fus = 12; %ft
d_engine = 6; %ft diameter + engine support
l_engine = 16; %ft (just longer than the engine length)
num_engine = 2; 
per_fus = 0.5; % per f-35 spec
fus_fuel_possible = fus_fuel(l_fus, h_fus, w_fus, d_engine, l_engine, num_engine, per_fus); 

function chord_l = chord_length(lfus, coeff1, coeff2)
chord_l = coeff1 + coeff2*lfus; 
end