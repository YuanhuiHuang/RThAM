% function [S1, S2, tt_us, z_] = acquireSingleAvgScanGaGe_50MHz(PI,DAQ,z0)
% **************************************************************************
%% 
% dbstop if error
% DAQ=gageInit;
Flag.isRSOM   = 0;
Flag.isPlot   = 1;
Flag.isFilter = 2; % 1 for temporal; 2 for spatial
AcqInfo.detType    = 'TAM50'; % TAM50 uses V3330. TAM100 uses HFM26
% SampleName = 'OpenCPS_randomFish_US100V5kHz39dB';
SampleName = 'CPS_randomFishinPlastik_TA10kV1kHz';
SampleName = [AcqInfo.detType '_' SampleName];

[ret, sysInfo] = CsMl_GetSystemInfo(DAQ); CsMl_ErrorHandler(ret, 1, DAQ);
[ret, AcqInfo] = CsMl_QueryAcquisition(DAQ); CsMl_ErrorHandler(ret, 1, DAQ);
for i = 1:sysInfo.ChannelCount
   [ret, ChanInfo(i)] = CsMl_QueryChannel(DAQ, i);
   CsMl_ErrorHandler(ret, 1, DAQ);
end

% DAQ
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Changing FPGA image require reset of DAQ % 
% Using FPGA image, problems happen with External Trigger Setup % 
% HWAvg works only with Dual Acq, Trigger Source Ch1-2, InputRange 2000 FSIR %
AcqInfo.isUsingHWAvg = true;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% InputRange of 2 channels should be the same
AcqInfo.InputRange = 1000; % mV
ChanInfo(1).InputRange  = AcqInfo.InputRange * 2 ;% FSIR 2 * [mV] 5000, 2000, 1000, 500, 200, 100
ChanInfo(2).InputRange  = AcqInfo.InputRange * 2 ;% FSIR 2 * [mV] 5000, 2000, 1000, 500, 200, 100
% AcqInfo.t_0 = 4.3e-6; AcqInfo.t_end = 6e-6;    % us HFM18=3.4us/1.7us % HFM26=3/3mm z0=1.9 5.18us/2.59us
AcqInfo.t_0     = 0e-6;  

AcqInfo.t_end   = 25e-6;    % us V3330 6/6.35mm F@8.65   [8.1 9.1] - [16.2 18.2]
AcqInfo.nAvg    = 2^10; % number of averages % HWavg use 2^n, n=123489-10, n=567 generates noise
AcqInfo.isAvg   = true;
AcqInfo.isUsingChan = 0; % 0 for 2 channels acquisition
if AcqInfo.isUsingChan == 0
    AcqInfo.nChan = 2;
else
    AcqInfo.nChan = 1;
end

AcqInfo.nHWAvg_Allowed = 1024;
if AcqInfo.isUsingHWAvg == true
    disp('Using hardware averaging multi-record FPGA image');
    disp('FSIR has to be fixed at 1000 mV.');
    AcqInfo.InputRange = 1000; % mV
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
AcqInfo.tStampOn    = 0;
AcqInfo.rawData     = 0;
AcqInfo.acqMode     = CsMl_Translate('Dual', 'Mode'); % Single | Dual acquisition code. When in Single mode, the other chan cannot be used as trigger source
AcqInfo.TriggerTimeout  = 1e6;   %  % Wait until trigger arrives [us] (-1: inf). 0 for immediate trigger when acquisition starts
AcqInfo.TimeStampConfig = CsMl_Translate('FixedClock', 'TimeStamp');  
AcqInfo.Fs          = 500e6; % % 500, 125, 50, 25, 10, 5, 2.5, 1 MS/s, 500, 250, 100, 50, 25, 10, 5, 2.5, 1 kS/s
AcqInfo.dt          = 1/AcqInfo.Fs;
AcqInfo.SegmentCount    = AcqInfo.nSWAvg;
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

tt = [(-AcqInfo.TriggerHoldoff+1)*AcqInfo.dt:AcqInfo.dt:(AcqInfo.Depth)*AcqInfo.dt];
tt_us = tt.*1e6;   
z_ = (tt).*1510e6;

% 
% [ret, AcqInfo, ChanInfo, TrigInfo] = gageSetup_TAM(DAQ, AcqInfo, ChanInfo); % Set acquisition, channel and trigger parameters
[ret, AcqInfo, ChanInfo, TrigInfo] = gageCoerce(DAQ, AcqInfo, ChanInfo, 1, 0);

%% **************************************************************************
% All dimensions are in mm
FovInfo.x0 = 11.5;    % CPS 100MHz/3/3mm
FovInfo.y0 = 18.2;   % CPS 100MHz/3/3mm
FovInfo.z0 = 23;

FovInfo.Lx = 5;
FovInfo.Ly = 0; % 1.7
FovInfo.Lz = 0;

FovInfo.ds = 20e-3; % mm
FovInfo.dx = FovInfo.ds;
FovInfo.dy = FovInfo.ds;
FovInfo.dz = FovInfo.ds;

piMoveAbs(PI.X,FovInfo.x0);
% pause(1);
piMoveAbs(PI.Y,FovInfo.y0);
% pause(1);
piMoveAbs(PI.Z,FovInfo.z0);
% pause(1);
%
[FovInfo.xAct, FovInfo.yAct, FovInfo.zAct] = pi3xGetPosition(PI);                                                  % Get position of the stages
FovInfo.xvAct = 50;%mm/s                               % max 50 for M-404, max 350 for M-683 Set velocity of the stages
FovInfo.yvAct = 50;%mm/s                               % max 50 for M-404, max 350 for M-683 Set velocity of the stages
FovInfo.zvAct = FovInfo.yvAct;%mm/s                               % max 50 for M-404, max 350 for M-683 Set velocity of the stages
piSetVel(PI.X, FovInfo.xvAct);
piSetVel(PI.Y, FovInfo.yvAct);
piSetVel(PI.Z, FovInfo.zvAct);

FovInfo.xvAct = piGetVel(PI.X);                                                   % Get real velocity of the stages
FovInfo.yvAct = piGetVel(PI.Y);                                                   % Get real velocity of the stages
FovInfo.zvAct = piGetVel(PI.Z);                                                   % Get real velocity of the stages

FovInfo.xaccAct = piGetAcc(PI.X);                                                 % Get Acceleration  of the stages
FovInfo.xdecAct = piGetDec(PI.X);                                                 % Get Decceleration of the stages
FovInfo.yaccAct = piGetAcc(PI.Y);                                                 % Get Acceleration  of the stages
FovInfo.ydecAct = piGetDec(PI.Y);                                                 % Get Decceleration of the stages
FovInfo.zaccAct = piGetAcc(PI.Z);                                                 % Get Acceleration  of the stages
FovInfo.zdecAct = piGetDec(PI.Z);                                                 % Get Decceleration of the stages

if ~isequal(rem(FovInfo.Lx,FovInfo.dx),0)
    FovInfo.Lx = ceil(FovInfo.Lx/FovInfo.dx)*FovInfo.dx;
end
if ~isequal(rem(FovInfo.Ly,FovInfo.dy),0)
    FovInfo.Ly = ceil(FovInfo.Ly/FovInfo.dy)*FovInfo.dy;
end

FovInfo.swapXY = 0;                     % 1: y-axis fast axis. 0: x-axis fast axis
if FovInfo.swapXY
    PI2.X = PI.Y; PI2.Y = PI.X; 
    PI.X = PI2.X; PI.Y = PI2.Y;
    
    intermediate = FovInfo.x0;
    FovInfo.x0 = FovInfo.y0;
    FovInfo.y0 = intermediate;

    intermediate = FovInfo.Lx;
    FovInfo.Lx = FovInfo.Ly;
    FovInfo.Ly = intermediate;
    
    intermediate = FovInfo.dx;
    FovInfo.dx = FovInfo.dy;
    FovInfo.dy = intermediate;
    
    clear intermediate PI2;
end

FovInfo.xLim = [FovInfo.x0-FovInfo.Lx/2 FovInfo.x0+FovInfo.Lx/2];
FovInfo.yLim = [FovInfo.y0-FovInfo.Ly/2 FovInfo.y0+FovInfo.Ly/2];
FovInfo.isSnake = 1;
[X,Y] = generateSequence(FovInfo.xLim, FovInfo.yLim, FovInfo.dx, FovInfo.dy, FovInfo.isSnake);
FovInfo.Nx    = size(X,1);                                                         % Number of TD x positions
FovInfo.Ny    = size(X,2);                                                         % Number of TD y positions

positionXY = zeros(FovInfo.Nx*FovInfo.Ny,4);

piEnableTrigOut(PI.X, 1);
piConfigTrigOut(PI.X);
piEnableTrigOut(PI.Y, 1);
piConfigTrigOut(PI.Y);
% piEnableTrigOut(PI.Z, 1);
% piConfigTrigOut(PI.Z);


% to do - not possible with HWAvg because it can only work at 1000 mV scale
% auto scale %SigRange2Scale = [4000 5700]; % TA - [4000 5700], US - [4000 5700]

%% setup DG4 
% [DG4, DG4Info] = DG4_init();
% 100, 200, 500, 1000, 2000, 5000Hz for all
% transducers, except that maximum PRF is internally
% limited to: 2000Hz for 0.5MHz transducers, 1000Hz
% for 0.25MHz transducers, and 500Hz for 0.1MHz
% transducers.
FIDInfo.PRRHz = 10e3; % if >10e3 Hz FID breaks
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
DG4Info.RF_High = 7; % Volt. FPG triggers on 100 ns 5V TTL
DG4Info.RF_Low = 0; % Volt
DG4Info.RF_Amplitude = 7; % Vpp.
DG4Info.RF_Offset = 3.5; % Volt.

% Channel 2
DG4Info.Scope_Channel = 2;
DG4Info.Scope_WaveShapeStr = 'PULSe'; % SINusoid|SQUare|RAMP|PULSe|NOISe|USER| etc
DG4Info.Scope_DutyCycle = DG4Info.DutyCycle ; % % in percentage

DG4Info.Scope_High = 5; % Volt. FPG triggers on 100 ns 5V TTL
DG4Info.Scope_Low = 0; % Volt

DG4Info.nImpedanceOhm = 10e3;

if Flag.isRSOM == 1
    DG4Info.GatedPolarity = 'NORMal';  % NORMal INVerted
elseif Flag.isRSOM == 0
    DG4Info.GatedPolarity = 'INVerted';  % NORMal INVerted
end
trigger_setRFact(DG4, DG4Info);
trigger_setRFact(DG4, DG4Info);
trig_output(DG4, 'OFF', DG4Info.Scope_Channel);
trig_output(DG4, 'OFF', DG4Info.RF_Channel);
pause(1)


% pause(1);
% trig_burstEnable(DG4,false,DG4Info.RF_Channel);
% trig_burstEnable(DG4,true,DG4Info.RF_Channel);

% trig_output(DG4, 'ON', DG4Info.Scope_Channel);
% trig_output(DG4, 'ON', DG4Info.RF_Channel);
% trig_output2Chan(DG4, 'ON', DG4Info);


%%
%
piEnableTrigOut(PI.X, 1);
piConfigTrigOut(PI.X);
piEnableTrigOut(PI.Y, 1);
piConfigTrigOut(PI.Y);

% pause(1);
trig_burstEnable(DG4,true,DG4Info.RF_Channel);
trig_output(DG4, 'ON', DG4Info.RF_Channel);
%
if AcqInfo.isAvg == false
    S = zeros(FovInfo.Nx*FovInfo.Ny,AcqInfo.SegmentSize, AcqInfo.SegmentCount, AcqInfo.nChan);                                                     % Initialize Signal Matrix
elseif AcqInfo.isAvg == true
    S = zeros(FovInfo.Nx*FovInfo.Ny,AcqInfo.SegmentSize, 1, AcqInfo.nChan);                                                     % Initialize Signal Matrix
end
%
h_figure1 = 10086; figure(h_figure1);     hold off;

counter =0;

Elapse = 0;  % Start internal clock
% 
% piEnableTrigOut(PI.X, 1);
% piEnableTrigOut(PI.Y, 1);
% piEnableTrigOut(PI.Z, 1);

trig_DisplaySaverEnable(DG4,1);
trig_DisplaySaverImmediate(DG4);
pause(2);
fprintf('\nNumber of Measurements: %i \n\n', FovInfo.Nx*FovInfo.Ny);
tic;   
%
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
    while CsMl_QueryStatus(DAQ) ~= 0  ;  end                                  % Wait until measurement is done (status = 0)
    
%     S(counter,:) = gageAcqAvg(DAQ, AcqInfo.rawData, AcqInfo.nAvg, AcqInfo.nHWAvg);                            % Acquire Signals
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
        while CsMl_QueryStatus(DAQ) ~= 0  ; end                                  % Wait until measurement is done (status = 0)
        
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
%

trig_output2Chan(DG4, 'OFF', DG4Info);
trig_DisplaySaverEnable(DG4,0);
% freeGage(DAQ);
%
Elapse=Elapse/60; fprintf('Total elapsed time is %s mins.\n', num2str(Elapse));

pi2xMoveAbs(PI, FovInfo.x0, FovInfo.y0);

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
    S2 = S(:,:,:,1); % separate Chan 2 data
end
save([SaveDat '.mat'], 'S1', 'S2', 'AcqInfo', 'ChanInfo', 'TrigInfo', 'FovInfo',...
    'tt', 'tt_us', '-v7.3');

if Flag.isPlot
    FovInfo.Ly = max(FovInfo.Ly, FovInfo.Lx);
    h_figure2=10087;
    figure(h_figure2); hold off;
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

Ratio = 1;
Flag.is_rsom = 0;
Flag.isCreateFolder = 0;
Flag.RAW = 1; Flag.AF = 0; Flag.LF = 0; Flag.HF = 0;
% T1 = 7.5; T2 = 9.125;
T1 = 8; T2 = 9.125;
ezshow_rsom_Quick_2019(FileName,Ratio,T1, T2, Flag);
% ezshow_rsom_Quick_2019(FileName,Ratio,2*T1, 2*T2, Flag);
% 
% ezshow_rsom_Quick_2019('201904101756_TAM50_CPS_randomFishinPlastik_TA10kV1kHz_Xscan_t0_25000ns_AVG1048576_z23000um',Ratio, T1, T2,Flag);
% ezshow_rsom_Quick_2019('201904051812_TAM50_OpenCPS_deadFish_US100V25dB_Yscan_t0_25000ns_AVG65536_z25000um',Ratio, 2*T1, 2*T2,Flag);
addpath('C:\Users\yuanhui\MATLAB\Email-matlab');
SendEmail_notification('yhhuang1987@gmail.com', 'TAM Scan', 'Finished');
