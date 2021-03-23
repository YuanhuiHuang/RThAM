% Sets the acquisition, channel and trigger parameters for the system and
% calls ConfigureAcquisition, ConfigureChannel and ConfigureTrigger.

function ret = Setup(handle, segCount, trigDelay, inputRange, nSegments)
if nargin < 5
    nSegments  = 32;             % 32 is equivalent to 1024 samples @ 1GSps
    if nargin < 4
        inputRange = 2000;
        if nargin < 3
            trigDelay = 1700;    % 1700 just before focus @ 1GSps (1740)
            if nargin < 2
                segCount = 1;
            end
        end
    end
end

fprintf('Setup file RSOM was accessed\n');

% --- Get System Info
[ret, sysinfo] = CsMl_GetSystemInfo(handle);
CsMl_ErrorHandler(ret, 1, handle);

%!!! 16 is the minimum resolution of a cell
% --- Set Acquisition Parameters
acqInfo.SampleRate      = 1e8;                                                  % Set sampling rate
acqInfo.ExtClock        = 0;
acqInfo.Mode            = CsMl_Translate('Single', 'Mode');
acqInfo.SegmentCount    = segCount;
acqInfo.Depth           = nSegments * 32;
acqInfo.SegmentSize     = nSegments * 32;                                             % Number of Samples
acqInfo.TriggerTimeout  = 0; % -1;                         %-1: external trigger                                                    % Wait until trigger signal arrives (neg: inf)
acqInfo.TriggerHoldoff  = 0;                                                         % Dead time before awaiting a trigger signal
acqInfo.TriggerDelay    = trigDelay;                  % 1GS/s: focus @ 1740 
time_stamp_clock        = CsMl_Translate('FixedClock', 'TimeStamp');                 % Number of omitted samples at the beginning
acqInfo.TimeStampConfig = time_stamp_clock;

ret = CsMl_ConfigureAcquisition(handle, acqInfo);
CsMl_ErrorHandler(ret, 1, handle);

% Set up all the channels even though
% they might not all be used. For example
% in a 2 board master / slave system, in single channel
% mode only channels 1 and 3 are used.

for i = 1:sysinfo.ChannelCount
    chan(i).Channel    = i;
    chan(i).Coupling   = CsMl_Translate('AC', 'Coupling');                           % Set the coupling to input TD channel to DC
    chan(i).DiffInput  = 0;
    chan(i).InputRange = inputRange;%10000,4000,2000,1000                                                       % Set total input voltage range
    chan(i).Impedance  = 50;                                                         % Input impedance (according to cable)
    chan(i).DcOffset   = 0;                                                          % Baseline offset
    chan(i).DirectAdc  = 0;
    chan(i).Filter     = 0; 
end

% chan(1).InputRange = 2000;
% chan(2).InputRange = 4000;

ret = CsMl_ConfigureChannel(handle, chan);
CsMl_ErrorHandler(ret, 1, handle);

% --- Set Trigger Parameters
trig.Trigger     = 1;
trig.Slope       = CsMl_Translate('Positive', 'Slope');
trig.Level       = 40;                                        % 15                                                             % Trigger threshold
trig.Source      = -1;                                                            % Trigger signal on channel -1
trig.ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');       % ExtCoupling                          % Set the coupling to trigger channel to DC
trig.ExtRange    = 10000;                                                            % Set total trigger signal voltage range

ret = CsMl_ConfigureTrigger(handle, trig);
CsMl_ErrorHandler(ret, 1, handle);

ret = 1;

end