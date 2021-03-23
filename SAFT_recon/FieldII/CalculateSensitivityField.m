function CalculateSensitivityField(f0,Fs,c,maxPixels)
%% Start Field II and set initial parameters
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\usefullFunctions')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\set_plot-v0.8.3\src')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\ImageJ\')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\ImageJ\fiji-win64\Fiji.app\scripts')
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
ymin = -2e-3;
ymax = 2e-3;
zmin = 0.0e-3;
zmax = 12e-3;
zpoints = maxPixels;
xpoints = round((xmax-xmin)/(zmax-zmin)*zpoints);
ypoints = round((ymax-ymin)/(zmax-zmin)*zpoints);
dx = (xmax-xmin)/xpoints;
dy = (ymax-ymin)/ypoints;
dz = (zmax-zmin)/zpoints;
x = xmin:dx:xmax;
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
    clc; disp([ nx length(x)]);
    for ny = 1:length(y)
        for nz = 1:length(z)
            point(1)=x(nx);
            point(2)=y(ny);
            point(3)=z(nz);
            [p1,t_temp] = calc_hp(Th,point);
            MaxSig(nz,nx,ny) = max(p1(:)); %NOTE: the convention here z is depth and y is elevation!!!
            MaxSigRWeighted(nz,nx,ny) = max(p1(:))*norm(point); %NOTE: the convention here z is depth(y) and y is elevation(z)!!!
            %MaxSig(nx,ny,n3) = norm(p1);
            %plot(p1);
            %pause(0.2)
            %P1nFilt = myfilter(P1n, [LCOF UCOF],fs );  %% filtering to desired freqeucny band
        end
    end
end
% field_end;


%% plot results
if ~IsJava3DInstalled(true)
    return
end

% Produce color scheme similar to 'hot' colors

blackMark = 0;
redMark = 0.1;
yellowMark = 0.2;
whiteMark = 1;

NormVoxel = MaxSig./max(MaxSig(:));

R = NormVoxel/(redMark-blackMark) - blackMark/(redMark-blackMark);
R(NormVoxel<blackMark) = 0;
R(NormVoxel>redMark) = 1;

G = NormVoxel/(yellowMark-redMark) - blackMark/(yellowMark-redMark);
G(NormVoxel<redMark) = 0;
G(NormVoxel>yellowMark) = 1;

B = NormVoxel/(whiteMark-yellowMark) - blackMark/(whiteMark-yellowMark);
B(NormVoxel<yellowMark) = 0;
B(NormVoxel>whiteMark) = 1;

% An extra step to do: R, G and B now contains doubles (0 to 1), and we
% would like to make 3 channels of single out of them.
R  = uint8(255 * R);
G  = uint8(255 * G);
B  = uint8(255 * B);

% We now put them together into one 3D color image (that is, with 4D). To
% do so, we simply concatenate them along the 3th dimension.
J = cat(4, R,G,B);

% Launch Miji. If we launch it in the false mode we specify
%  that we do not want to diplay the ImageJ toolbar.
Miji();

% The 3D viewer can only display ImagePlus. ImagePlus is the way ImageJ
% represent images. We can't feed it directly MATLAB data. Fortunately,
% that is where MIJ comes into handy. It has a function that can create an
% ImagePlus from a Matlab object.
% 1. The first argument is the name we will give to the image.
% 2. The second argument is the Matlab data
% 3. The last argument is a boolean. If true, the ImagePlus will be
% displayed as an image sequence. You might find this useful as well.
imp = MIJ.createColor('MRI data', J, false);

% Display the data in ImageJ 3D viewer
% Now for the display itself.
%
% We create an empty 3D viewer to start with. We do not show it yet.
universe = ij3d.Image3DUniverse();

%
% Now we show the 3D viewer window.
universe.show();

%
% Then we send it the data, and ask it to be displayed as a volumetric
% rendering.
c = universe.addVoltex(imp);

% save data
% x_real = x;
% y_real = z;
% z_real = y;
% save(sprintf('%s\\SensitivityFieldElevation_Fs%1.2e_c%d_f%1.2e.mat',savefolder,Fs,c,f0),...
%    'MaxSig','MaxSigRWeighted','c','Fs','f0','x_real','y_real','z_real')

toc;

end

