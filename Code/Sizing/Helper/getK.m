function K = getK(ac, polar)
    K = 1 ./ (pi .* ac.initial.AR .* polar.e);
end