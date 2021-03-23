% Example from http://www.egr.msu.edu/~fultras-web/files/documentation/Field-to-FOCUS.pdf
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII

% Field II CW Example
% Start Field II and set initial parameters
field_init(0);
f0=1e6;
Fs=100e6;
c = 1500; % Speed of sound [m/s]
lambda = 1500/f0;
focus = [0 0 25*lambda]; % Fixed focal point [m]
N_elements = 20; % Number of physical elements
width = 7e-4; % Width of element
height = 3e-3; % Height of element [m]
kerf = 5e-4; % Kerf [m]
elefocus = 1; % Whether to use elevation focus
Rfocus = 25e-3; % Elevation focus [m]

% Define the transducer
Th = xdc_linear_array (N_elements, width, height, kerf, 20, 1, focus);
figure(1);
show_xdc(Th);

% This sets up our trasducer array with 20 0.7 mm x 3 mm elements
% spaced 0.5 mm edge-to-edge. Now we need to define the simulation
% grid for field calculations. y = 0 for XZ plane.
spacing= width + kerf;
elements_x = 20;
xmin = -(width + spacing) * (elements_x/2+1);
xmax = (width + spacing) * (elements_x/2+1);
ymin = 0;
ymax = 0;
zmin = 1e-3;
zmax = 50 * lambda;
xpoints = 400;
ypoints = 1;
zpoints = 300;
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
set_sampling(Fs);
set_field('c',c);
Ts = 1/Fs; % Sampling period
T = 50e-6;
te = 0:Ts:T; % Time vector
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
        P1n(n2,n3) = norm(p1);
    end
end
field_end;
figure(2);
h = pcolor(x*100,z*100,rot90(squeeze(abs(P1n)),3));
set(h,'edgecolor','none');
title('Pressure Field at y = 0 cm');
xlabel('x (cm)');
ylabel('z (cm)');
ylim([0 zmax*100])
toc;