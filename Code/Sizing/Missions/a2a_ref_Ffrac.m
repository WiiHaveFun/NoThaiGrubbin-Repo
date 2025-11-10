function [Ffrac, Wfracs, segments] = a2a_ref_Ffrac(ac)
% A2A_REF_FFRAC  Calculates the fuel fraction for an air-to-air mission and
% mission segment weight fractions.
%    [Ffrac, Wfrac, segments] = A2A_REF_FFRAC(ac)  returns the mission fuel
%    fraction, mission segment weight fractions, and the mission segments.

segments = "takeoff";
Wfrac = 1;
Wfracs = Wfrac;

% p_clean = simple_polar("clean", 2);

% Warmup, taxi, and takeoff
Wfrac = Wfrac .* misc_Wfrac("warmup");
% Wfrac = Wfrac .* misc_Wfrac("taxi"); % Ignore taxi for now
Wfrac = Wfrac .* misc_Wfrac("takeoff");

% Climb and accelerate
segments = [segments, "climb_1"];
Wfracs = [Wfracs, Wfrac];
h1 = get_cruise_start_h(ac, Wfrac, ac.a2a.W0, 0, ac.polar.a2a.clean, false, ac.a2a.cruise_pp);
[Wfrac_climb, d_climb] = climb_ref_Wfrac(ac, Wfrac, ac.a2a.W0, 0, h1, ac.polar.a2a.clean, false);
Wfrac = Wfrac .* Wfrac_climb;

% Cruise climb to combat
segments = [segments, "cruise_1"];
Wfracs = [Wfracs, Wfrac];
[Wfrac_cruise, ~, ~] = cruiseclimb_Wfrac(ac, Wfrac, ac.a2a.W0, ac.a2a.R - d_climb, ac.polar.a2a.clean, ac.a2a.cruise_pp);
Wfrac = Wfrac .* Wfrac_cruise;

% Combat acceleration
segments = [segments, "dash"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* climb_acc_Wfrac(ac.initial.M_cruise, ac.a2a.M_dash);

% Descent to combat (No fuel burned during descent, no distance gained)
segments = [segments, "descent_1"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* misc_Wfrac("descent");

% Combat
segments = [segments, "combat"];
Wfracs = [Wfracs, Wfrac];
Wf_combat = combat_Wf(ac.initial.TSFC_wet, ac.initial.T_max, ac.a2a.t_combat);
Wfrac = Wfrac .* (1 - Wf_combat ./ (Wfrac .* ac.a2a.W0));

% Climb and accelerate
segments = [segments, "climb_2"];
Wfracs = [Wfracs, Wfrac];
h1 = get_cruise_start_h(ac, Wfrac, ac.a2a.W0, ac.a2a.h_combat, ac.polar.a2a.clean, false, ac.a2a.cruise_pp);
[Wfrac_climb, d_climb] = climb_ref_Wfrac(ac, Wfrac, ac.a2a.W0, ac.a2a.h_combat, h1, ac.polar.a2a.clean, false);
Wfrac = Wfrac .* Wfrac_climb;

% Cruise climb back
segments = [segments, "cruise_2"];
Wfracs = [Wfracs, Wfrac];
[Wfrac_cruise, ~, ~] = cruiseclimb_Wfrac(ac, Wfrac, ac.a2a.W0, ac.a2a.R - d_climb, ac.polar.a2a.clean, ac.a2a.cruise_pp);
Wfrac = Wfrac .* Wfrac_cruise;

% Descent to loiter (No fuel burned during descent, no distance gained)
segments = [segments, "descent_2"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* misc_Wfrac("descent");

% Loiter
segments = [segments, "loiter_1"];
Wfracs = [Wfracs, Wfrac];
LDmax = 0.5 * sqrt(pi .* ac.initial.AR .* ac.polar.a2a.clean.e ./ ac.polar.a2a.clean.CD0);
Wfrac = Wfrac .* loiter_Wfrac(ac.a2a.t_loiter, ac.initial.TSFC_dry, LDmax);

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
Wf_mission = (1 - Wfrac) .* ac.a2a.W0;

% Reserve fuel
Wfrac_loiter_reserve = loiter_Wfrac(ac.a2a.t_loiter, ac.initial.TSFC_dry, LDmax);
Wf_loiter_reserve = (1 - Wfrac_loiter_reserve) .* (ac.a2a.W0 - Wf_mission);
Wf_reserve = Wf_loiter_reserve + 0.05 .* Wf_mission;

% Trapped fuel
Wf_trapped = 0.01 .* Wf_mission;

% Total fuel
Wf = Wf_mission + Wf_reserve + Wf_trapped;

% Fuel fraction
Ffrac = Wf ./ ac.a2a.W0;
end
