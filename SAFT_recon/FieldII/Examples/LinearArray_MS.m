% Example from http://www.egr.msu.edu/~fultras-web/files/documentation/Field-to-FOCUS.pdf
%% Start Field II and set initial parameters
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\usefullFunctions')
cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII
field_init(0);

%
f0=40e6; %excitation frequency
nel = 1;    % number of elements
width = 55/1e6;   % width of element
height = 1.5/1e3;     % height of element

kerf = (70-55)/1e6
Rcurve = 7.5/1e3;   % radius of element curvature

elemres=10e-6; % element discretisation resolution

Nx = width/elemres; 
Ny = height/elemres;
fcs = [0 0 0];  % focus position

Th = xdc_focused_array(nel,width,height,kerf,Rcurve,Nx,Ny,fcs);
figure(1), [x_pos,y_pos,z_pos] = show_xdc_MS(Th, kerf, width, height)
%hold on, scatter3(x_pos,y_pos,z_pos)
title('Geometry 128 element linear array - single element','FontSize',16)
daspect([1 1 1]);
saveas(gcf,sprintf('Geometry128ElementLinearArray2.png'),'png')


%

% This sets up our trasducer array with 20 0.7 mm x 3 mm elements
% spaced 0.5 mm edge-to-edge. Now we need to define the simulation
% grid for field calculations. y = 0 for XZ plane.
xmin = 0;
xmax = 0;
ymin = -height*2/3;
ymax = height*2/3;
zmin = 0.5e-3;
zmax = 15e-3;
xpoints = 1;
ypoints = 100;
zpoints = 100;
dx = (xmax-xmin)/xpoints;
dy = (ymax-ymin)/ypoints;
dz = (zmax-zmin)/zpoints;
x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;

% This sets up our coordinate grid to cover the full width of the
% transducer array in the x direction and to measure the pressure field to
% 50 wavelengths in the z direction. Now we need to set the sampling
% frequency, the medium sound speed and the excitation signal of the
% apertures.
%UCOFvector=40*1e6;%[0.25:0.25:6]*1e6
%LCOFvector=0*1e6;%[0:0.25:5.75]*1e6
Fs=12500e6;
c=1520;
set_sampling(Fs);
set_field('c',c);
Ts = 1/Fs; % Sampling period
T = 2030/Fs;
te = 0:Ts:2030/Fs; % Time vector
excitation = sin(2*pi*f0*te+pi); % Excitation signal
xdc_excitation(Th, excitation);

% The next step is to initialize the vectors, run the calc_hp function
% and display the resulting pressure field.
tic;
point = [0 0 0];
t1 = zeros(length(y),length(z)); % Start time for Thrture 1 pressure signal
P1n = t1; % Norm of pressure from Thrture 1
for n2 = 1:length(y)
    clc;[ n2 length(y)]
    for n3 = 1:length(z)
        point(1)=0;
        point(2)=y(n2);
        point(3)=z(n3);
        [p1,t1(n2,n3)] = calc_hp(Th,point);
        %P1n(n2,n3) = norm(p1);
        P1n(n2,n3) = max(p1(:));
        %P1nFilt = myfilter(P1n, [LCOF UCOF],fs );  %% filtering to desired freqeucny band
    end
end
field_end;
figure(2);
%h = pcolor(y*1000,z*1000,rot90(squeeze(abs(P1n)),3));
%set(h,'edgecolor','none');
imagesc(y*1000,z*1000,rot90(squeeze(P1n),3))
title('Pressure Field at x = 0 mm');
xlabel('y (mm)');
ylabel('z (mm)');
ylim([zmin*1000 zmax*1000])
daspect([1 1 1])
toc;

%%
field_init(0);

%%
nel = 1;    % number of elements
width = 55/1e6;   % width of element
height = 1.5/1e3;     % height of element

kerf = (70-55)/1e6
Rcurve = 7.5/1e3;   % radius of element curvature

elemres=10e-6; % element discretisation resolution

Nx = width/elemres; 
Ny = height/elemres;
fcs = [0 0 0];  % focus position

Th = xdc_focused_array(nel,width,height,kerf,Rcurve,Nx,Ny,fcs);
figure(1), show_xdc(Th)
%hold on, scatter3(x_pos,y_pos,z_pos)
title('Geometry 128 element linear array - single element','FontSize',16)
daspect([1 1 1]);
saveas(gcf,sprintf('Geometry128ElementLinearArray2.png'),'png')

% This sets up our trasducer array with 20 0.7 mm x 3 mm elements
% spaced 0.5 mm edge-to-edge. Now we need to define the simulation
% grid for field calculations. y = 0 for XZ plane.
xmin = -7.5e-3;
xmax = 7.5e-3;
ymin = 0;
ymax = 0;
zmin = 0.5e-3;
zmax = 15e-3;
xpoints = 100;
ypoints = 1;
zpoints = 100;
dx = (xmax-xmin)/xpoints;
dy = (ymax-ymin)/ypoints;
dz = (zmax-zmin)/zpoints;
x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;

% This sets up our coordinate grid to cover the full width of the
% transducer array in the x direction and to measure the pressure field to
% 50 wavelengths in the z direction. Now we need to set the sampling
% frequency, the medium sound speed and the excitation signal of the
% apertures.
UCOFvector=40*1e6;%[0.25:0.25:6]*1e6
LCOFvector=0*1e6;%[0:0.25:5.75]*1e6
Fs=125e6;
c=1520;
set_sampling(Fs);
set_field('c',c);
Ts = 1/Fs; % Sampling period
T = 2030/Fs;
te = 0:Ts:2030/Fs; % Time vector
%excitation = sin(2*pi*f0*te+pi); % Excitation signal
%xdc_excitation(Th, excitation);

% The next step is to initialize the vectors, run the calc_hp function
% and display the resulting pressure field.
tic;
point = [0 0 0];
t1 = zeros(length(x),length(z)); % Start time for Thrture 1 pressure signal
P1n = t1; % Norm of pressure from Thrture 1
for n2 = 1:length(x)
    clc;[ n2 length(x)]
    for n3 = 1:length(z)
        point(1)=x(n2);
        point(2)=0;
        point(3)=z(n3);
        [p1,t1(n2,n3)] = calc_hp(Th,point);
        %P1n(n2,n3) = norm(p1);
        P1n(n2,n3) = max(p1(:));
        %P1nFilt = myfilter(P1n, [LCOF UCOF],fs );  %% filtering to desired freqeucny band
    end
end
field_end;
figure(3);
%h = pcolor(y*1000,z*1000,rot90(squeeze(abs(P1n)),3));
%set(h,'edgecolor','none');
imagesc(x*1000,z*1000,rot90(squeeze(P1n),3))
title('Pressure Field at y = 0 mm');
xlabel('x (mm)');
ylabel('z (mm)');
ylim([0 zmax*1000])
daspect([1 1 1])
toc;