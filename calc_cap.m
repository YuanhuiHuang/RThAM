%%calc_cap
A=56e-3*103e-3; %mm^2
epsil_air = 1.00059;
epsil_vacuum = 8.854187817e-12; %F/m

D=1.5e-3;

C = epsil_vacuum * epsil_air * A ./ D

