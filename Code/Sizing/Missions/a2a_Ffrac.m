function [Ffrac, Wfracs, segments] = a2a_Ffrac(ac)
% A2A_FFRAC  Calculates the fuel fraction for an air-to-air mission and
% mission segment weight fractions.
%    [Ffrac, Wfrac, segments] = A2A_FFRAC(ac)  returns the mission fuel
%    fraction, mission segment weight fractions, and the mission segments.

segments = "takeoff";
Wfrac = 1;
Wfracs = Wfrac;

% Warmup, taxi, and takeoff
Wfrac = Wfrac .* misc_Wfrac("warmup");
Wfrac = Wfrac .* misc_Wfrac("taxi");
Wfrac = Wfrac .* misc_Wfrac("takeoff");
% Climb and accelerate
segments = [segments, "climb_1"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* climb_acc_Wfrac(0.0, ac.initial.M_cruise);
d_climb = get_climb_dist(ac.initial.climb_angle, ac.initial.h_cruise);
% Cruise climb to combat
segments = [segments, "cruise_1"];
Wfracs = [Wfracs, Wfrac];
LDmax = sub_LDmax_est(ac.initial.AR, ac.initial.M_cruise);
Wfrac = Wfrac .* cruise_Wfrac(ac.a2a.R - d_climb, ac.initial.V_cruise, ac.initial.TSFC_dry, 0.943.*LDmax);
% Combat acceleration
segments = [segments, "dash"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* climb_acc_Wfrac(ac.initial.M_cruise, ac.a2a.M_dash);
% Descent to combat
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
Wfrac = Wfrac .* climb_acc_Wfrac(0.0, ac.initial.M_cruise);
d_climb = get_climb_dist(ac.initial.climb_angle, ac.initial.h_cruise - ac.a2a.h_combat);
% Cruise climb back
segments = [segments, "cruise_2"];
Wfracs = [Wfracs, Wfrac];
LDmax = sub_LDmax_est(ac.initial.AR, ac.initial.M_cruise);
Wfrac = Wfrac .* cruise_Wfrac(ac.a2a.R - d_climb, ac.initial.V_cruise, ac.initial.TSFC_dry, 0.943.*LDmax);
% Descent to loiter
segments = [segments, "descent_2"];
Wfracs = [Wfracs, Wfrac];
Wfrac = Wfrac .* misc_Wfrac("descent");
% Loiter
segments = [segments, "loiter_1"];
Wfracs = [Wfracs, Wfrac];
LDmax = sub_LDmax_est(ac.initial.AR, ac.initial.M_loiter);
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
LDmax = sub_LDmax_est(ac.initial.AR, ac.initial.M_loiter);
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
