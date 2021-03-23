% function [S1, S2, tt_us, z_] = acquireMulRecAvgRSOM_50MHz(PI,DAQ,z0)
% **************************************************************************
%% init
% mstart; DAQ=gageInit; [DG4, DG4Info] = DG4_init_test();

%%
Return = trig_sysClockSource(DG4,'EXT');
trig_burstEnable(DG4,1,1);
Return = trig_burstMode(DG4,'TRIGgered');
trig_burstNcycles(DG4,10);
trig_burstNcyclesDelay(DG4,0e-6);
trig_burstTriggerOnEdge(DG4,1);
Return = trig_burstMode(DG4,'TRIGgered');
Return = trig_burstTriggerSource(DG4,'EXTernal',1);
Return = trig_burstMode(DG4,'TRIGgered');
% trig_burstEnable(DG4,1,1);

%% 
% dbstop if error
Flag.isRSOM   = 0; % % Continuous is only ~20% faster than discrete scan, but require continuous RF PULSING !!!!
FovInfo.isSnake = 0;
Flag.isSendEmail   = 0;
Flag.isPlot   = 1;
Flag.isFilter = 1; % 1 for temporal; 2 for spatial
% AcqInfo.detType    = 'TAM50'; % TAM50 uses V3330. TAM100 uses HFM26
AcqInfo.detType    = 'TAM50'; % TAM50 uses V3330. TAM100 uses HFM26
% SampleName = 'OpenCPS_randomFish_US100V5kHz39dB';
SampleName = 'OilLine_SutureBraidedTube';
if Flag.isRSOM   == 1
    SampleName = ['R' AcqInfo.detType '_' SampleName];
elseif Flag.isRSOM   == 0
    SampleName = [AcqInfo.detType '_' SampleName];
end

% %% setup DG4 
% [DG4, DG4Info] = DG4_init();
% 100, 200, 500, 1000, 2000, 5000Hz for all transducers, 
% except that maximum PRF is internally limited to: 
% 2000Hz for 0.5MHz transducers, 1000Hz for 0.25MHz transducers, and 500Hz for 0.1MHz transducers.
FIDInfo.PRRHz = 261.63; % if >10e3 Hz FID breaks; CS12502 can take <2kHz PRR only
% FIDInfo.PRRHz = 100; % if >10e3 Hz FID breaks; CS12502 can take 2kHz PRR only
if FIDInfo.PRRHz > 10e3    FIDInfo.PRRHz = 10e3;    end
RFaction.nCycles = 2.5;

DG4Info.PeriodActionSec    = 5; % seconds
DG4Info.PeriodRestSec      = 25; % seconds
DG4Info.PeriodSec          = DG4Info.PeriodActionSec + DG4Info.PeriodRestSec; % seconds
DG4Info.DutyCycle          = round(100 * (DG4Info.PeriodRestSec / (DG4Info.PeriodActionSec+DG4Info.PeriodRestSec))); % percentage


% Channel 1
DG4Info.RF_Channel = 1;
DG4Info.RF_Freq = FIDInfo.PRRHz; % Hz
DG4Info.RF_WaveShapeStr = 'SINusoid'; % SINusoid|SQUare|RAMP|PULSe|NOISe|USER| etc
DG4Info.RF_PulseWidth = 100e-9; % second. FPG triggers on 100 ns 5V TTL; DG4 accepts 0.3125% of period
DG4Info.RF_DutyCycle = 0.315; % % in percentage
DG4Info.RF_Delay = 0; % second
if DG4Info.RF_PulseWidth<1./DG4Info.RF_Freq
    DG4Info.RF_PulseWidth = 1./DG4Info.RF_Freq .* 0.315 ./ 100;
end
DG4Info.RF_High = 7; % Volt. FPG triggers on 100 ns 5V TTL
DG4Info.RF_Low = 0; % Volt
DG4Info.RF_Amplitude = 7; % Vpp.
DG4Info.RF_Offset = DG4Info.RF_Amplitude/2; % Volt.

% Channel 2
DG4Info.Scope_Channel = 2;
DG4Info.Scope_WaveShapeStr = 'SQUare'; % SINusoid|SQUare|RAMP|PULSe|NOISe|USER| etc
DG4Info.Scope_DutyCycle = DG4Info.DutyCycle ; % % in percentage

DG4Info.Scope_High = 7; % Volt. FPG triggers on 100 ns 5V TTL
DG4Info.Scope_Low = 0; % Volt

DG4Info.nImpedanceOhm = 10e3;

if Flag.isRSOM == 1
    DG4Info.GatedPolarity = 'NORMal';  % NORMal INVerted
    DG4Info.BurstEnable = false;    % 20190411 don't use due to sychronization timing issue between PI and DAQ, HWavg delay underterminable.
elseif Flag.isRSOM == 0
%     DG4Info.GatedPolarity = 'INVerted';  % NORMal INVerted
    DG4Info.GatedPolarity = 'NORMal';  % NORMal INVerted
    DG4Info.BurstEnable = true;
end
% trigger_setRFact(DG4, DG4Info);

%%
DG4Info.Scope_Channel = 2;
DG4Info.Scope_Freq = FIDInfo.PRRHz; % Hz
DG4Info.Scope_WaveShapeStr = 'SQUare'; % SINusoid|SQUare|RAMP|PULSe|NOISe|USER| etc
DG4Info.Scope_PulseWidth = 100e-9; % second. FPG triggers on 100 ns 5V TTL; DG4 accepts 0.3125% of period
DG4Info.Scope_DutyCycle = 0.315; % % in percentage
DG4Info.Scope_Delay = 0; % second
if DG4Info.Scope_PulseWidth<1./DG4Info.Scope_Freq
    DG4Info.Scope_PulseWidth = 1./DG4Info.Scope_Freq .* 0.315 ./ 100;
end
DG4Info.Scope_High = 7; % Volt. FPG triggers on 100 ns 5V TTL
DG4Info.Scope_Low = 0; % Volt
DG4Info.Scope_Amplitude = 7; % Vpp.
DG4Info.Scope_Offset = DG4Info.Scope_Amplitude/2; % Volt.
%
trig_function(DG4, DG4Info.Scope_WaveShapeStr, DG4Info.Scope_Channel);
trig_frequency(DG4, DG4Info.Scope_Freq, DG4Info.Scope_Channel);
trig_pulseWidth(DG4, DG4Info.Scope_PulseWidth, DG4Info.Scope_Channel);
% trig_pulseDcycle(DG4, DG4Info.Scope_DutyCycle, DG4Info.Scope_Channel);
trig_pulseDelay(DG4, DG4Info.Scope_Delay, DG4Info.Scope_Channel);
trig_pulseHold(DG4, 'DUTY', DG4Info.Scope_Channel); % WIDTh|DUTY
trig_pulseLeading(DG4, 0.0*DG4Info.Scope_PulseWidth, DG4Info.Scope_Channel); % leading/falling edge time  ? 0.625 × pulse width
trig_pulseTrailing(DG4, 0.0*DG4Info.Scope_PulseWidth, DG4Info.Scope_Channel); % leading/falling edge time  ? 0.625 × pulse width
trig_voltageUnit(DG4, 'VPP', DG4Info.Scope_Channel);

trig_outputImpedance(DG4,10000,DG4Info.Scope_Channel);

trig_voltageHigh(DG4, DG4Info.Scope_High, DG4Info.Scope_Channel);
trig_voltageLow(DG4, DG4Info.Scope_Low, DG4Info.Scope_Channel);
trig_voltageAmplitude(DG4, DG4Info.Scope_Amplitude, DG4Info.Scope_Channel);
trig_voltageOffset(DG4, DG4Info.Scope_Offset, DG4Info.Scope_Channel);
%

% trig_output(DG4, 'OFF', DG4Info.Scope_Channel);
% trig_output(DG4, 'OFF', DG4Info.RF_Channel);
pause(1)


% pause(1);
% trig_burstEnable(DG4,false,DG4Info.RF_Channel);
% trig_burstEnable(DG4,true,DG4Info.RF_Channel);

% trig_output(DG4, 'ON', DG4Info.Scope_Channel);
% trig_output(DG4, 'ON', DG4Info.RF_Channel);
% trig_output2Chan(DG4, 'ON', DG4Info);

%%
% DAQ=gageInit; pause(2);
CsMl_AbortCapture(DAQ);
% [ret, sysInfo] = CsMl_GetSystemInfo(DAQ); CsMl_ErrorHandler(ret, 1, DAQ);
% [ret, AcqInfo] = CsMl_QueryAcquisition(DAQ); CsMl_ErrorHandler(ret, 1, DAQ);
% for i = 1:sysInfo.ChannelCount
%    [ret, ChanInfo(i)] = CsMl_QueryChannel(DAQ, i);
%    CsMl_ErrorHandler(ret, 1, DAQ);
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Changing FPGA image require reset of DAQ % 
% Using FPGA image, problems happen with External Trigger Setup % 
% HWAvg works only with Dual Acq, Trigger Source Ch1-2, InputRange 2000 FSIR %
AcqInfo.isUsingHWAvg = false; % 20200819 conclusion - no SNR improvement! 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% InputRange of 2 channels should be the same
AcqInfo.InputRange = 100; % mV %% MulRecAvg allows 1000 | 200 | 100 mV
ChanInfo(1).InputRange  = AcqInfo.InputRange * 2 ;% FSIR 2 * [mV] 5000, 2000, 1000, 500, 200, 100
ChanInfo(2).InputRange  = 5000 * 2;% FSIR 2 * [mV] 5000, 2000, 1000, 500, 200, 100
% AcqInfo.t_0 = 4.3e-6; AcqInfo.t_end = 6e-6;    % us HFM18=3.4us/1.7us % HFM26=3/3mm z0=1.9 5.18us/2.59us
AcqInfo.t_0     = 0e-6;  
AcqInfo.t_end   = 22e-6;    % us V3330 6/6.35mm F@8.65   [8.1 9.1] - [16.2 18.2]
AcqInfo.nAvg    = 100; % number of averages % HWavg use 2^n, n=123489-10, n=567-10 generates noise
AcqInfo.isAvg   = true;
AcqInfo.isUsingChan = 0; % 0 for 2 channels acquisition
if AcqInfo.isUsingChan == 0
    AcqInfo.nChan = 2;
else
    AcqInfo.nChan = 1;
end

AcqInfo.nHWAvg_Allowed = 1024;
if AcqInfo.isUsingHWAvg == true
    disp('Using hardware MulRecAvg FPGA image. FSIR can ONLY be 1000 mV.');
%     if (AcqInfo.InputRange == 500) || (AcqInfo.InputRange == 2000) || (AcqInfo.InputRange == 5000)
    AcqInfo.InputRange = 1000; % mV
%         disp('FSIR CANNOT be 5000 | 2000 | 500 mV. Changed to 1000 mV.');
%     end
    ChanInfo(1).InputRange  = AcqInfo.InputRange * 2 ;% FSIR 2 * [mV] 5000, 2000, 1000, 500, 200, 100
    ChanInfo(2).InputRange  = AcqInfo.InputRange * 2 ;% FSIR 2 * [mV] 5000, 2000, 1000, 500, 200, 100
    if AcqInfo.nAvg <= AcqInfo.nHWAvg_Allowed
        AcqInfo.nHWAvg = AcqInfo.nAvg; % number of hard averages; Changing hard avg requires freeGage
        AcqInfo.nSWAvg = 1;
    elseif AcqInfo.nAvg > AcqInfo.nHWAvg_Allowed
        AcqInfo.nHWAvg = AcqInfo.nHWAvg_Allowed; % number of hard averages; Changing hard avg requires freeGage
        AcqInfo.nSWAvg = ceil((AcqInfo.nAvg)/AcqInfo.nHWAvg); % number of hard averages; Changing hard avg requires freeGage
        AcqInfo.nAvg = AcqInfo.nSWAvg * AcqInfo.nHWAvg;
        disp(['nAvg is updated to be ' num2str(AcqInfo.nAvg)]);
    end
elseif AcqInfo.isUsingHWAvg == false
    disp('NOT using hardware averaging multi-record FPGA image');
    AcqInfo.nHWAvg = 0; 
    AcqInfo.nSWAvg = AcqInfo.nAvg;
end
AcqInfo.tStampOn    = 1;
AcqInfo.rawData     = 0;
AcqInfo.acqMode     = CsMl_Translate('Dual', 'Mode'); % Single | Dual acquisition code. When in Single mode, the other chan cannot be used as trigger source
AcqInfo.TriggerTimeout  = 10e6;   %  % Wait until trigger arrives [us] (-1 = inf). 0 for immediate trigger when acquisition starts
AcqInfo.TimeStampConfig = CsMl_Translate('FixedClock', 'TimeStamp');  
AcqInfo.Fs          = 500e6; % % 500, 125, 50, 25, 10, 5, 2.5, 1 MS/s, 500, 250, 100, 50, 25, 10, 5, 2.5, 1 kS/s
AcqInfo.dt          = 1/AcqInfo.Fs;

%% **************************************************************************
% All dimensions are in mm
FovInfo.x0 = 31.46;    % CPS 100MHz/3/3mm 10
FovInfo.y0 = 30;   % CPS 100MHz/3/3mm 20.9
FovInfo.z0 = 35.5250-1.0+0.5+0.5+0.15-0.75-0.3-0.15+0.5+0.5+0.6+0.15-0.3-0.45;

FovInfo.Lx = 3; % 4
FovInfo.Ly = 1.5; % 1.3
FovInfo.Lz = 0;

FovInfo.ds = 0.02; % mm
FovInfo.dx = FovInfo.ds * 1;
FovInfo.dy = FovInfo.ds * 1;
FovInfo.dz = FovInfo.ds * 1;

if ~isequal(rem(FovInfo.Lx,FovInfo.dx),0)
    FovInfo.Lx = ceil(FovInfo.Lx/FovInfo.dx)*FovInfo.dx;
end
if ~isequal(rem(FovInfo.Ly,FovInfo.dy),0)
    FovInfo.Ly = ceil(FovInfo.Ly/FovInfo.dy)*FovInfo.dy;
end

FovInfo.xLim = [FovInfo.x0-FovInfo.Lx/2 FovInfo.x0+FovInfo.Lx/2];
FovInfo.yLim = [FovInfo.y0-FovInfo.Ly/2 FovInfo.y0+FovInfo.Ly/2];

[X,Y] = generateSequence(FovInfo.xLim, FovInfo.yLim, FovInfo.dx, FovInfo.dy, FovInfo.isSnake);
FovInfo.Nx    = size(X,1);                                                         % Number of TD x positions
FovInfo.Ny    = size(X,2);                                                         % Number of TD y positions
FovInfo.Ntot  = FovInfo.Nx * FovInfo.Ny;
if Flag.isRSOM == 1
    positionXY = zeros(FovInfo.Nx*FovInfo.Ny,1);
elseif Flag.isRSOM == 0
    positionXY = zeros(FovInfo.Nx*FovInfo.Ny,4);
end

% FovInfo.swapXY = ~FovInfo.Ly;                     % 1: y-axis fast axis. 0: x-axis fast axis
FovInfo.swapXY = 0;                     % 1: y-axis fast axis. 0: x-axis fast axis
if FovInfo.swapXY
    PI2.X = PI.Y; PI2.Y = PI.X; 
    PI.X = PI2.X; PI.Y = PI2.Y;
    
    Intermediate = FovInfo.x0;
    FovInfo.x0 = FovInfo.y0;
    FovInfo.y0 = Intermediate;

    Intermediate = FovInfo.Lx;
    FovInfo.Lx = FovInfo.Ly;
    FovInfo.Ly = Intermediate;
    
    Intermediate = FovInfo.dx;
    FovInfo.dx = FovInfo.dy;
    FovInfo.dy = Intermediate;

    clear intermediate PI2;
end

[FovInfo.xAct, FovInfo.yAct, FovInfo.zAct] = pi3xGetPosition(PI);    % Get position of the stages
FovInfo.vAct = 50;%mm/s                               % max 50 for M-404, max 350 for M-683 Set velocity of the stages
FovInfo.xAct = FovInfo.xLim(1);
FovInfo.yAct = Y(1);
piSetVel(PI.X, FovInfo.vAct);
piSetVel(PI.Y, FovInfo.vAct);
piSetVel(PI.Z, FovInfo.vAct);

AcqInfo.direction = +1;
piMoveAbs(PI.X,FovInfo.xLim(1));    % pause(1);
piMoveAbs(PI.Y,Y(1));               % pause(1);
piMoveAbs(PI.Z,FovInfo.z0);         % pause(1);

while pi2xOnTargetState(PI) == 0 ; end 
if Flag.isRSOM == 1
    % 2 is a magic number to synchronize pi stages and gage
    MagicNumber2SyncPI2DAQ = 2; % default 2
    FovInfo.xvAct = floor(1e4*((FIDInfo.PRRHz/AcqInfo.nHWAvg) * (FovInfo.Lx / (1+FovInfo.Nx))) / MagicNumber2SyncPI2DAQ )/1e4; % floor to slower the speed to 1. ensure enough no. pulses 2. PI accepts 0.0001 digit
    FovInfo.yvAct = floor(1e4*((FIDInfo.PRRHz/AcqInfo.nHWAvg) * (FovInfo.Ly / (1+FovInfo.Ny))) / MagicNumber2SyncPI2DAQ )/1e4;%mm/s                               % max 50 for M-404, max 350 for M-683 Set velocity of the stages
    FovInfo.zvAct = FovInfo.vAct;%mm/s                               % max 50 for M-404, max 350 for M-683 Set velocity of the stages
elseif Flag.isRSOM == 0
    FovInfo.xvAct = 200;%mm/s      % max 200 for smooth trigger signals    % max 50 for M-404, max 350 for M-683 Set velocity of the stages
    FovInfo.xvAct = 50;%mm/s
    FovInfo.yvAct = 50;%mm/s                               % max 50 for M-404, max 350 for M-683 Set velocity of the stages
    FovInfo.zvAct = FovInfo.yvAct;%mm/s                               % max 50 for M-404, max 350 for M-683 Set velocity of the stages
end

piSetVel(PI.X, FovInfo.xvAct);
piSetVel(PI.Y, FovInfo.yvAct);
piSetVel(PI.Z, FovInfo.vAct);

FovInfo.xvAct = piGetVel(PI.X);                                                   % Get real velocity of the stages
FovInfo.yvAct = piGetVel(PI.Y);                                                   % Get real velocity of the stages
FovInfo.zvAct = piGetVel(PI.Z);                                                   % Get real velocity of the stages

FovInfo.xaccAct = piGetAcc(PI.X);                                                 % Get Acceleration  of the stages
FovInfo.xdecAct = piGetDec(PI.X);                                                 % Get Decceleration of the stages
FovInfo.yaccAct = piGetAcc(PI.Y);                                                 % Get Acceleration  of the stages
FovInfo.ydecAct = piGetDec(PI.Y);                                                 % Get Decceleration of the stages
FovInfo.zaccAct = piGetAcc(PI.Z);                                                 % Get Acceleration  of the stages
FovInfo.zdecAct = piGetDec(PI.Z);                                                 % Get Decceleration of the stages

piEnableTrigOut(PI.X, 2); % TrigOutID 1-4 to line 5-8
piConfigTrigOut(PI.X);
piEnableTrigOut(PI.Y, 2);
piConfigTrigOut(PI.Y);
piEnableTrigOut(PI.Z, 2);
piConfigTrigOut(PI.Z);


% to do - not possible with HWAvg because it can only work at 1000 mV scale
% auto scale %SigRange2Scale = [4000 5700]; % TA - [4000 5700], US - [4000 5700]

%% DAQ
if Flag.isRSOM == 1
    AcqInfo.SegmentCount    = FovInfo.Nx;
elseif Flag.isRSOM == 0
    AcqInfo.SegmentCount    = AcqInfo.nSWAvg;
end
AcqInfo.acqRes      = 32; % the sampling unit is 32 samples block for CS12502
AcqInfo.nBlockinSegment  = ceil((AcqInfo.t_end-AcqInfo.t_0)*AcqInfo.Fs/AcqInfo.acqRes);
if AcqInfo.t_0 < 0
    AcqInfo.TriggerHoldoff = -AcqInfo.t_0 * AcqInfo.Fs; % number of samples pre-trigger
    AcqInfo.TriggerDelay   = 0;
    AcqInfo.SegmentSize    = AcqInfo.nBlockinSegment * AcqInfo.acqRes;
    AcqInfo.Depth          = AcqInfo.SegmentSize - AcqInfo.TriggerHoldoff;
elseif AcqInfo.t_0 >= 0
    AcqInfo.TriggerHoldoff = 0;
    AcqInfo.TriggerDelay   = AcqInfo.t_0 * AcqInfo.Fs;
    AcqInfo.Depth          = AcqInfo.nBlockinSegment * AcqInfo.acqRes;
    AcqInfo.SegmentSize    = AcqInfo.Depth;
end
if AcqInfo.TriggerHoldoff
    tt = [(-AcqInfo.TriggerHoldoff+1)*AcqInfo.dt:AcqInfo.dt:(AcqInfo.Depth)*AcqInfo.dt];
elseif AcqInfo.TriggerDelay
    tt = [(AcqInfo.TriggerDelay+1)*AcqInfo.dt:AcqInfo.dt:(AcqInfo.Depth+AcqInfo.TriggerDelay)*AcqInfo.dt];
else
    tt = [(-AcqInfo.TriggerHoldoff+1)*AcqInfo.dt:AcqInfo.dt:(AcqInfo.Depth)*AcqInfo.dt];
end
tt_us = tt.*1e6;   
z_ = (tt).*1510e6;

% 
[ret, AcqInfo, ChanInfo, TrigInfo] = gageSetup_TAM_SW(DAQ, AcqInfo, ChanInfo); % Set acquisition, channel and trigger parameters
[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);
AcqInfo.SampleOffset = acqInfo.SampleOffset;
AcqInfo.DcOffset = 0;
AcqInfo.ChannelCount = AcqInfo.nChan; 
% [ret, AcqInfo, ChanInfo, TrigInfo] = gageCoerce(DAQ, AcqInfo, ChanInfo, 1, 0);
% if ret < 1
% %     trig_output(DG4, 'OFF', DG4Info.RF_Channel);
%     DAQ=gageInit;
%     error('DAQ config failed. Restarted.');
% end
%%
% % %%
piSetVel(PI.X, FovInfo.vAct);
piSetVel(PI.Y, FovInfo.vAct);
piSetVel(PI.Z, FovInfo.vAct);
piMoveAbs(PI.X,FovInfo.xLim(1));    % pause(1);
piMoveAbs(PI.Y,FovInfo.yLim(1));               % pause(1);
piMoveAbs(PI.Z,FovInfo.z0);         % pause(1);
while pi2xOnTargetState(PI) == 0 ; end 
% 
% %%
% piEnableTrigOut(PI.X, 1);
% piConfigTrigOut(PI.X);
% piEnableTrigOut(PI.Y, 1);
% piConfigTrigOut(PI.Y);
% 
% FovInfo.xvAct = floor(1e4*((FIDInfo.PRRHz/AcqInfo.nHWAvg) * (FovInfo.Lx / (1+FovInfo.Nx))) / 2 )/1e4; % floor to slower the speed to 1. ensure enough no. pulses 2. PI accepts 0.0001 digit
% FovInfo.yvAct = FovInfo.xvAct;%mm/s                               % max 50 for M-404, max 350 for M-683 Set velocity of the stages
% FovInfo.zvAct = FovInfo.vAct;%mm/s                               % max 50 for M-404, max 350 for M-683 Set velocity of the stages
% 
% piSetVel(PI.X, FovInfo.xvAct);
% piSetVel(PI.Y, FovInfo.yvAct);
% piSetVel(PI.Z, FovInfo.vAct);
% 
% FovInfo.xvAct = piGetVel(PI.X);                                                   % Get real velocity of the stages
% FovInfo.yvAct = piGetVel(PI.Y);                                                   % Get real velocity of the stages
% FovInfo.zvAct = piGetVel(PI.Z);  
%
if (AcqInfo.isAvg == false) && (Flag.isRSOM == 0)
    S = zeros(FovInfo.Nx*FovInfo.Ny,AcqInfo.SegmentSize, AcqInfo.SegmentCount, AcqInfo.nChan);                                                     % Initialize Signal Matrix
elseif (AcqInfo.isAvg == true) && (Flag.isRSOM == 0)
    S = zeros(FovInfo.Nx*FovInfo.Ny,AcqInfo.SegmentSize, 1, AcqInfo.nChan);                                                     % Initialize Signal Matrix
elseif  (Flag.isRSOM == 1)
    S = zeros(FovInfo.Nx*FovInfo.Ny,AcqInfo.SegmentSize, 1, AcqInfo.nChan);         
end

counter =0;
Elapse = 0;  % Start internal clock

if FovInfo.Ntot > 50000
    NPrint   = 50;
else
    NPrint = 1;
end

bScanPause = 0.1;                             % To get rid of vibrations
t_tot = diff(FovInfo.xLim)/FovInfo.xvAct;
fprintf('\n**********************************************\n');
fprintf('Sampling rate is: \t\t\t\t %g MSps\n', AcqInfo.Fs/1e6);
fprintf('Number of Measurements: \t\t %i \n', FovInfo.Ntot);
fprintf('Estimated Measurement Time: \t %.3g minutes\n', FovInfo.Ny*(diff(FovInfo.xLim)/FovInfo.xvAct + bScanPause)/60);
fprintf('Start time is:\t\t\t\t\t %s', datestr(now,'HH:MM:SS'));
fprintf('\n**********************************************\n\n');
if exist('h_figure1')
    h_figure1 = h_figure1 +1;
else
    h_figure1 = 1000; 
end
figure(h_figure1);     clf(h_figure1);  hold off;

% trig_burstEnable(DG4,true,DG4Info.RF_Channel);
% trig_burstEnable(DG4,false,DG4Info.RF_Channel);
% trig_burstEnable(DG4,false,DG4Info.RF_Channel);
% trig_output(DG4, 'ON', DG4Info.RF_Channel);
% trig_output(DG4, 'OFF', DG4Info.RF_Channel);
% trig_DisplaySaverEnable(DG4,1);
% trig_DisplaySaverImmediate(DG4);

CsMl_ResetTimeStamp(DAQ);  % Reset the time stamp counter so we start at 0

trig_output(DG4, 'ON', DG4Info.Scope_Channel);

pause(1);
%%
tic;   
%
% If the scan does not work, try to config the PI trigger output from
% PIMikroMove app.
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%
couter=0;
if Flag.isRSOM == 1
    for i = 1:FovInfo.Ny
        if AcqInfo.direction > 0                      % Positive AcqInfo.direction
            if FovInfo.isSnake
                AcqInfo.direction = AcqInfo.direction*-1;
            end
    %         trig_output(DG4, 'ON', DG4Info.RF_Channel);
            if rem(i,NPrint) == 0
                fprintf('%6i \t B-Scan at %.5g \t Time left: %.3g minutes \n', ...
                        (i-1)*FovInfo.Nx+1, Y(i), (FovInfo.Ny-i)*(t_tot + bScanPause)/60);
            end

            pi2xMoveAbs(PI, FovInfo.xLim(2), Y(i));                                         % Move Stage to beginning of next y-Line                                                             % Time to start pause
    %         [FovInfo.xAct, FovInfo.yAct] = genPausePi([FovInfo.xLim(2), Y(i)], [FovInfo.xAct, FovInfo.yAct], FovInfo.yvAct);         % Pause the routine while moving to next position


            CsMl_ErrorHandler(CsMl_Capture(DAQ));                           % Start acquisition and await trigger event        
    %         while CsMl_QueryStatus(DAQ) ~= 1  ; pause(0.02); end                                  % Wait until measurement is done (status = 0)

            while CsMl_QueryStatus(DAQ) ~= 0  ; end                                  % Wait until measurement is done (status = 0)
    %         while piOnTargetState(PI.X) == 0 ; pause(0.5);  end 
    %         CsMl_AbortCapture(DAQ);

            if ~FovInfo.isSnake
                % Move to the next y-line
                piSetVel(PI.X, FovInfo.vAct);
                piSetVel(PI.Y, FovInfo.vAct);
                pause(0.01); 
        %         piMoveAbs(PI.X,FovInfo.xLim(1));    % pause(1);
                pi2xMoveAbs(PI, FovInfo.xLim(1), Y(i)+FovInfo.dy);
                while pi2xOnTargetState(PI) == 0 ; pause(0.01); end 
                piSetVel(PI.X, FovInfo.xvAct);
                piSetVel(PI.Y, FovInfo.yvAct);
                pause(0.01); 
            end

    %         trig_output(DG4, 'OFF', DG4Info.RF_Channel);
            % Fetch the data:
            [stemp, ~, tStamp] = gageAcqMulRecAvg2Chan_fast(DAQ,AcqInfo,ChanInfo);
            S((1+(i-1)*FovInfo.Nx):FovInfo.Nx*i,:,:,:) = permute(stemp, [2 1 3]);
            positionXY((1+(i-1)*FovInfo.Nx):FovInfo.Nx*i, 1) = tStamp*1e-6*FovInfo.xvAct;

            for iChan = 1:AcqInfo.nChan
                try set(0, 'currentfigure', h_figure1); catch figure(h_figure1); set(0, 'currentfigure', h_figure1); end
                subplot(AcqInfo.nChan, 1, iChan); hold on; 
                plot(tt_us,S(1,:,1,iChan));xlim([min(tt_us) max(tt_us)]);%ylim([-inputRange/1000/2 inputRange/1000/2]);
                if AcqInfo.nChan == 2
                    title(sprintf('Channel %d', iChan));
                elseif AcqInfo.nChan == 1
                    title(sprintf('Channel %d', AcqInfo.isUsingChan));
                end
                ylim([-ChanInfo(iChan).InputRange +ChanInfo(iChan).InputRange] .* 1.2 ./2 ./ 1000);
                grid on; grid minor;
            end
            xlim([min(tt_us) max(tt_us)]);
            xlabel('µs'); ylabel('Volt');
            drawnow;

        elseif AcqInfo.direction < 0                      % Negative AcqInfo.direction
            if FovInfo.isSnake
                AcqInfo.direction = AcqInfo.direction*-1;
            end
    %         trig_output(DG4, 'ON', DG4Info.RF_Channel);
            if rem(i,NPrint) == 0
                fprintf('%6i \t B-Scan at %.5g \t Time left: %.3g minutes \n', ...
                        (i-1)*FovInfo.Nx+1, Y(i), (FovInfo.Ny-i)*(t_tot + bScanPause)/60);
            end

    %         while CsMl_QueryStatus(DAQ) ~= 1  ; pause(0.02); end                                  % Wait until measurement is done (status = 0)

            pi2xMoveAbs(PI, FovInfo.xLim(1), Y(i));                                         % Move Stage to beginning of next y-Line                                                             % Time to start pause
    %         while pi2xOnTargetState(PI) == 0 ; end
    %         [FovInfo.xAct, FovInfo.yAct] = genPausePi([FovInfo.xLim(2), Y(i)], [FovInfo.xAct, FovInfo.yAct], FovInfo.yvAct);         % Pause the routine while moving to next position

            CsMl_ErrorHandler(CsMl_Capture(DAQ));                           % Start acquisition and await trigger event

            while CsMl_QueryStatus(DAQ) ~= 0  ; end                                  % Wait until measurement is done (status = 0)
    %         while piOnTargetState(PI.X) == 0 ; pause(0.5);  end 
    %         CsMl_AbortCapture(DAQ);

            if ~FovInfo.isSnake
                % Move to the next y-line
                piSetVel(PI.X, FovInfo.vAct);
                piSetVel(PI.Y, FovInfo.vAct);
                pause(0.01); 
        %         piMoveAbs(PI.X,FovInfo.xLim(1));    % pause(1);
                pi2xMoveAbs(PI, FovInfo.xLim(2), Y(i)+FovInfo.dy);
                while pi2xOnTargetState(PI) == 0 ; pause(0.01);  end 
                piSetVel(PI.X, FovInfo.xvAct);
                piSetVel(PI.Y, FovInfo.yvAct);
                pause(0.01); 
            end

    %         trig_output(DG4, 'OFF', DG4Info.RF_Channel);
            % Fetch the data:
            [stemp, ~, tStamp] = gageAcqMulRecAvg2Chan_fast(DAQ,AcqInfo,ChanInfo);
            S((1+(i-1)*FovInfo.Nx):FovInfo.Nx*i,:,:,:) = permute(stemp, [2 1 3]);
            positionXY((1+(i-1)*FovInfo.Nx):FovInfo.Nx*i, 1) = tStamp*1e-6*FovInfo.xvAct;
    %         S(FovInfo.Nx*i:-1:(1+(i-1)*FovInfo.Nx),:,:,:) = permute(stemp, [2 1 3]);
    %         positionXY(FovInfo.Nx*i:-1:(1+(i-1)*FovInfo.Nx), 1) = tStamp*1e-6*FovInfo.xvAct;

            for iChan = 1:AcqInfo.nChan
                try set(0, 'currentfigure', h_figure1); catch figure(h_figure1); set(0, 'currentfigure', h_figure1); end
                subplot(AcqInfo.nChan, 1, iChan); hold on; 
                plot(tt_us,S(1,:,1,iChan));xlim([min(tt_us) max(tt_us)]);%ylim([-inputRange/1000/2 inputRange/1000/2]);
                if AcqInfo.nChan == 2
                    title(sprintf('Channel %d', iChan));
                elseif AcqInfo.nChan == 1
                    title(sprintf('Channel %d', AcqInfo.isUsingChan));
                end
                ylim([-ChanInfo(iChan).InputRange +ChanInfo(iChan).InputRange] .* 1.2 ./2 ./ 1000);
                grid on; grid minor;
            end
            xlim([min(tt_us) max(tt_us)]);
            xlabel('µs'); ylabel('Volt');
            drawnow;
        end

    %     if FovInfo.Ny~=1
        fprintf('*');                                                  % Stop internal clock
    %     if i==FovInfo.Ny
        Elapse = Elapse + toc; 
        fprintf('%i \t %g sec\t Target position: %g \t %g \n', counter, Elapse, X(1,i), Y(i)); 
        tic;
    %     end
    %     end
    end

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5%%%    
elseif Flag.isRSOM == 0
    for i = 1:FovInfo.Ny
        j = 1;
        counter = counter + 1;

        pi2xMoveAbs(PI, X(j,i), Y(i));                                         % Move Stage to beginning of next y-Line                                                             % Time to start pause
    %     [FovInfo.xAct, FovInfo.yAct] = genPausePi([X(j,i), Y(i)], [FovInfo.xAct, FovInfo.yAct], FovInfo.yvAct);         % Pause the routine while moving to next position
    %     if FovInfo.swapXY %% In-Motion trigger only available at 
    %         while pi2xOnTargetState(PI) == 0 ; end

        if rem(i,20) == 0
            fprintf('%i \t Target position: %g \t %g \n', counter, X(j,i), Y(i));
        end

        CsMl_ErrorHandler(CsMl_Capture(DAQ));                           % Start acquisition and await trigger event
        while CsMl_QueryStatus(DAQ) ~= 0   end                                  % Wait until measurement is done (status = 0)

%         S(counter,:) = gageAcqAvg(DAQ, AcqInfo.rawData, AcqInfo.nAvg, AcqInfo.nHWAvg);                            % Acquire Signals
        S(counter,:,:,:) = gageAcqAvg2Chan_fast(DAQ,AcqInfo,ChanInfo);


        for iChan = 1:AcqInfo.nChan
            try set(0, 'currentfigure', h_figure1); catch figure(h_figure1); set(0, 'currentfigure', h_figure1); end
            subplot(AcqInfo.nChan, 1, iChan); hold on; 
            plot(tt_us,S(counter,:,1,iChan));xlim([min(tt_us) max(tt_us)]);%ylim([-inputRange/1000/2 inputRange/1000/2]);
            if AcqInfo.nChan == 2
                title(sprintf('Channel %d', iChan));
            elseif AcqInfo.nChan == 1
                title(sprintf('Channel %d', AcqInfo.isUsingChan));
            end
            ylim([-ChanInfo(iChan).InputRange +ChanInfo(iChan).InputRange] .* 1.2 ./2 ./ 1000);
            grid on; grid minor;
        end
        xlim([min(tt_us) max(tt_us)]);
        xlabel('µs'); ylabel('Volt');
        drawnow;


    %     [xAct, yAct] = pi2xGetPosition(pi);                                    % Get current position of the stage
    %     positionXY(counter,:) = [X(j,i), Y(i), FovInfo.xAct, FovInfo.yAct];

        for j = 2:FovInfo.Nx
            counter = counter + 1;

            pi2xMoveAbs(PI,X(j,i), 100);                                       % Move the stage to next x-position, don't move along y
    %         genPausePi([X(j,i), Y(i)], [FovInfo.xAct, FovInfo.yAct], FovInfo.yvAct);                    % Pause the stage while moving to next position
    %         while pi2xOnTargetState(PI) == 0 ; end

            CsMl_ErrorHandler(CsMl_Capture(DAQ), 1, DAQ);                           % Start acquisition and await trigger event
            while CsMl_QueryStatus(DAQ) ~= 0   end                                  % Wait until measurement is done (status = 0)

            S(counter,:,:,:) = gageAcqAvg2Chan_fast(DAQ,AcqInfo,ChanInfo);                         % Acquire Signals
            if FovInfo.Ny == 1     
                for iChan = 1:AcqInfo.nChan    
                    try set(0, 'currentfigure', h_figure1); catch figure(h_figure1); set(0, 'currentfigure', h_figure1); end
                    ax = subplot(AcqInfo.nChan, 1, iChan); hold on; 
                    plot(tt_us,S(counter,:,1,iChan));xlim([min(tt_us) max(tt_us)]);%ylim([-inputRange/1000/2 inputRange/1000/2]);
                    if AcqInfo.nChan == 2
                        title(sprintf('Channel %d', iChan));
                    elseif AcqInfo.nChan == 1
                        title(sprintf('Channel %d', AcqInfo.isUsingChan));
                    end
                    ylim([-ChanInfo(iChan).InputRange +ChanInfo(iChan).InputRange] .* 1.2 ./2 ./ 1000);
                    grid on; grid minor;
                end
                xlim([min(tt_us) max(tt_us)]);
                xlabel('µs'); ylabel('Volt');
                drawnow;
            end
    %         [xAct, yAct] = pi2xGetPosition(pi);                                % Get current position of the stage
            FovInfo.xAct = FovInfo.xAct+ FovInfo.dx;
            positionXY(counter,:) = [X(j,i), Y(i), FovInfo.xAct, FovInfo.yAct];

            if FovInfo.Nx~=1
                fprintf('*');
                if j==FovInfo.Nx
                    Elapse = Elapse + toc; 
                    fprintf('%i \t %g sec\t Target position: %g \t %g \n', counter, Elapse, X(j,i), Y(i));
                    tic;
                end
            end
        end
        if FovInfo.Ny~=1
            fprintf('*');                                                  % Stop internal clock
            if i==FovInfo.Ny
                Elapse = Elapse + toc; 
                fprintf('%i \t %g sec\t Target position: %g \t %g \n', counter, Elapse, X(j,i), Y(i)); 
                tic;
            end
        end
    end
end

trig_output(DG4, 'OFF', DG4Info.Scope_Channel);

    %%
% trig_output2Chan(DG4, 'OFF', DG4Info);
% trig_DisplaySaverEnable(DG4,0);
% freeGage(DAQ);
%
fprintf('Total elapsed time is %s seconds.\n', num2str(Elapse));

piSetVel(PI.X, FovInfo.vAct);
piSetVel(PI.Y, FovInfo.vAct);
piMoveAbs(PI.X,FovInfo.xLim(1));    % pause(1);
piMoveAbs(PI.Y,Y(1));               % pause(1);

if FovInfo.Lx==0
    SampleName2 = [SampleName '_' 'Yscan'];
elseif FovInfo.Ly==0
    SampleName2 = [SampleName '_' 'Xscan'];
else
    SampleName2 = [SampleName '_' 'RS'];
end
if strcmp(getenv('USERNAME'), 'yuanhui')
    savePath = 'C:\Users\yuanhui\MATLAB\TAM\Data\';
end
cdate = datestr(now,'yyyymmddHHMM');
FileName = [cdate '_' SampleName2 '_t' num2str(AcqInfo.t_0*1e9) '_' num2str(AcqInfo.t_end*1e9) 'ns' '_' 'AVG' num2str(AcqInfo.nAvg*AcqInfo.nHWAvg) '_z' num2str(FovInfo.z0*1000) 'um'];
% SaveName = isFileExisting(FileName,savePath);
SaveDat = [savePath, FileName];
% clear SampleName FileName SaveName
% freeGage(DAQ);                                                           % Free the system up
S1 = 0; S2 = 0;
if AcqInfo.isUsingChan == 0
    S1 = S(:,:,:,1); % separate Chan 1 data
    S2 = S(:,:,:,2); % separate Chan 2 data
elseif AcqInfo.isUsingChan == 1
    S1 = S(:,:,:,1); % separate Chan 1 data
    S2 = 0; % separate Chan 2 data
elseif AcqInfo.isUsingChan == 2
    S1 = 0; % separate Chan 1 data
    S2 = S(:,:,:,2); % separate Chan 2 data
end
save([SaveDat '.mat'], 'S1', 'S2', 'AcqInfo', 'ChanInfo', 'TrigInfo', 'FovInfo',...
    'tt', 'tt_us', '-v7.3');

if Flag.isPlot
    FovInfo.Ly = max(FovInfo.Ly, FovInfo.Lx);
    if exist('h_figure2')
        h_figure2=h_figure2+1;  
    else
        h_figure2=2000;  
    end
    figure(h_figure2); clf(h_figure2); hold off;
    
    for iChan = 1:AcqInfo.nChan
%         if Flag.isFilter
%            SS = filtS(S(:,:,1,iChan), AcqInfo.dt, FovInfo.ds, Flag.isFilter);
%         else
           SS = S(:,:,1,iChan);
%         end
        
        subplot(AcqInfo.nChan, 1, iChan); hold off;
        if FovInfo.Ny == 1
           imagesc(tt_us, [-FovInfo.Ly/2 : FovInfo.dy : FovInfo.Ly/2], abs(SS)); 
           colormap jet; colorbar; xlabel('\mus'); ylabel('mm'); grid on;
        else
           imagesc(tt_us, [-FovInfo.Ly/2 : FovInfo.ds : FovInfo.Ly/2], abs(SS)); 
           colormap jet; colorbar; xlabel('\mus'); ylabel('mm'); grid on;
        end
        if AcqInfo.nChan == 2
            title(sprintf('Channel %d', iChan));
        elseif AcqInfo.nChan == 1
            title(sprintf('Channel %d', AcqInfo.isUsingChan));
        end
%         axis image;
    end
end
% system('"C:\Program Files\SyncToy 2.1\SyncToyCmd.exe" "-R" "TAM_Data"')

% ans = load('train.mat','y'); sound(ans.y);
%%
Ratio = 1;
Flag.is_rsom = 0;
Flag.isCreateFolder = 0;
Flag.is_Tiff = 0;
Flag.RAW = 1; Flag.AF = 0; Flag.LF = 0; Flag.HF = 0;
% T1 = 7.5; T2 = 9.125;
% T1 = 8.3; T2 = 9.125;
% T1 = 8.4; T2 = 8.9;
% T1 = 5.1; T2 = 7.5;
% T1 = 9.0; T2 = 9.38;
T1 = 9.0; T2 = 9.1;
ezshow_rsom_Quick_2019(FileName,Ratio,T1, T2, Flag);
% ezshow_rsom_Quick_2019(FileName,Ratio,2*T1, 2*T2, Flag);
% 
% ezshow_rsom_Quick_2019('201904151917_TAM50_CPS_T2C20MHz_FishAgar30dpf_TopPositionAboveAirGap_TA10kV10kHz_RS_t0_25000ns_AVG1048576_z14150um',Ratio, T1, T2,Flag);
% ezshow_rsom_Quick_2019('201904051812_TAM50_OpenCPS_deadFish_US100V25dB_Yscan_t0_25000ns_AVG65536_z25000um',Ratio, 2*T1, 2*T2,Flag);
if Flag.isSendEmail  == 1
    addpath('C:\Users\yuanhui\MATLAB\Email-matlab');
    SendEmail_notification('yhhuang1987@gmail.com', 'TAM Scan', FileName);
end

%% Xcorr
% simpleXcorr;


