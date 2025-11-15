f = @(x1,x2) x1^2+x2^2-2*x1-2*x2+2;
g1 = @(x1,x2) 3*x1+x2-5.5;
g2 = @(x1,x2) x1+2*x2-4;
g3 = @(x1,x2) (x1-3)^2+(x2-2)^2;

x1coarse=linspace(2,5,4);
x2coarse=linspace(1,3,3);

nref = 10;
x1=refvec(x1coarse,nref);
x2=refvec(x2coarse,nref);

for i=1:length(x1)
  for j=1:length(x2)
    fobj(i,j) = f(x1(i),x2(j));
    con1(i,j) = g1(x1(i),x2(j));
    con2(i,j) = g2(x1(i),x2(j));
    con3(i,j) = g3(x1(i),x2(j));
  end
end

offset = 3.0;


figure(2)
clf;

carpet(x1,x2,fobj',offset,nref,'k','k');

hold on;

[xc, yc]=carpetconvert(x1, x2, fobj', offset, 3.5, 1.25);
plot(xc,yc,'kx','MarkerSize',10, 'LineWidth',1.5);
h = carpettext(x1, x2, fobj', offset, 3.5, 1.25, '   Spot');

ylabel('Objective 1')

h = carpetlabel(x1, x2, fobj', offset, nref, 1, 0, 0.3, 0.0 );
h = carpetlabel(x1, x2, fobj', offset, nref, 0, -1, 0, -0.75 );

h = carpettext(x1, x2, fobj', offset, 3.5, 3.0, '$X_1$', 1.0);
h = carpettext(x1, x2, fobj', offset, 2.0, 2.0, '$X_2$', 0.0, -2.0);

OC1 = ocontourc(x1,x2,con1',6*[1 1],false);
C1conv = carpetcontourconvert(x1,x2,fobj',offset,OC1);
h = hatchedcontours(C1conv,'g');

con1_test = con1;
con1_test(con1 < 6) = 0;
con1_test(con1 >= 6) = 1;
% con1_test = imgaussfilt(double(con1_test), 0.5);

OC1 = ocontourc(x1,x2,con1_test',0.5.*[1 1],false);
C1conv = carpetcontourconvert(x1,x2,fobj',offset,OC1);
h = hatchedcontours(C1conv,'b');
