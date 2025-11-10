function [Ffrac, Wfracs, segments] = strike_ref_Ffrac(ac)
% STRIKE_REF_FFRAC  Calculates the fuel fraction for a strike mission.

segments = "takeoff";
Wfrac = 1;
Wfracs = Wfrac;

% Warmup, taxi, and takeoff
Wfrac = misc_Wfrac("warmup");
% Wfrac = Wfrac .* misc_Wfrac("taxi");
Wfrac = Wfrac .* misc_Wfrac("takeoff");

% Climb and accelerate
segments = [segments, "climb_1"];
Wfracs = [Wfracs, Wfrac];
h1 = get_cruise_start_h(ac, Wfrac, ac.strike.W0, 0, ac.polar.strike.clean, false, ac.strike.cruise_pp);
[Wfrac_climb, d_climb] = climb_ref_Wfrac(ac, Wfrac, ac.strike.W0, 0, h1, ac.polar.strike.clean, false);
Wfrac = Wfrac .* Wfrac_climb;

% Cruise climb to combat
segments = [segments, "cruise_1"];
Wfracs = [Wfracs, Wfrac];
[Wfrac_cruise, ~, ~] = cruiseclimb_Wfrac(ac, Wfrac, ac.strike.W0, ac.strike.R - d_climb, ac.polar.strike.clean, ac.strike.cruise_pp);
Wfrac = Wfrac .* Wfrac_cruise;

% Descent to combat
segments = [segments, "descent_1"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* misc_Wfrac("descent");

% Combat acceleration
segments = [segments, "dash"];
Wfracs = [Wfracs, Wfrac];
if ac.initial.M_cruise < ac.strike.M_dash
    Wfrac = Wfrac .* climb_acc_Wfrac(ac.initial.M_cruise, ac.strike.M_dash);
end

% Combat
segments = [segments, "combat"];
Wfracs = [Wfracs, Wfrac];
Wf_combat = combat_Wf(ac.initial.TSFC_dry, ac.initial.T_mil, ac.strike.t_combat);
Wfrac = Wfrac .* (1 - Wf_combat ./ (Wfrac .* ac.strike.W0));

% Climb and accelerate
segments = [segments, "climb_2"];
Wfracs = [Wfracs, Wfrac];
h1 = get_cruise_start_h(ac, Wfrac, ac.strike.W0, ac.strike.h_combat, ac.polar.strike.clean, false, ac.strike.cruise_pp);
[Wfrac_climb, d_climb] = climb_ref_Wfrac(ac, Wfrac, ac.strike.W0, ac.strike.h_combat, h1, ac.polar.strike.clean, false);
Wfrac = Wfrac .* Wfrac_climb;

% Cruise climb back
segments = [segments, "cruise_2"];
Wfracs = [Wfracs, Wfrac];
[Wfrac_cruise, ~, ~] = cruiseclimb_Wfrac(ac, Wfrac, ac.strike.W0, ac.strike.R - d_climb, ac.polar.strike.clean, ac.strike.cruise_pp);
Wfrac = Wfrac .* Wfrac_cruise;

% Descent to loiter
segments = [segments, "descent_2"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* misc_Wfrac("descent");

% Loiter
segments = [segments, "loiter_1"];
Wfracs = [Wfracs, Wfrac];
LDmax = 0.5 * sqrt(pi .* ac.initial.AR .* ac.polar.strike.clean.e ./ ac.polar.strike.clean.CD0);
Wfrac = Wfrac .* loiter_Wfrac(ac.strike.t_loiter, ac.initial.TSFC_dry, LDmax);

% First landing attempt
segments = [segments, "landing_1"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* misc_Wfrac("landing");

% Second landing attempt
segments = [segments, "climb_3"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* climb_acc_Wfrac(0.0, ac.initial.M_loiter);
segments = [segments, "landing_2"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* misc_Wfrac("landing");

% Mission fuel
Wf_mission = (1 - Wfrac) .* ac.strike.W0;

% Reserve fuel
Wfrac_loiter_reserve = loiter_Wfrac(ac.strike.t_loiter, ac.initial.TSFC_dry, LDmax);
Wf_loiter_reserve = (1 - Wfrac_loiter_reserve) .* (ac.strike.W0 - Wf_mission);
Wf_reserve = Wf_loiter_reserve + 0.05 .* Wf_mission;

% Trapped fuel
Wf_trapped = 0.01 .* Wf_mission;

% Total fuel
Wf = Wf_mission + Wf_reserve + Wf_trapped;

% Fuel fraction
Ffrac = Wf ./ ac.strike.W0;
end
