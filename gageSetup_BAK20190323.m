% Sets the acquisition, channel and trigger parameters for the system and
% calls ConfigureAcquisition, ConfigureChannel and ConfigureTrigger.

function ret = gageSetup_BAK20190323(handle,...
                     segCount,...
                     trigDelay,...
                     inputRange,...
                     nSegments,...
                     acqMode,...
                     transducer,...
                     timeout,...
                     hard_average)
if nargin < 9
    hard_average = 1;
    if nargin < 8
        timeout = -1;
        if nargin < 7
            transducer = 'RSOM50';
            if nargin < 6
                acqMode = 'Single';
                if nargin < 5
                    nSegments  = 32;             % 32 is equivalent to 1024 samples
                    if nargin < 4
                        inputRange = 2000;
                        if nargin < 3
                            trigDelay = 1700;    % Focus 1740 (1GS) / 870 (500MS)
                            if nargin < 2
                                segCount = 1;
                            end
                        end
                    end
                end
            end
        end
    end
end



%% --- Get System Info
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
Old_Mode = acqInfo.Mode;

% --- Set Acquisition Parameters
if strcmp(transducer, 'RSOM100')
    acqInfo.SampleRate      = 1e9;                                             % Set sampling rate
elseif strcmp(transducer, 'RSOM50')
    acqInfo.SampleRate      = 500e6;
elseif strcmp(transducer, 'TAM100')
    acqInfo.SampleRate      = 500e6;
elseif strcmp(transducer, 'TAM50')
    acqInfo.SampleRate      = 500e6;
elseif strcmp(transducer, 'TAM20')
    acqInfo.SampleRate      = 50e6;
elseif strcmp(transducer, 'SOI')
    acqInfo.SampleRate      = 250e6;
elseif strcmp(transducer, 'LUS100')
    acqInfo.SampleRate      = 500e6;
else
    disp('Wrong setup file.');
    return;    
end
disp(sprintf('\nSetup file %s accessed\n', transducer));

acqInfo.Mode            = CsMl_Translate(acqMode, 'Mode');
%%
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
        end
    end
    acqInfo.Mode = mode;
    CsMl_SetMulrecAverageCount(handle, hard_average);
    CsMl_ErrorHandler(ret, 1, handle);
%     acqInfo.Mode            = CsMl_Translate(acqMode, 'Mode');
    %     acqInfo.Mode = bitor(acqInfo.Mode,hex2dec(num2str(40000000)));       % 0x40000000 is for FPGA image 1; 0x80000000 is for image 2
    %     CsMl_SetMulrecAverageCount(handle, hard_average);
%         ret = CsMl_Commit(handle);
    %     CsMl_ErrorHandler(ret, 1, handle);
elseif (hard_average <= 1)
    mode = Old_Mode;
end
    % acqInfo.SegmentCount = 1; 
    % acqInfo.Depth = 130e3;  % maximum hardware segment samples
    % acqInfo.SegmentSize = 130e3;
%%
acqInfo.Mode = mode;    
acqInfo.ExtClock        = 0;
acqRes = 32;                              %!!! 32 is the minimum resolution of a cell
acqInfo.SegmentCount    = segCount;
acqInfo.Depth           = nSegments * acqRes;
acqInfo.SegmentSize     = nSegments * acqRes;                              % Number of Samples
acqInfo.TriggerTimeout  = timeout;                                              % Wait until trigger arrives [us] (-1: inf)
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
    chan(i).Channel    = i;
    chan(i).Coupling   = CsMl_Translate('AC', 'Coupling');                           % Set the coupling to input TD channel to DC
    chan(i).DiffInput  = 0;
    chan(i).InputRange = inputRange;    % 10000, 4000, 2000, 1000, 400, 200              % Set total input voltage range
    chan(i).Impedance  = 50;                                                         % Input impedance (according to cable)
    chan(i).DcOffset   = 0;                                                          % Baseline offset
    chan(i).DirectAdc  = 0;
    chan(i).Filter     = 1;                                         %  5-Pole with -3dB point at 70 MHz; - 1 turns on filter, 0 turns filter off (0 is default)
end

% chan(1).InputRange = 2000;
chan(2).InputRange = 10000;
chan(2).Filter     = 0;                                         %  5-Pole with -3dB point at 70 MHz; - 1 turns on filter, 0 turns filter off (0 is default)

ret = CsMl_ConfigureChannel(handle, chan);
CsMl_ErrorHandler(ret, 1, handle);

% --- Set Trigger Parameters
trig.Trigger     = 1;
trig.Slope       = CsMl_Translate('Positive', 'Slope');
trig.Level       = 10;                                                     % Trigger threshold
trig.Source      = 2;                                                               % Trigger signal on channel -1
trig.ExtCoupling = CsMl_Translate('AC', 'ExtCoupling');                    % ExtCoupling          % Set the coupling to trigger channel to DC
trig.ExtRange    = 10000;	% Set total trigger signal voltage range FSIR 2000 | 10000
trig.ExtImpedance= 50; 

ret = CsMl_ConfigureTrigger(handle, trig);
CsMl_ErrorHandler(ret, 1, handle);
% ret = 1;
% CsMl_ForceCalibration(handle);
% end
