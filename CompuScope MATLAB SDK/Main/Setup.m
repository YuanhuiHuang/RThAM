function [ret] = Setup(handle)
% Set the acquisition, channel and trigger parameters for the system and
% calls ConfigureAcquisition, ConfigureChannel and ConfigureTrigger.

[ret, sysinfo] = CsMl_GetSystemInfo(handle);
CsMl_ErrorHandler(ret, 1, handle);

acqInfo.SampleRate = 500e6;
acqInfo.ExtClock = 0;
acqInfo.Mode = CsMl_Translate('dual', 'Mode');
acqInfo.SegmentCount = 5;
acqInfo.Depth = 4096;
acqInfo.SegmentSize = 4096;
acqInfo.TriggerTimeout = -1;
acqInfo.TriggerHoldoff = 0;
acqInfo.TriggerDelay = 0;
acqInfo.TimeStampConfig = 0;

[ret] = CsMl_ConfigureAcquisition(handle, acqInfo);
CsMl_ErrorHandler(ret, 1, handle);

% Set up all the channels even though
% they might not all be used. For example
% in a 2 board master / slave system, in single channel
% mode only channels 1 and 3 are used.
for i = 1:sysinfo.ChannelCount
    chan(i).Channel = i;
    chan(i).Coupling = CsMl_Translate('DC', 'Coupling');
    chan(i).DiffInput = 0;
    chan(i).InputRange = 2000;
    chan(i).Impedance = 50;
    chan(i).DcOffset = 0;
    chan(i).DirectAdc = 0;
    chan(i).Filter = 0; 
end;   
chan(1).InputRange = 200;

[ret] = CsMl_ConfigureChannel(handle, chan);
CsMl_ErrorHandler(ret, 1, handle);

trig.Trigger = 1;
trig.Slope = CsMl_Translate('Positive', 'Slope');
trig.Level = 10;
trig.Source = 2;
trig.ExtCoupling = CsMl_Translate('AC', 'ExtCoupling');
trig.ExtRange = 2000;

[ret] = CsMl_ConfigureTrigger(handle, trig);
CsMl_ErrorHandler(ret, 1, handle);

ret = 1;