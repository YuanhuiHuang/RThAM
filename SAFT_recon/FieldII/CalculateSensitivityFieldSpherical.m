function CalculateSensitivityField(radius,Fs,c,maxPixels)
%% Start Field II and set initial parameters
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\usefullFunctions')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\TransducerBandwidthSignalDistortion')
savefolder = 'D:\Users\mathias.schwarz\Documents\MatlabData\FieldII\SphericalTransducer\';

%% Define Transducer geometry
diameter = 1.5e-3;
focalRadius = 1.65e-3;
eleSize = diameter/30;

% field_init(0);
Th = xdc_concave(diameter/2, focalRadius, eleSize);
figure(1), show_xdc(Th);
daspect([1 1 1]);
saveas(gcf,[savefolder '\SphericalTransducer.png'],'png');

%% Now we need to define the simulation grid for field calculations. y = 0 for XZ plane.
xmin = -0.75e-3;
xmax = 0.75e-3;
ymin = -0.75e-3;
ymax = 0.75e-3;
zmin = 0.3e-3;
zmax = 3e-3;
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
% excitation = sin(2*pi*(0:1/Fs:2/f0)*f0);
% xdc_excitation (Th, excitation);
Ts = 1/Fs; % Sampling period
t = 0:Ts:radius/(c)*10;
tau = c/radius*(t-(max(t)/2-radius/c));
nShape = radius*(1-tau).*heaviside(1-abs(tau-1));
figure(11), plot(t,nShape);
Filter = [20 180]*1e6;
nShapeFilt = SimFilter(nShape, t, Filter, 'BP', 1);
figure(111), plot(t,nShapeFilt);

%% The next step is to initialize the vectors, run the calc_hp function
% and display the resulting pressure field.
tic;
MaxSig = zeros(length(z),length(x),length(y));
point = [0 0 0];
for nx = 1:length(x)
    disp([ nx length(x)]);
    for ny = 1:length(y)
    	disp([ ny length(y)]);
        for nz = 1:length(z)
            point(1)=x(nx);
            point(2)=y(ny);
            point(3)=z(nz);
            [p1,t_temp] = calc_hp(Th,point);
            p1Filt = smooth(p1,round(length(p1)/10));
            nShapeConv = conv(nShape,p1Filt);
            MaxSig(nz,nx,ny) = max(nShapeConv) - min(nShapeConv);
        end
    end
end

% save data
save(sprintf('%s\\SensitivityFieldSpherical_Fs%1.2e_c%d_R%1.2e.mat',savefolder,Fs,c,radius),...
   'MaxSig','c','Fs','radius','x','y','z')

% for 3D images
NormVoxel = MaxSig(:,:,:);
NormVoxel = NormVoxel - min(NormVoxel(:));
NormVoxel = NormVoxel./max(NormVoxel(:));
Vol3Dfolder = sprintf('%s\\SensitivityFieldSpherical_Fs%1.2e_c%d_R%1.2e\\',savefolder,Fs,c,radius);
if exist(Vol3Dfolder,'dir') ~= 7
    mkdir(Vol3Dfolder)
    disp(['Creating ' Vol3Dfolder])
end
for i=1:length(y)
    imwrite(squeeze(NormVoxel(:,:,i)),[Vol3Dfolder 'SField_' num2str(i) '.png']);
    imshow(squeeze(NormVoxel(:,:,i)))
%     imagesc(squeeze(NormVoxel(:,:,i))), colormap gray, colorbar
    disp(num2str(i))
    pause(0.01)
end

toc;

end

