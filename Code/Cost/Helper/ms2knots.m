function knots = ms2knots(ms)
    %MS2KNOTS Convert meters per second to knots
    %   knots = MS2KNOTS(ms) converts speed in m/s to knots.
    %
    %   Conversion factor: 1 m/s = 1.94384 knots

    knots = ms * 1.94384;
end