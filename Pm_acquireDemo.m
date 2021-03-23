
%%
[PmVid, PmSrc, PmSrcInfo] = Pm_init();

%%
PmVid.ROIPosition = [0 0 2048 2048];% set FOV; for CMOS no need to trim horizontal
PmSrc.AutoContrast = 'ON';
PmPreview = preview(PmVid);

%% 
stoppreview(PmVid);

%% 
SaveMeasName = 'GFP10xFish10dpm';
PmSrc.ExpRes          = 'us'; % 'ms' or 'us'
PmSrc.Exposure        =   5e3; % 0-10000 for both ms and us; 1 us required by camera to synchronize
PmROIPosition = Pm_selectROI(PmVid,PmPreview,'Full'); % 'Full', 'Half', 'Manual', 'Keep'
% PMvid1.ROIPosition = [0 512 2048 1024];% set FOV; for CMOS no need to trim horizontal
PmSrc.TriggerMode = 'Internal Trigger'; % 'Internal Trigger' 'Edge Trigger' or 'Trigger First'

PmSrcInfo = get(getselectedsource(PmVid));

%% Fastest fps required but short video (limited by memory to 5-6 kframes ??? )
TiffSavingPath = makeVideoDir('C:\Pictures\', 'Short', SaveMeasName); % 'Short' video 
PmSrc.StreamAcquisition = 'OFF'; % 'OFF', 'RAW' or 'TIFF'
PmVid.LoggingMode  = 'memory'; % 'disk', 'disk&memory'; 100 fps achievable if log to memory first
triggerconfig(PmVid,'manual'); % This is trigger for logging of imaqtool object - 'immediate'  'manual'  'hardware'
PmSrc.AutoContrast = 'OFF'; % if ON frame rate reduces to half
PmVid.TimerPeriod = (6000/100) * (PmROIPosition(3)*PmROIPosition(4))/(2048*2048) ; % seconds, calculate the period can take in order not to exceed memory
% PmVid.TimerPeriod = 1; % seconds, calculate the period can take in order not to exceed memory
flushdata(PmVid);
% PmPreview = preview(PmVid);
start(PmVid);
tic; trigger(PmVid); % if use manual trigger to log data to memory

%% stop write to TIFF
stop(PmVid); toc

% % Step 10 - write to TIFF
addpath('C:\Users\yuanhui\MATLAB\TAM\saveastiff_4.4');
Tiffoptions.message   = true;
Tiffoptions.color = false;      % [Width Height Color Frame]
Tiffoptions.append    = true;
Tiffoptions.overwrite = true;
Tiffoptions.big       = true; % using 64 bit addressing allowing for >4GB file
nFramesStack = 1000 ; % 500 frames (4 GB) per block
nFramesAvailable = PmVid.FramesAvailable;
PmTimeStamp = zeros(nFramesAvailable, 1);
PmMetaData(nFramesAvailable,1) = struct('AbsTime', [0,0,0,0,0,0.0], ...
                'FrameNumber', 0, 'RelativeFrame', 0, 'TriggerIndex', 0);
hWaitbar = waitbar(0,'Start saving ...');
for idx=1:nFramesStack:nFramesAvailable
    if idx+nFramesStack > nFramesAvailable
        nFramesStack = nFramesAvailable - idx +1;
    end
    TiffFileName = [TiffSavingPath 'S_PM_stack',num2str(idx) 'to' num2str(idx+nFramesStack-1) '.tif'];
    [PmRaw, PmTimeStamp(idx:idx+nFramesStack-1), PmMetaData(idx:idx+nFramesStack-1)] = getdata(PmVid,nFramesStack);
    waitbar(idx/nFramesAvailable,hWaitbar, ['Saving to disk ' num2str(idx) '-' num2str(idx+nFramesStack-1) ' of ' num2str(nFramesAvailable)]);
    saveastiff(squeeze(PmRaw), TiffFileName, Tiffoptions);
end
close(hWaitbar);

PmSrcInfo = get(getselectedsource(PmVid));
save([TiffSavingPath datestr(now,'yyyymmdd') '_'...
    SaveMeasName '_' num2str(PmSrcInfo.Exposure) PmSrcInfo.ExpRes '_'...
    num2str(round(1./mean(diff(PmTimeStamp)))) 'fps' '_Meta.mat'],...
    'PmTimeStamp', 'PmMetaData', 'PmSrcInfo');

%% long video required, but fps halved as fastest memory logging
stoppreview(PmVid);
TiffSavingPath = makeVideoDir('C:\Pictures\', 'Long', SaveMeasName);
PmSrc.StreamSavingPath = TiffSavingPath;
PmSrc.AutoContrast = 'OFF';
PmSrc.StreamAcquisition = 'TIFF'; % 'OFF', 'RAW' or 'TIFF' % disk stream give 50 frames/s
% PmPreview = preview(PmVid);
stoppreview(PmVid)
flushdata(PmVid);
warning('off');
tStart = tic; 
start(PmVid);

%% Step 8 - Stop acquisition MANNUALLY. Don't need if specified frames*triggers
stop(PmVid); 
tElapsed = toc(tStart);
disp(lastwarn); warning('on'); 
PmSrc.StreamAcquisition = 'OFF'; % 'OFF', 'RAW' or 'TIFF'
PmSrc.FanSpeed         = 'HIGH'; 

PmSrcInfo = get(getselectedsource(PmVid));
save([TiffSavingPath datestr(now,'yyyymmdd') '_'...
    SaveMeasName '_' num2str(PmSrcInfo.Exposure) PmSrcInfo.ExpRes '_'...
    num2str(round(length(dir([TiffSavingPath '*F_PV*']))/(tElapsed))) 'fps' '_Meta.mat'],...
    'PmTimeStamp', 'PmMetaData', 'PmSrcInfo');
