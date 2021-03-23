% clear; clc; close all;
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\TransducerBandwidthSignalDistortion')
Fs = 2e9;
v_s = 1510;

%% Start Field II and set initial parameters
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\usefullFunctions')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\!Toolbox\set_plot-v0.8.3\src')
cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII
savefolder = 'E:\MatlabData\FieldII';

%% Define Transducer geometry
diameter = 1.5e-3;
focalRadius = 1.65e-3;
eleSize = diameter/50;

field_init(0);
Th = xdc_concave(diameter/2, focalRadius, eleSize);
figure(1), show_xdc(Th);
daspect([1 1 1]);
%saveas(gcf,sprintf([savefolder '\Geometry128ElementLinearArray.png']),'png');

%% Define excitation signal of the apertures.
set_sampling(Fs);
set_field('c',v_s);
set_field('use_att',0);
Ts = 1/Fs; % Sampling period
aa = 30e-6; % radius of emitting  sphere
t = 0:Ts:500/Fs;
tau = v_s/aa*(t-(max(t)/2-aa/v_s));
nShape = aa*(1-tau).*heaviside(1-abs(tau-1));
figure(11), plot(t,nShape);

Filter = [10 160]*1e6;
nShapeFilt = SimFilter(nShape, t, Filter, 'BP', 1);
figure(111), plot(t,nShapeFilt);



%% The next step is to initialize the vectors, run the calc_hp function
% and display the resulting pressure field.

% transducer properties
f_c   = 98e6;
F_TD  = 1.65e-3;                                                           % Focal length of TD [m]
D_TD  = 1.50e-3;

% Focal zone and acceptance angle
alpha = atan(D_TD/(2*F_TD));                                               % Half-Angle of view [rad]
D_foc = 1.02*v_s/f_c*F_TD/D_TD;                                            % Width of focal zone (Olympus) [m]
% D_foc = 0.5*v_s/(mean(f_BP)*sin(alpha));                                 % Width of focal zone [um]       
a = D_foc/2;
f_hyp = a/cos(pi/2-alpha);
b = sqrt(f_hyp^2 - a^2);                                                   % a and b are hyperbel parameters    

depthMin = -1*1e-3;
depthMax = 3*1e-3;
step = 0.1e-3;
radMax = a/b * sqrt( (depthMax)^2 + b^2 );
NxMax = 100;
xVec = linspace(0,1.2*radMax,NxMax);

for depth = (focalRadius+depthMin):step:(focalRadius+depthMax)
    rad = a/b * sqrt( (depth-F_TD)^2 + b^2 );


    counter = 1;
    for Nx = 1:NxMax
        x = xVec(Nx);
        y = 0;
        z = depth;
        point = [x y z];
        [p1,t_temp] = calc_hp(Th,point);
    %     p1Filt = smooth(p1,round(length(p1)/10));
        nShapeConv = conv(nShapeFilt,p1);
        tConv = Ts*[1:length(nShapeConv)];
        sensitivity(counter) = max(nShapeConv)-min(nShapeConv);
        sensitivity2(counter) = max(p1)-min(p1);
        counter = counter + 1;
    end

    figure(20), plot(xVec,sensitivity), title(num2str(depth*1e3));  axis([0 xVec(end) 0 max(sensitivity)])
    figure(21), plot(xVec,sensitivity2), title(num2str(depth*1e3)); axis([0 xVec(end) 0 max(sensitivity2)])
    pause(0.1)
end



%%
% % figure(1), plot(0:0.01:3,sensitivity)
% 
% zHelp = 0:0.01:3; fHelp = (1./(zHelp-1.65))*1e-20; 
% % figure(2), plot(zHelp,fHelp,'red')
% 
% fHelp = (1./(zHelp-1.65))*1e-20; 
% figure(2), plot(zHelp,fHelp,'red')
% 
% figure(3), plot(0:0.01:3,sensitivity), hold on
% plot(zHelp,abs(0.4*fHelp),'red')
% plot(0:0.01:3,sensitivity2*1e-4,'green'), hold off

%%
% field_end;

