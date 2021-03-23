function CalculateSensitivityFieldLarge(a,Fs,c,maxPixels)

% Example from http://www.egr.msu.edu/~fultras-web/files/documentation/Field-to-FOCUS.pdf
%% Start Field II and set initial parameters
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\usefullFunctions')
cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII
savefolder = 'D:\Users\mathias.schwarz\Documents\MatlabData\FieldII\Images';

%% Definitions
%maxPixels=300;

%% Define Transducer geometry
clearvars -except a Fs c maxPixels
clc

nel = 1;    % number of elements
width = 55/1e6;   % width of element
height = 1.5/1e3;     % height of element

kerf = (70-55)/1e6;
Rcurve = 7.5/1e3;   % radius of element curvature

elemres=10e-6; % element discretisation resolution

Nx = width/elemres; 
Ny = height/elemres;
fcs = [0 0 0];  % focus position

field_init(0);
Th = xdc_focused_array(nel,width,height,kerf,Rcurve,Nx,Ny,fcs);
figure(1), [x_pos,y_pos,z_pos] = show_xdc_MS(Th, kerf, width, height);
%hold on, scatter3(x_pos,y_pos,z_pos)
title('Geometry 128 element linear array - single element','FontSize',16);
daspect([1 1 1]);
saveas(gcf,sprintf([savefolder '\Geometry128ElementLinearArray.png']),'png');


%

% Now we need to define the simulation grid for field calculations. y = 0 for XZ plane.
xmin = -15e-3; %0;
xmax = 15e-3; %0;
ymin = -5e-3;
ymax = 5e-3;
zmin = 0.0e-3;
zmax = 15e-3;
zpoints = maxPixels;
xpoints = round((xmax-xmin)/(zmax-zmin)*zpoints); %1;
ypoints = round((ymax-ymin)/(zmax-zmin)*zpoints);
dx = (xmax-xmin)/xpoints;
dy = (ymax-ymin)/ypoints;
dz = (zmax-zmin)/zpoints;
x = xmin:dx:xmax;
y = ymin:dy:ymax;
z = zmin:dz:zmax;

% Now we need to set the sampling frequency, the medium sound speed
% and the excitation signal of the apertures.
%Fs=1250e6;
Ts = 1/Fs; % Sampling period
%c=1480;
set_sampling(Fs);
set_field('c',c);
set_field('use_att',0);

%a = 50e-6; % radius of emitting  sphere
t = 0:Ts:2030/Fs;
tau = c/a*(t-(max(t)/2-a/c));
excitation=a*(1-tau).*heaviside(1-abs(tau-1));

% Set the impulse response and excitation of the emit aperture
% impulse_response=sin(2*pi*f0*(0:1/fs:2/f0));
% impulse_response=impulse_response.*hanning(max(size(impulse_response)))';
% xdc_impulse (Th, impulse_response);
% xdc_impulse (Th2, impulse_response);
xdc_excitation (Th, excitation);

%% The next step is to initialize the vectors, run the calc_hp function
% and display the resulting pressure field.
tic;
MaxSig = zeros(length(x),length(y),length(z)); % Start time for Thrture 1 pressure signal
point = [0 0 0];
for nx = 1:length(x)
    clc; disp([ nx length(x)]);
    for ny = 1:length(y)
        for nz = 1:length(z)
            point(1)=x(nx);
            point(2)=y(ny);
            point(3)=z(nz);
            [p1,t_temp] = calc_hp(Th,point);
            MaxSig(nx,ny,nz) = max(p1(:));
            %MaxSig(nx,ny,n3) = norm(p1);
            %plot(p1);
            %pause(0.2)
            %P1nFilt = myfilter(P1n, [LCOF UCOF],fs );  %% filtering to desired freqeucny band
        end
    end
end
field_end;

%for ix=1:length(x)
ix=round(length(x)/2);
    set(gca,'FontSize',14)
    figure(2);
    YZMat=squeeze(MaxSig(ix,:,:));
    imagesc(z*1000,y*1000,YZMat)
    title(['Maximal signal at x = ' num2str(x(ix)*1000) ' mm for sphere radius a = ' num2str(a*1e6) 'micron'],'FontSize',16);
    colormap('jet')
    colorbar('FontSize',16)
    xlabel('z (mm)','FontSize',16);
    ylabel('y (mm)','FontSize',16);
    xlim([zmin*1000 zmax*1000])
    ylim([ymin*1000 ymax*1000])
    daspect([1 1 1])
    saveas(gcf,sprintf('%s\YZPlaneLarge_Fs_%1.2e_c_%d_a_%5.5f.png',savefolder,Fs,c,a),'png')
    %pause(0.2)
%end

%for iy=1:length(y)
iy=round(length(y)/2);
    set(gca,'FontSize',14)
    figure(3);
    XZMat=squeeze(MaxSig(:,iy,:));
    imagesc(z*1000,x*1000,XZMat)
    title(['Maximal signal at y = ' num2str(y(iy)*1000) ' mm for sphere radius a = ' num2str(a*1e6) 'micron'],'FontSize',16);
    colorbar;
    xlabel('z (mm)','FontSize',16);
    ylabel('x (mm)','FontSize',16);
    xlim([zmin*1000 zmax*1000])
    ylim([xmin*1000 xmax*1000])
    daspect([1 1 1])
    saveas(gcf,sprintf('%s\XZPlaneLarge_Fs_%1.2e_c_%d_a_%5.5f.png',savefolder,Fs,c,a),'png')
    %pause(0.2)
%end

% save data
save(sprintf('%s\SensitivityFieldLarge_Fs_%1.2e_c_%d_a_%5.5f.mat',savefolder,Fs,c,a),'MaxSig','c','Fs','a','x','y','z')

% transform to coordinates used later:
x_real = x;
y_real = z;
z_real = y;
sensitivityField = permute(MaxSig,[1 3 2]);
save(sprintf('%s\SensitivityFieldLarge2_Fs_%1.2e_c_%d_a_%5.5f.mat',savefolder,Fs,c,a),'sensitivityField','c','Fs','a','x_real','y_real','z_real')

toc;

end

