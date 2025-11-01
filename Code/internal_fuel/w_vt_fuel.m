function fuel_vol = w_vt_fuel(ch_fus, ch_end, l, t, chf, che)
% W_VT_FUEL calculates the amount of fuel that can be put into
% the wings or vertical stabilizer. Both volumes are estimated by a
% trapezoid multiplied by a thickness. 

%ch_fus and ch_end are the lengths of chord being used for the trapezoid
% l is the length of the wing that can be used
%t is the thickness in terms of chord (i.e t*c = 0.06*c)
%ch_used is the length of chord that can be used to store fuel (less than 1
%due to control surfaces) in terms of chord (i.e ch_used*ch = 0.5*ch)
% chf is the length of the chord where the fuselage ends and the wing
% starts
% che is the chord length at the point of the wing where fuel can no
% longer be put in terms of chord length 

% fuel_vol returns the amount of fuel in 1 vertical tail or 1/2 of the
% total wing

fuel_vol = ((ch_fus+ch_end)/2)*l*t*((chf+che)/2); %estimate as a trapezoidal prism 

end

