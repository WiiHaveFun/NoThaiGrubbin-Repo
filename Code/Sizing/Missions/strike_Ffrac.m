function Ffrac = strike_Ffrac(ac)
% STRIKE_FFRAC  Calculates the fuel fraction for a strike mission.

% Warmup, taxi, and takeoff
Wfrac = misc_Wfrac("warmup");
Wfrac = Wfrac .* misc_Wfrac("taxi");
Wfrac = Wfrac .* misc_Wfrac("takeoff");
% Climb and accelerate
Wfrac = Wfrac .* climb_acc_Wfrac(0.0, ac.initial.M_cruise);
% Cruise climb to combat
LDmax = sub_LDmax_est(ac.initial.AR, ac.initial.M_cruise);
Wfrac = Wfrac .* cruise_Wfrac(ac.strike.R, ac.initial.V_cruise, ac.initial.TSFC_dry, 0.943.*LDmax);
% Descent to combat
Wfrac = Wfrac .* misc_Wfrac("descent");
% Combat acceleration
if ac.initial.M_cruise < ac.strike.M_dash
    Wfrac = Wfrac .* climb_acc_Wfrac(ac.initial.M_cruise, ac.strike.M_dash);
end
% Combat
Wf_combat = combat_Wf(ac.initial.TSFC_dry, ac.initial.T_mil, ac.strike.t_combat);
Wfrac = Wfrac .* (1 - Wf_combat ./ (Wfrac .* ac.initial.W0));
% Climb and accelerate
Wfrac = Wfrac .* climb_acc_Wfrac(0.0, ac.initial.M_cruise);
% Cruise climb back
LDmax = sub_LDmax_est(ac.initial.AR, ac.initial.M_cruise);
Wfrac = Wfrac .* cruise_Wfrac(ac.strike.R, ac.initial.V_cruise, ac.initial.TSFC_dry, 0.943.*LDmax);
% Descent to loiter
Wfrac = Wfrac .* misc_Wfrac("descent");
% Loiter
LDmax = sub_LDmax_est(ac.initial.AR, ac.initial.M_loiter);
Wfrac = Wfrac .* loiter_Wfrac(ac.strike.t_loiter, ac.initial.TSFC_dry, LDmax);
% First landing attempt
Wfrac = Wfrac .* misc_Wfrac("landing");
% Second landing attempt
Wfrac = Wfrac .* climb_acc_Wfrac(0.0, ac.initial.M_loiter);
Wfrac = Wfrac .* misc_Wfrac("landing");
% Mission fuel
Wf_mission = (1 - Wfrac) .* ac.initial.W0;
% Reserve fuel
LDmax = sub_LDmax_est(ac.initial.AR, ac.initial.M_loiter);
Wfrac_loiter_reserve = loiter_Wfrac(ac.strike.t_loiter, ac.initial.TSFC_dry, LDmax);
Wf_loiter_reserve = (1 - Wfrac_loiter_reserve) .* (ac.initial.W0 - Wf_mission);
Wf_reserve = Wf_loiter_reserve + 0.05 .* Wf_mission;
% Trapped fuel
Wf_trapped = 0.01 .* Wf_mission;
% Total fuel
Wf = Wf_mission + Wf_reserve + Wf_trapped;
% Fuel fraction
Ffrac = Wf ./ ac.initial.W0;

end
