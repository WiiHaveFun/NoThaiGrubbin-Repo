function ac = init_polars(ac)

% Refined polars (initialization)
ac.polar.clean = drag_polar(ac, ...                 % Fuel tanks only if present for all polars
                            "no", false, true, false);  
ac.polar.catapult = drag_polar(ac, ...              % Full flaps
                            "full", true, true, false);  
ac.polar.catapult_nogear = drag_polar(ac, ...              % Full flaps, gear deployed
                            "full", false, true, false);  
ac.polar.approach = drag_polar(ac, ...              % Half flaps, gear deployed, hook deployed
                            "half", true, true, true);  
ac.polar.approach_nogear = drag_polar(ac, ...              % Half flaps, hook deployed
                            "half", false, true, true);  
ac.polar.takeoff = drag_polar(ac, ...               % Half flaps, gear deployed
                            "half", true, true, false);  
ac.polar.takeoff_nogear = drag_polar(ac, ...               % Half flaps
                            "half", false, true, false);  
ac.polar.landing = drag_polar(ac, ...               % Full flaps, gear deployed
                            "full", true, true, false);  
ac.polar.landing_nogear = drag_polar(ac, ...               % Full flaps
                            "full", false, true, false);    
% Cruise spline
ac.polar.cruise_pp = generate_cruise_spline(ac, ac.polar.clean);
end