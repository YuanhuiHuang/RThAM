function [PmVid, PmSrc, PmSrcInfo] = Pm_init()
% this script innitialize Photometrics Prime sCMOS for external triggered
% acquisition for RF activation of tissues. 20190108 yuanhui
%% Basic tools
% imaqreset
% imaqtool
% tmtool
% propinfo(PmVid,'TriggerRepeat')

options.message = 1;
try
%% Step 0 - specify .dll library for the sCMOS
imaqregister('C:\Program Files\Photometrics\PMQI-MatlabAdaptor\Utilities\MatlabAdaptor\PMImaq_2017b.dll');

%% Step 1 - Decide which device you want to work with.
% imaqhwinfo
try
    Info = imaqhwinfo('pmimaq_2017b');
catch ME
end
nTrials = 0;
while exist('ME')
    nTrials = nTrials + 1;
    try
        Info = imaqhwinfo('pmimaq_2017b');
    catch ME
    end
    if nTrials > 20 % if tried 10 times, quit.
        errcode = 1;        assert(false);
        break;
    end
end

if isempty(Info.DeviceIDs)
    Info = imaqhwinfo('pmimaq_2017b');   
end
if isempty(Info.DeviceIDs)
    errcode = 1;    assert(false);
end
PMdev1_Info = imaqhwinfo('pmimaq_2017b',Info.DeviceIDs{1});

%% Step 2 - Choose the format to work with.
% Create video input object. 
PmVid = videoinput('pmimaq_2017b',Info.DeviceIDs{1},PMdev1_Info.SupportedFormats{1})
PmVid.Tag = 'RION-Yuanhui';

PmVid.StartFcn      = @Pm_callback;
PmVid.TriggerFcn    = @Pm_callback;
PmVid.StopFcn       = @Pm_callback;
PmVid.FramesAcquiredFcn     = @Pm_FramesAcquiredCallback;
PmVid.FramesAcquiredFcnCount = 1; % Specify number of frames that must be acquired before frames acquired event is generated
PmVid.TimerFcn = @Pm_TimerFcnCallback; %  Specify the callback function to execute when a predefined period of time passes.
% iatconfigureLogging(PmVid,'C:\Pictures\imaqLog_0002.bin');

% get(PmVid)
%% Step 3 - Preview to check that the device is working and the image is what you expect.
% using default parameters by Prime
% himage = preview(PmVid);
%% Step 3.1
% stoppreview(PmVid);
% closepreview(PmVid);

%% Step 4 - Decide how many frames you want to acquire.
% PmVid_Info = get(PmVid);
% PmVid.ROIPosition = [128 484 1792 1080];% set FOV; for CMOS no need to trim horizontal
PmVid.ROIPosition = [0 0 2048 2048];% set FOV; for CMOS no need to trim horizontal
% PmVid.FramesPerTrigger = 200; 
% PmVid.TriggerRepeat = 10;  % 0 means don't repeat. n+1 Number of Triggers 
% PmVid.FrameGrabInterval = 1; % acquire every 5 frame in the video stream.
PmVid.Timeout  = 10; % 1 second
PmVid_Info = get(PmVid);
PmVid.FrameGrabInterval = 1; % acquire every 5 frame in the video stream.

PmVid.FramesPerTrigger = Inf; % Inf
PmVid.TriggerRepeat = 0;  % 0 means don't repeat. n+1 Number of Triggers 

% % Choose your log mode
% % logging to disk using imaqtool still takes up memory
PmVid.LoggingMode  = 'memory'; % 'disk', 'disk&memory'
triggerconfig(PmVid,'manual'); % This is trigger for logging of imaqtool object - 'immediate'  'manual'  'hardware'
imaqVideoLogger = VideoWriter([makeVideoDir('C:\Pictures\') '\imaqLogger_tmp.mj2'], 'Archival');
imaqVideoLogger.LosslessCompression = true;
imaqVideoLogger.MJ2BitDepth = 16;
PmVid.DiskLogger = imaqVideoLogger;
% triggerconfig(PmVid,'hardware','Falling edge','Extern'); % 'immediate'  'manual'  'hardware'
% triggerinfo(PmVid)
% triggerconfig(PmVid) % see properties
% triggerconfig(PmVid,'immediate'); % 'immediate'  'manual'  'hardware'
% triggerconfig(PmVid,'hardware','Falling edge','Extern'); % 'immediate'  'manual'  'hardware'
% trigger(PmVid); % if use manual trigger

% flushdata(PmVid);
% figure, imagesc(peekdata(PmVid,1)); % peek the last one frame
%



%% Step 5 - Set Acquisition Parameters. Need preview to take effect of setting
% Set value of a video source object property.
% Not all properties are specified. 
PmSrc = getselectedsource(PmVid);
PmSrc.AutoContrast = 'ON';
PmSrc.Binning = '1x1'; % '2x2' makes no sense for sCMOS hoping reduced read noise

PmSrc.CentroidsEnabled = 'NO';

PmSrc.CircularBufferEnabled = 'ON';

PmSrc.ClearCycles  = 1; % ??

PmSrc.ExpRes          = 'ms'; % 'ms' or 'us'
PmSrc.Exposure        =   50; % 0-10000 for both ms and us
PmSrc.ExposeOutMode = 'First Row' ; % 'First/All/Any Row'

PmSrc.FrameInfo       = 'ON';
PmSrc.MetadataEnabled =   'Yes';
PmSrc.Tag = 'RION-Yuanhui';

PmSrc.Offset          = 170;  % 170 at -25 Celsius degrees
PmSrc.AutoContrast = 'ON';
PmSrc.SensorTempSet      =   -25; % °C
PmSrc.FanSpeed         = 'HIGH'; 

% % before turn off the fan, make sure liquid cooling is working
% PmSrc.FanSpeed = 'Off(Liquid Cooled)'; 

% PmSrc.StreamSavingPath = 'C:\Users\yuanhui\Pictures\!Microscope\Stream2Disk';
% mkdir('C:\Users\yuanhui\Pictures\!Microscope\Stream2Disk2')


PmSrc.PMode    = 'Normal'; % ?? 'Alternate Normal'
PmSrc.PP0ENABLED  = 'YES'; % DESPECKLE BRIGHT LOW
PmSrc.PP1ENABLED  = 'YES'; % DESPECKLE BRIGHT HIGH
PmSrc.PP2ENABLED  = 'YES'; % DESPECKLE DARK LOW
PmSrc.PP3ENABLED  = 'NO'; % DENOISING slows frame rate
PmSrc.PP4ENABLED  = 'YES'; % DESPECKLE DARK HIGH

PmSrc.StreamSavingPath = makeVideoDir('C:\Pictures\', 'Long');
PmSrc.TriggerMode = 'Internal Trigger'; % 'Internal Trigger' 'Edge Trigger' or 'Trigger First'
PmSrc.ClearMode = 'Pre-Sequence'; % 'Pre-Sequence' or 'Pre-Exposure' 'Post-Sequence'
PmSrc.StreamAcquisition = 'OFF'; % 'OFF', 'RAW' or 'TIFF'

% 
% %% Step 5.1 Preview using specified parameters
% preview(PmVid,himage);
% %% Step 5.2
% stoppreview(PmVid);
% %% Step 5.3
% closepreview(PmVid);

%%
% %% Step 7 - Start acquisition
% start(PmVid);
% 
% %% Step 8 - Stop acquisition MANNUALLY. Don't need if specified frames*triggers
% stop(PmVid)
% 
% %% Step 9 - Export data to Workspace
% 
PmSrcInfo = get(getselectedsource(PmVid));

%%

catch exception
    switch errcode
        case 1
            if options.message, error 'No connection to camera. '; end;
    end
end
