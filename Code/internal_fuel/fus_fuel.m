function fuel_vol = fus_fuel(l_fus, h_fus, w_fus, d_engine, l_engine, num_engine, per_fus)
%FUS_FUEL calculates an estimate of fuel volume possible based on fuselage
%parameters
% overestimates signifigantly
% l,h,and w_fus are the dimensions of the fuselage
% d and l engine are the diameter and length of the engine
% num_engine is the number of engines
% per_fus is the percentage of the fuselage length that includes fuel 

v_tot = (per_fus*l_fus)*h_fus*w_fus; %approximate as a rectangular prism 

v_eng = num_engine*pi*(d_engine/2)^2*l_engine; % approximate as a cylinder

fuel_vol_all = 0.5*(v_tot - v_eng); % from f-35, fuel is only in top half of fuselage

fuel_vol = 0.8*fuel_vol_all; % from f-35 and raymer - about 80% of space left is available for fuel
end