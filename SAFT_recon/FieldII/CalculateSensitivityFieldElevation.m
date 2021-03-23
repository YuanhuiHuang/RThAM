function CalculateSensitivityFieldElevation(f0,Fs,c,maxPixels)
%% Start Field II and set initial parameters
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\usefullFunctions')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\set_plot-v0.8.3\src')
cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII
savefolder = 'D:\Users\mathias.schwarz\Documents\MatlabData\FieldII';

%% Define Transducer geometry
clearvars -except f0 Fs c maxPixels savefolder
clc

nel = 1;    % number of elements
width = 55/1e6;   % width of element
height = 1.5/1e3;     % height of element

kerf = (70-55)/1e6;
Rcurve = 7.5/1e3;   % radius of element curvature

elemres = 10e-6; % element discretisation resolution

Nx = width/elemres; 
Ny = height/elemres;
fcs = [0 0 0];  % focus position

% field_init(0);
Th = xdc_focused_array(nel,width,height,kerf,Rcurve,Nx,Ny,fcs);
figure(1), [x_pos,y_pos,z_pos] = show_xdc_MS(Th, kerf, width, height);
%hold on, scatter3(x_pos,y_pos,z_pos)
title('Geometry 128 element linear array - single element','FontSize',16);
daspect([1 1 1]);
%saveas(gcf,sprintf([savefolder '\Geometry128ElementLinearArray.png']),'png');

%% Now we need to define the simulation grid for field calculations. y = 0 for XZ plane.
ymin = -7.5e-3;
ymax = 7.5e-3;
zmin = 0.0e-3;
zmax = 15e-3;
zpoints = maxPixels;
ypoints = round((ymax-ymin)/(zmax-zmin)*zpoints); %1;
dy = (ymax-ymin)/ypoints;
dz = (zmax-zmin)/zpoints;
x = 0;
y = ymin:dy:ymax;
z = zmin:dz:zmax;

%% Define excitation signal of the apertures.
set_sampling(Fs);
set_field('c',c);
set_field('use_att',0);
excitation = sin(2*pi*(0:1/Fs:2/f0)*f0);
xdc_excitation (Th, excitation);

%% The next step is to initialize the vectors, run the calc_hp function
% and display the resulting pressure field.
tic;
MaxSig = zeros(length(z),length(y)); % Start time for Thrture 1 pressure signal
MaxSigRWeighted = zeros(length(z),length(y));
point = [0 0 0];
for nx = 1:length(x)
    for ny = 1:length(y)
        clc; disp([ ny length(y)]);
        for nz = 1:length(z)
            point(1)=x(nx);
            point(2)=y(ny);
            point(3)=z(nz);
            [p1,t_temp] = calc_hp(Th,point);
            MaxSig(nz,ny) = max(p1(:)); %NOTE: the convention here z is depth and y is elevation!!!
            MaxSigRWeighted(nz,ny) = max(p1(:))*norm(point); %NOTE: the convention here z is depth(y) and y is elevation(z)!!!
            %MaxSig(nx,ny,n3) = norm(p1);
            %plot(p1);
            %pause(0.2)
            %P1nFilt = myfilter(P1n, [LCOF UCOF],fs );  %% filtering to desired freqeucny band
        end
    end
end
% field_end;

% plot results
figure(2);
imagesc(y*1000,z(10:end)*1000,MaxSig(10:end,:))
title(['Sensitivity at f0 = ' num2str(f0*1e-6) 'MHz']);
colorbar
xlabel('elevation z (mm)');
ylabel('depth y (mm)');
daspect([1 1 1])
set_plot(gcf, 'FigureStyle', 'twocol', 'ColorMap', 'hot')
saveas(gcf,sprintf('%s\\Images\\YZPlain_Fs%1.2e_c%d_f%1.2e.png',savefolder,Fs,c,f0),'png')
figure(3);
imagesc(y*1000,z(10:end)*1000,MaxSigRWeighted(10:end,:))
title(['Sensitivity at f0 = ' num2str(f0*1e-6) 'MHz']);
colorbar
xlabel('elevation z (mm)');
ylabel('depth y (mm)');
daspect([1 1 1])
set_plot(gcf, 'FigureStyle', 'twocol', 'ColorMap', 'hot')
saveas(gcf,sprintf('%s\\Images\\YZPlainWeighted_Fs%1.2e_c%d_f%1.2e.png',savefolder,Fs,c,f0),'png')

% save data
x_real = x;
y_real = z;
z_real = y;
save(sprintf('%s\\SensitivityFieldElevation_Fs%1.2e_c%d_f%1.2e.mat',savefolder,Fs,c,f0),...
   'MaxSig','MaxSigRWeighted','c','Fs','f0','x_real','y_real','z_real')

toc;

end

