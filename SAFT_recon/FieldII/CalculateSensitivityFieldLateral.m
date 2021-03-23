function CalculateSensitivityFieldLateral(f0,Fs,c,maxPixels)
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
xmin = -7.5e-3;
xmax = 7.5e-3;
zmin = 0.0e-3;
zmax = 15e-3;
zpoints = maxPixels;
xpoints = round((xmax-xmin)/(zmax-zmin)*zpoints); %1;
dx = (xmax-xmin)/xpoints;
dz = (zmax-zmin)/zpoints;
x = xmin:dx:xmax;
y = 0;
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
MaxSig = zeros(length(z),length(x)); % Start time for Thrture 1 pressure signal
MaxSigRWeighted = zeros(length(z),length(x));
point = [0 0 0];
for nx = 1:length(x)
    clc; disp([ nx length(x)]);
    for ny = 1:length(y)
        for nz = 1:length(z)
            point(1)=x(nx);
            point(2)=y(ny);
            point(3)=z(nz);
            [p1,t_temp] = calc_hp(Th,point);
            MaxSig(nz,nx) = max(p1(:)); %NOTE: the convention here z is depth and y is elevation!!!
            MaxSigRWeighted(nz,nx) = max(p1(:))*norm(point); %NOTE: the convention here z is depth(y)!!!
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
imagesc(x*1000,z(10:end)*1000,MaxSig(10:end,:))
title(['Max signal at f0 = ' num2str(f0*1e-6) 'MHz']);
title(['Sensitivity at f0 = ' num2str(f0*1e-6) 'MHz']);
colorbar
xlabel('lateral disp x (mm)');
ylabel('depth y (mm)');
daspect([1 1 1])
set_plot(gcf, 'FigureStyle', 'twocol', 'ColorMap', 'hot')
saveas(gcf,sprintf('%s\\Images\\YXPlain_Fs%1.2e_c%d_f%1.2e.png',savefolder,Fs,c,f0),'png')
figure(3);
imagesc(x*1000,z(10:end)*1000,MaxSigRWeighted(10:end,:))
title(['Sensitivity at f0 = ' num2str(f0*1e-6) 'MHz']);
colorbar
xlabel('lateral disp x (mm)');
ylabel('depth y (mm)');
daspect([1 1 1])
set_plot(gcf, 'FigureStyle', 'twocol', 'ColorMap', 'hot')
saveas(gcf,sprintf('%s\\Images\\YXPlainWeighted_Fs%1.2e_c%d_f%1.2e.png',savefolder,Fs,c,f0),'png')

% save data
save(sprintf('%s\\SensitivityFieldLateral_Fs%1.2e_c%d_f%1.2e.mat',savefolder,Fs,c,f0),...
   'MaxSig','MaxSigRWeighted','c','Fs','f0','x','y','z')
toc;

end

