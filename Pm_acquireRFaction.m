%% acquireRFactionCam
% v1.0 yuanhui 20190221 
% acquire fluorescent signal from camera in RF activation of cells
[DG4, DG4Info] = DG4_init();
[PmVid, PmSrc, PmSrcInfo] = Pm_init();

%% setup camera
PmSrc.Exposure        =   100; % 0-10000 for both ms and us; 1 us required by camera to synchronize
PmSrc.ExpRes          = 'ms'; % 'ms' or 'us'
PmSrc.Binning = '1x1'; % '2x2' makes no sense for sCMOS hoping reduced read noise
PmSrc.Offset          = 185; 
PmPreview = preview(PmVid);
pause(3)
PmVid.ROIPosition = Pm_selectROI(PmVid,PmPreview,'Manual'); % 'Full', 'Half', 'Manual', 'Keep'
% PmVid.ROIPosition = [0 200 2048 1648];% set FOV; for CMOS no need to trim horizontal
PmSrc.AutoContrast = 'ON';
PmSrc.TriggerMode = 'Internal Trigger'; % 'Internal Trigger' 'Edge Trigger' or 'Trigger First'

stoppreview(PmVid);

PmSrcInfo = get(getselectedsource(PmVid));

%% setup DG4 
% 100, 200, 500, 1000, 2000, 5000Hz for all
% transducers, except that maximum PRF is internally
% limited to: 2000Hz for 0.5MHz transducers, 1000Hz
% for 0.25MHz transducers, and 500Hz for 0.1MHz
% transducers.
FIDInfo.PRRHz = 2000; % if >10e3 Hz FID breaks
if FIDInfo.PRRHz > 10e3    FIDInfo.PRRHz = 10e3;    end
RFaction.nCycles = 2.5;

DG4Info.PeriodActionSec    = 5; % seconds
DG4Info.PeriodRestSec      = 25; % seconds
DG4Info.PeriodSec          = DG4Info.PeriodActionSec + DG4Info.PeriodRestSec; % seconds
DG4Info.DutyCycle          = round(100 * (DG4Info.PeriodRestSec / (DG4Info.PeriodActionSec+DG4Info.PeriodRestSec))); % percentage


% Channel 1
DG4Info.RF_Channel = 1;
DG4Info.RF_Freq = FIDInfo.PRRHz; % Hz
DG4Info.RF_WaveShapeStr = 'PULSe'; % SINusoid|SQUare|RAMP|PULSe|NOISe|USER| etc
DG4Info.RF_PulseWidth = 100e-9; % second. FPG triggers on 100 ns 5V TTL; DG4 accepts 0.3125% of period
DG4Info.RF_DutyCycle = 0.315; % % in percentage
DG4Info.RF_Delay = 0; % second
if DG4Info.RF_PulseWidth<1./DG4Info.RF_Freq
    DG4Info.RF_PulseWidth = 1./DG4Info.RF_Freq .* 0.315 ./ 100;
end
DG4Info.RF_High = 5; % Volt. FPG triggers on 100 ns 5V TTL
DG4Info.RF_Low = 0; % Volt
DG4Info.RF_Amplitude = 5; % Vpp.
DG4Info.RF_Offset = 2.5; % Volt.

% Channel 2
DG4Info.Scope_Channel = 2;
DG4Info.Scope_WaveShapeStr = 'PULSe'; % SINusoid|SQUare|RAMP|PULSe|NOISe|USER| etc
DG4Info.Scope_DutyCycle = DG4Info.DutyCycle ; % % in percentage

DG4Info.Scope_High = 5; % Volt. FPG triggers on 100 ns 5V TTL
DG4Info.Scope_Low = 0; % Volt

DG4_setRFact(DG4, DG4Info);

% 
trig_output(DG4, 'OFF', DG4Info.RF_Channel);
trig_output(DG4, 'OFF', DG4Info.Scope_Channel);
% trig_output(DG4, 'ON', DG4Info.Scope_Channel);
% trig_output(DG4, 'ON', DG4Info.RF_Channel);
%%
trig_output2Chan(DG4, 'ON', DG4Info);

%%
trig_output2Chan(DG4, 'OFF', DG4Info);


%% Sample name
FileName = 'Gcamp6s20xFish3dpf_8kV'; % eg 'Gcamp6s20xFish10dpf_8kV'
FileName = [FileName num2str(FIDInfo.PRFHz) 'PRF' ...
    '_Act' num2str(DG4Info.PeriodActionSec) ...
    'Rest' num2str(DG4Info.PeriodActionSec) 's' ...
    num2str(RFaction.nCycles) 'cycl']; 

%% run 1 Background - Dark
trig_output(DG4, 'OFF', DG4Info.RF_Channel);
trig_output(DG4, 'OFF', DG4Info.Scope_Channel);
SaveMeasName = [FileName '_DARK']; 

% % long video required, but fps halved as fastest memory logging
stoppreview(PmVid);
TiffSavingPath = makeVideoDir('C:\Pictures\', 'Long', SaveMeasName);
PmSrc.StreamSavingPath = TiffSavingPath;
PmSrc.AutoContrast = 'OFF';
% PmSrc.FanSpeed = 'Off(Liquid Cooled)'; 
pause(2)
PmSrc.StreamAcquisition = 'TIFF'; % 'OFF', 'RAW' or 'TIFF' % disk stream give 50 frames/s
% PmPreview = preview(PmVid);
% stoppreview(PmVid)
flushdata(PmVid);
warning('off');
% % using timmer of camera to stop image acquisition
PmVid.TimerPeriod = RFaction.nCycles * DG4Info.PeriodSec; % seconds, calculate the period can take in order not to exceed memory

start(PmVid); tStart = tic; 

% pause(PmVid.TimerPeriod)

%% % Stop acquisition MANNUALLY. Don't need if specified frames*triggers
stop(PmVid); 
% tElapsed = toc(tStart)
disp(lastwarn); warning('on'); 
PmSrc.StreamAcquisition = 'OFF'; % 'OFF', 'RAW' or 'TIFF'
% PmSrc.FanSpeed         = 'HIGH'; 
PmSrc.AutoContrast = 'ON';
PmPreview = preview(PmVid);

PmSrcInfo = get(getselectedsource(PmVid));
tElapsed = (PmVid.UserData)
save([TiffSavingPath datestr(now,'yyyymmdd') '_'...
    SaveMeasName '_' num2str(PmSrcInfo.Exposure) PmSrcInfo.ExpRes '_'...
    num2str(round(length(dir([TiffSavingPath '*F_PV*']))/(tElapsed))) 'fps' '_Meta.mat'],...
    'PmSrcInfo');

%% %% run 2 Stimulation
SaveMeasName = [FileName '_RFon']; 
trig_output(DG4, 'ON', DG4Info.Scope_Channel);
% trig_output(DG4, 'OFF', DG4Info.RF_Channel);
% % long video required, but fps halved as fastest memory logging
% stoppreview(PmVid);
TiffSavingPath = makeVideoDir('C:\Pictures\', 'Long', SaveMeasName);
PmSrc.StreamSavingPath = TiffSavingPath;
PmSrc.AutoContrast = 'OFF';
% PmSrc.FanSpeed = 'Off(Liquid Cooled)'; 
pause(2)
PmSrc.StreamAcquisition = 'TIFF'; % 'OFF', 'RAW' or 'TIFF' % disk stream give 50 frames/s
% PmPreview = preview(PmVid);
stoppreview(PmVid)
flushdata(PmVid);
warning('off');
% % using timmer of camera to stop image acquisition
PmVid.TimerPeriod = RFaction.nCycles * DG4Info.PeriodSec; % seconds, calculate the period can take in order not to exceed memory
trig_output(DG4, 'ON', DG4Info.RF_Channel);
pause(2)
start(PmVid); tStart = tic; 

% pause(PmVid.TimerPeriod)

%% Stop acquisition MANNUALLY. Don't need if specified frames*triggers
stop(PmVid); 
trig_output(DG4, 'OFF', DG4Info.RF_Channel);
trig_output(DG4, 'OFF', DG4Info.Scope_Channel);
% tElapsed = toc(tStart);
disp(lastwarn); warning('on'); 
PmSrc.StreamAcquisition = 'OFF'; % 'OFF', 'RAW' or 'TIFF'
% PmSrc.FanSpeed         = 'HIGH'; 
PmSrc.AutoContrast = 'ON';
PmPreview = preview(PmVid);

PmSrcInfo = get(getselectedsource(PmVid));
tElapsed = (PmVid.UserData)
save([TiffSavingPath datestr(now,'yyyymmdd') '_'...
    SaveMeasName '_' num2str(PmSrcInfo.Exposure) PmSrcInfo.ExpRes '_'...
    num2str(round(length(dir([TiffSavingPath '*F_PV*']))/(tElapsed))) 'fps' '_Meta.mat'],...
    'PmSrcInfo');

%%
stoppreview(PmVid);

%%
trigger_close(DG4);
Pm_close(PmVid);
