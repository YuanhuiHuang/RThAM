% Andrew Horsley, 27/5/2016

%% NI DIO card (NI PCI DIO-32HS)
% used for sending TTL trigger pulses to the camera

% delete(instrfind); % clear instrument memory
% s = daq.createSession('ni');
% addDigitalChannel(s,'Dev1','port3/line0','OutputOnly');

%% Camera properties
% Photometrics PRIME camera

% Ensure that we are starting in a blank state:
% Close camera and unload all device configurations
try    
    core.reset
catch
end
% Destroy any previous core object
clear core

% Instantiate a MMCore object
import mmcorej.* 
core = CMMCore();
% Load camera configuration and initialize.
core.loadSystemConfiguration('C:\Users\yuanhui\Downloads\FRET_Microscope\PM_USB_A26\Imaging Software\Prime Configuration File\Prime_20180522.cfg');

% apply settings:
% set property using: core.setProperty('Prime', 'Binning', '1x1');
% check using: binning = core.getProperty('Prime', 'Binning');
core.setProperty('Prime_20180522', 'Binning', '1x1');
core.setProperty('Prime_20180522', 'Gain', '1');
core.setProperty('Prime_20180522', 'Exposure', '50');
core.setProperty('Prime_20180522', 'ClearMode', 'Pre-Sequence');
core.setProperty('Prime_20180522', 'ClearCycles', '1'); % default is 2
core.setProperty('Prime_20180522', 'TriggerMode', 'Internal Trigger');
core.setProperty('Prime_20180522', 'ExposeOutMode', 'All Rows');

% set ROI. For best frame rate, the ROI should be vertically symmetric
% around the chip centre (as there are two sensor halves). May as well
% centre the ROI horizontally as well (X-axis)
NumXPixels=2048; NumYPixels=2048; 
XStart=floor(2048-NumXPixels)/2; YStart=floor(2048-NumYPixels)/2;
core.setROI(XStart,YStart,NumXPixels,NumYPixels);

%% Take images

nTestImages = 100;

% set up image array
width = NumXPixels;
height = NumYPixels;
actual = zeros(width,height,nTestImages);

% ready camera
core.startSequenceAcquisition(nTestImages, 0, false);  

% take images
% for i=1:nTestImages
% outputSingleScan(s,1);outputSingleScan(s,0); % effective TTL pulse to trigger camera
% pause(1+0.03)
% end

% extract images from micromanager storage
figure; 
for m=1:nTestImages
    n=nTestImages-m+1;
    pause(1)
    actual(:,:,n) = transpose(reshape(double(core.popNextImage()), [width, height]));
    imagesc(squeeze(actual(:,:,n))); axis image
    
end

% plot example image





%% Clean up:
% delete(instrfind)
% delete(s)
% clear s

% Close camera and unload all device configurations
% core.reset


