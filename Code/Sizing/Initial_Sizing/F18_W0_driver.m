%% F-18E/F Validation, Air-to-air
clc
ac = aircraft();
ac.initial.AR = 3.99;
ac.initial.W_pay = 2946 .* 4.44822;

ac.a2a.R = 475 .* 1852;
ac.a2a.M_dash = 1.8;
ac.a2a.t_combat = 2 .* 60; 

% 1 crew
% Wfrac_reg.A = 0.8570 .* 0.224809.^-0.0557;
% Wfrac_reg.C = -0.0557;

% 2 crew
% Wfrac_reg.A = 0.8902 .* 0.224809.^-0.0528;
% Wfrac_reg.C = -0.0528;

% Nicolai
% Wfrac_reg.A = 0.9110 .* 0.224809.^-0.0532;
% Wfrac_reg.C = -0.0532;

% Raymer
Wfrac_reg.A = 2.3400 .* 0.224809.^-0.1300;
Wfrac_reg.C = -0.1300;

[ac] = iterate_W0(ac, Wfrac_reg, @a2a_Ffrac);
disp(ac.initial.W0./4.44822)

%% F-18E/F Validation, Strike
ac.initial.W_pay = 5422 .* 4.44822;

ac.strike.R = 388 .* 1852;
ac.strike.M_dash = 0.9;
ac.strike.V_dash = getV(0, ac.strike.M_dash);
ac.strike.R_combat = 100 .* 1852;
ac.strike.t_combat = ac.strike.R_combat ./ ac.strike.V_dash;

% 1 crew
% Wfrac_reg.A = 0.8570 .* 0.224809.^-0.0557;
% Wfrac_reg.C = -0.0557;

% 2 crew
% Wfrac_reg.A = 0.8902 .* 0.224809.^-0.0528;
% Wfrac_reg.C = -0.0528;

% Nicolai
% Wfrac_reg.A = 0.9110 .* 0.224809.^-0.0532;
% Wfrac_reg.C = -0.0532;

% Raymer
Wfrac_reg.A = 2.3400 .* 0.224809.^-0.1300;
Wfrac_reg.C = -0.1300;

[ac] = iterate_W0(ac, Wfrac_reg, @strike_Ffrac);
disp(ac.initial.W0./4.44822)