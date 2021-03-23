clear; clc; close all;
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\TransducerBandwidthSignalDistortion')
Fs = 10e9;
c = 1500;

%% Start Field II and set initial parameters
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\usefullFunctions')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\set_plot-v0.8.3\src')
cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII
savefolder = 'D:\Users\mathias.schwarz\Documents\MatlabData\FieldII';

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
set_field('c',c);
set_field('use_att',0);
% excitation = sin(2*pi*(0:1/Fs:2/f0)*f0);
% xdc_excitation (Th, excitation);
Ts = 1/Fs; % Sampling period
a = 5e-6; % radius of emitting  sphere
t = 0:Ts:500/Fs;
tau = c/a*(t-(max(t)/2-a/c));
nShape = a*(1-tau).*heaviside(1-abs(tau-1));
figure(11), plot(t,nShape);

Filter = [20 180]*1e6;
nShapeFilt = SimFilter(nShape, t, Filter, 'BP', 1);
% Order = 4;
% [b,a]=butter(Order,Filter/(Fs/2));
% nShapeFilt = filtfilt(b,a,nShape);
figure(111), plot(t,nShapeFilt);



%% The next step is to initialize the vectors, run the calc_hp function
% and display the resulting pressure field.

for i = 0:0.1:2
    point = [0 0.1e-3 1.65e-3*i];
    [p1,t_temp] = calc_hp(Th,point);
    figure(2), plot(p1);
%     p1Filt = medfilt1(p1,round(length(p1)/10));
    p1Filt = smooth(p1,round(length(p1)/10));
    figure(22), plot(p1Filt);
%     nShapeConv = conv(nShapeFilt,p1Filt);
    nShapeConv = conv(nShape,p1Filt);
    tConv = Ts*[1:length(nShapeConv)];
    figure(3), plot(tConv,nShapeConv);
    pause 
end

% field_end;

