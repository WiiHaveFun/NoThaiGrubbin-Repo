function obj = score(R, t_combat, M_dash, cost)
    [R, t_combat, M_dash] = ndgrid(R, t_combat, M_dash);

    obj = (R - 700)./300;
    obj = obj + (t_combat - 2)./3;
    obj = obj + (M_dash - 1.6)./0.4;

    cost./113e6;
end