clear; close all; clc;

%% Constants
gamma = 1.4;
R = 287;

%% Geometry
S = 670./10.764;
b = 59./3.281;
c_geom = S./b;

taper_min = 0.05;
c_max = (2.*S)./(b.*(1+taper_min));
c_min = c_max.*taper_min;

%% Cruise
M_cruise = 0.84;
h_cruise = 40e3./3.281;
[rho_cruise, p_cruise, T_cruise] = stdatmfull(h_cruise);
mu_cruise = sutherlands(T_cruise);
a_cruise = sqrt(gamma.*R.*T_cruise);
V_cruise = M_cruise.*a_cruise;
Re_cruise = (rho_cruise.*V_cruise.*c_geom)./mu_cruise;

Re_max_cruise = (rho_cruise.*V_cruise.*c_max)./mu_cruise;
Re_min_cruise = (rho_cruise.*V_cruise.*c_min)./mu_cruise;

Cp_crit_cruise = (2./(gamma.*M_cruise.^2)) .* (((1+0.5.*(gamma-1).*M_cruise.^2)/(1+0.5.*(gamma-1))).^(gamma./(gamma-1))-1);

%% Takeoff/Landing
V_TO = 140./1.944;
[rho_TO, ~, T_TO] = stdatmfull(0);
mu_TO = sutherlands(T_TO);
Re_TO = (rho_TO.*V_TO.*c_geom)./mu_TO;

Re_max_TO = (rho_TO.*V_TO.*c_max)./mu_TO;
Re_min_TO = (rho_TO.*V_TO.*c_min)./mu_TO;

a_TO = sqrt(gamma.*R.*T_TO);
M_TO = V_TO./a_TO;

%% Dash
M_dash = 1.7;
h_dash = 30e3./3.281;
[rho_dash, ~, T_dash] = stdatmfull(h_dash);
mu_dash = sutherlands(T_dash);
a_dash = sqrt(gamma.*R.*T_dash);
V_dash = M_dash.*a_dash;
Re_dash = (rho_dash.*V_dash.*c_geom)./mu_dash;

%% Initial Values
taper_initial = 0.2;
sweep_initial = 25;

c_root_initial = (2.*S)./(b.*(1+taper_initial));
c_tip_initial = c_root_initial.*taper_initial;

MAC_initial = (2./3).*c_root_initial.*((1+taper_initial+taper_initial.^2)./(1+taper_initial));

% Section 1
x_LE_1 = 0;
y_LE_1 = 0;
z_LE_1 = 0;
chord_1 = c_root_initial;
angle_1 = 0;

disp([x_LE_1, y_LE_1, z_LE_1, chord_1, angle_1])

% Section 2
x_LE_2 = 0.25.*(c_root_initial-c_tip_initial) + (b./2).*tand(sweep_initial);
y_LE_2 = b./2;
z_LE_2 = 0;
chord_2 = c_tip_initial;
angle_2 = 2;

disp([x_LE_2, y_LE_2, z_LE_2, chord_2, angle_2])