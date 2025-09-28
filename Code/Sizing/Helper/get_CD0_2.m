function CD0 = get_CD0_2(W0design, Sdesign, S)


c = -0.1289;
d = 0.7506;
Swet = 10.^(c + d.*log10(W0design ./ 4.44822)) .* 0.092903;
Swet_rest = Swet - 2.*Sdesign;

cf = 0.0040;
CD0 = cf .* (Swet_rest + 2.*S) ./ S;
