function CD0 = get_CD0(W0, S)


c = -0.1289;
d = 0.7506;
Swet = 10.^(c + d.*log10(W0 ./ 4.44822)) .* 0.092903;

cf = 0.0040;
CD0 = cf .* Swet ./ S;
