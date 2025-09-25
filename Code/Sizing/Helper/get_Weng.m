function Weng = get_Weng(T0)


Tmil = 0.6 .* T0; % Military thrust is roughly 60% of maximum thrust.
Tmil = Tmil ./ 4.44822; % Convert from N to lb
W_dry = 0.521.*Tmil.^0.9;
Weng = W_dry + 0.082.*Tmil.^0.65 + 0.26.*Tmil.^0.5 + 9.33.*(W_dry./1000).^1.078;
Weng = Weng .* 4.44822; % Convert from lb to N
end