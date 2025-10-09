function fuel_vol = w_vt_fuel(ch_fus, ch_end, l, t, ch_used)
% W_VT_FUEL calculates the amount of fuel that can be put into
% the wings or vertical stabilizer. Both volumes are estimated by a
% trapezoid multiplied by a thickness. 

% ch_fus is the length of the chord where the fuselage ends and the wing
% starts
% ch_end is the chord length at the point of the wing where fuel can no
% longer be put in terms of chord length 
% l is the length of the wing that can be used
%t is the thickness in terms of chord (i.e t*c = 0.06*c)
%ch_used is the length of chord that can be used to store fuel (less than 1
%due to control surfaces) in terms of chord (i.e ch_used*ch = 0.5*ch)

% fuel_vol returns the amount of fuel in 1 vertical tail or 1/2 of the
% total wing


fuel_vol = (ch_used*(ch_fus+ch_end)/2)^2*l*t; %estimate as a trapezoidal prism 

end

