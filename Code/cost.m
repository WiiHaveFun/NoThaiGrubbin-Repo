function cst = cost(ac)
% COST  Creates a cost struct containing default parameters.
%    cst = COST()  returns the aircraft struct.

% All units are metric (m-kg-s)

% Aircraft struct TODO put in aircraft.m
ac_num_crew = 1;

ac_num_AIM120C_a2a = 6;
ac_num_AIM9X_a2a = 2;

ac_num_JDAM_strike = 4;
ac_num_AIM9X_strike = 2;

% Auxillary
%cst.aux.

% Environmental, Fleet, Compatibility, Weapons
cst.EFCW.AIM120_price = 916000;                                                     % Cost per AIM-120
cst.EFCW.AIM9X_price = 1;                                                           % Cost per AIM-9X TODO placeholder
cst.EFCW.JDAM_price = 22000 + 3026.54;                                              % Cost per JDAM

% COC
cst.COC.a2a_weapons = ac_num_AIM120C_a2a * cst.EFCW.AIM120_price + ...
    ac_num_AIM9X_a2a * cst.EFCW.AIM9X_price;                                        % Assumes all are used

cst.COC.strike_weapons = ac_num_JDAM_strike * cst.EFCW.JDAM_price + ...
    ac_num_AIM9X_strike * cst.EFCW.AIM9X_price;                                     % Assumes all are used

cst.COC.avg_weapons = (0.5 * cst.COC.a2a_weapons) + (0.5 * ac_num_AIM9X_strike);    % Assumes 50-50 mission mix

end