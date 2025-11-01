%calculate wing fuel using roskams method
b = 33/0.85; % account for folding wings and roskams assumption that 0.85% of span is usable
S = 670*0.58; % get the percentage that's only in the non-folded wing area
t = 0.06; % thickness percentage
tau = 1; % assume thickness % is the same at root and tip
lambda = 0.3; %taper ratio

wing_fuel(S, b, t, tau, lambda)

wing_fuel(804*0.58,44.5,0.04,0.72, 0.17); 

wing_fuel(787, 68.7,0.1, 0.80, 0.5); % matches roskam example

function v_fuel = wing_fuel(S, b, t, tau, lambda)

v_fuel = 0.54*(S^2/b)*t*((1+lambda*sqrt(tau)+lambda^2*tau)/((1+lambda)^2));

end