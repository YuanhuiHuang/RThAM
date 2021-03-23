%% test
nAvg = 1;% number of soft averages
hard_average = 1024; % number of hard averages; Changing hard avg requires freeGage
inputRange = 2000;% [mV] 10000, 4000, 2000, 1000, 400, 200, 100
segCount = nAvg;

Fs = 500e6;
dt = 1/Fs;
t_0 = 0e-6; t_end = 10e-6;    % us HFM18=3.4us/1.7us [1.5 3.74] 

trigDelay = t_0 * Fs;
endpoint = t_end * Fs; % FPGA average take 65 KSamples per channel / 2 channel
t = [t_0+dt:dt:t_end];

nSamples   = (endpoint - trigDelay); %2048;        % Number of samples
detType    = 'TAM50';%TAM50: 500e6, TAM100: 1e9

acqRes    = 32;
acqMode   = 'Single';                                                      % this is the single acquisition code
nSegments = ceil(nSamples/acqRes);
TriggerTimeout  = -1;   %  % Wait until trigger arrives [us] (-1: inf)
rawdata = 0;

handle = DAQ


%% --- Get System Info
% [ret] = CsMl_ForceCalibration(handle);
[ret, sysinfo] = CsMl_GetSystemInfo(handle);
CsMl_ErrorHandler(ret, 1, handle);

%%
% We'll query the driver for the acquisition
% parameters so we know the mode before we change it to use
% the extended options.
[ret, acqInfo] = CsMl_QueryAcquisition(handle);
% If we change the mode, we'll keep a copy of the original capture mode in
% old_mode in case we need it later
% acqInfo.Mode = 2;
% Old_Mode = acqInfo.Mode;

% --- Set Acquisition Parameters
if strcmp(detType, 'RSOM100')
    acqInfo.SampleRate      = 1e9;                                             % Set sampling rate
elseif strcmp(detType, 'RSOM50')
    acqInfo.SampleRate      = 500e6;
elseif strcmp(detType, 'TAM100')
    acqInfo.SampleRate      = 1e9;
elseif strcmp(detType, 'TAM50')
    acqInfo.SampleRate      = 500e6;
elseif strcmp(detType, 'SOI')
    acqInfo.SampleRate      = 250e6;
elseif strcmp(detType, 'LUS100')
    acqInfo.SampleRate      = 500e6;
else
    disp('Wrong setup file.');
    return;    
end
disp(sprintf('\nSetup file %s accessed\n', detType));

acqInfo.Mode            = CsMl_Translate(acqMode, 'Mode');

% setup acqInfo.Mode using hardware averaging FPGA image
if (hard_average > 1)
    % Check to see which optional fpga images are available
    [ret, options] = CsMl_GetExtendedOptions(handle);
    % Calculate the active channel count using the original
    % mode, before we add the MulRec Averaging constant
    ChannelCount = acqInfo.Mode * sysinfo.BoardCount;
    
    % This next part determines if multiple record averaging  is available
    % and which fpga image (1 or 2) it is on. If you know that your CompuScope 
    % system has multiple record averaging and which image it is on you can 
    % skip this step and just "or" (or add) the appropriate constant to the 
    % acquisition mode. The constant for image 1 is 0x40000000 and for image 2 
    % is 0x80000000.
    mulrecavg_option = CsMl_Translate('mulrec averaging', 'Options');
    if options(1).OptionConstant == mulrecavg_option
        mode = acqInfo.Mode + options(1).ModeConstant;
    elseif options(2).OptionConstant == mulrecavg_option
        mode = acqInfo.Mode + options(2).ModeConstant;
    else
        % system does not support mulrec averaging with TD, we'll try
        % regular mulrec averaging which has a value of 16
        disp('System does not support Multiple Record Averaging TD');
        disp('Trying to load Multiple Record Averaging');
        if options(1).OptionConstant == 16
            mode = acqInfo.Mode + options(1).ModeConstant;
        elseif options(2).OptionConstant == 16
            mode = acqInfo.Mode + options(2).ModeConstant;
        else
            disp('System does not support Multiple Record Averaging');
            CsMl_FreeSystem(handle);
            return;    
        end;
    end;
    acqInfo.Mode = mode;
    CsMl_SetMulrecAverageCount(handle, hard_average);
    CsMl_ErrorHandler(ret, 1, handle);
%     acqInfo.Mode            = CsMl_Translate(acqMode, 'Mode');
    %     acqInfo.Mode = bitor(acqInfo.Mode,hex2dec(num2str(40000000)));       % 0x40000000 is for FPGA image 1; 0x80000000 is for image 2
    %     CsMl_SetMulrecAverageCount(handle, hard_average);
%         ret = CsMl_Commit(handle);
    %     CsMl_ErrorHandler(ret, 1, handle);
elseif (hard_average <= 1)
    acqInfo.Mode            = CsMl_Translate(acqMode, 'Mode');
end
    % acqInfo.SegmentCount = 1; 
    % acqInfo.Depth = 130e3;  % maximum hardware segment samples
    % acqInfo.SegmentSize = 130e3;
     
% acqInfo.ExtClock        = 0;
acqRes = 32;                              %!!! 32 is the minimum resolution of a cell
acqInfo.SegmentCount    = segCount;
acqInfo.Depth           = nSegments * acqRes;
acqInfo.SegmentSize     = nSegments * acqRes;                              % Number of Samples
acqInfo.TriggerTimeout  = TriggerTimeout;   %TriggerTimeout                                           % Wait until trigger arrives [us] (-1: inf)
acqInfo.TriggerHoldoff  = 0;                                               % Dead time before awaiting a trigger signal
acqInfo.TriggerDelay    = trigDelay;                                       % 1GS/s: focus @ 1740 
time_stamp_clock        = CsMl_Translate('FixedClock', 'TimeStamp');       % Number of omitted samples at the beginning
acqInfo.TimeStampConfig = time_stamp_clock;
% acqInfo.SampleResolution = -2097152; % by default resolution is -2097152, but not 2^32, because for 1024 12bit-sequence adding up it is enough.
% acqInfo.SampleSize = 4; % 4 for hardware average and 2 for none
ret = CsMl_ConfigureAcquisition(handle, acqInfo);
CsMl_ErrorHandler(ret, 1, handle);
% [ret, acqInfo] = CsMl_QueryAcquisition(handle);

%%
% Set up all the channels even though
% they might not all be used. For example
% in a 2 board master / slave system, in single channel
% mode only channels 1 and 3 are used.
for i = 1:sysinfo.ChannelCount
%     [ret, chan(i)] = CsMl_QueryChannel(handle,i);
    chan(i).Channel    = i;
    chan(i).Coupling   = CsMl_Translate('DC', 'Coupling');                           % Set the coupling to input TD channel to DC
    chan(i).DiffInput  = 0;
    chan(i).InputRange = inputRange;    % 10000, 4000, 2000, 1000, 400, 200              % Set total input voltage range
    chan(i).Impedance  = 50;                                                         % Input impedance (according to cable)
    chan(i).DcOffset   = 0;                                                          % Baseline offset
    chan(i).DirectAdc  = 0;
    chan(i).Filter     = 0; 
end

% chan(1).InputRange = 2000;
% chan(2).InputRange = 4000;

ret = CsMl_ConfigureChannel(handle, chan);
CsMl_ErrorHandler(ret, 1, handle);

%%
% --- Set Trigger Parameters
% CsMl_QueryTrigger(handle, 1)
trig.Trigger     = 1;
trig.Slope       = CsMl_Translate('Positive', 'Slope');
trig.Level       = 20;                                                     % Trigger threshold
trig.Source      = -1;                                                               % Trigger signal on channel -1
trig.ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');                    % ExtCoupling          % Set the coupling to trigger channel to DC
trig.ExtRange    = inputRange;                                                            % Set total trigger signal voltage range
trig.ExtImpedance= 1000000; % 1000000

ret = CsMl_ConfigureTrigger(handle, trig);
CsMl_ErrorHandler(ret, 1, handle);
ret = 1;
[ret] = CsMl_ForceCalibration(handle);
% Setup(DAQ, segCount, trigDelay, inputRange, nSegments, acqMode, detType, TriggerTimeout, hard_average);                                                                         % Set acquisition, channel and trigger parameters
pause(1);ret = CsMl_Commit(DAQ);CsMl_GetErrorString(ret)
