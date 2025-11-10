function h1 = get_cruise_start_h(ac, Wfrac_1, W0, h0, polar, is_max, pp)

options = optimoptions("fsolve", "Display", "none");
h1 = fsolve(@(h) h_residual(h), 12000, options);
% h1 = fzero(@(h) h_residual(h), [1000, 20000]);

function R = h_residual(h)
    [Wfrac_2, ~] = climb_ref_Wfrac(ac, Wfrac_1, W0, h0, h, polar, is_max);

    % Convert weight to cruise climb start value
    W = W0 .* Wfrac_1 .* Wfrac_2;

    % Residual is distance between climb end altitude and optimal cruise
    % climb start altitude for the initial cruise climb weight
    R = h - ppval(pp, W);
end
end