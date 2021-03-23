function [ret, ChanInfo] = gageChanSetup_TAM(handle, ChanInfo)

% Sets the acquisition, channel and trigger parameters for the system and
% calls ConfigureAcquisition, ConfigureChannel and ConfigureTrigger.
% Version setup_DAQ_TAM
% The used DAQ is CS12502, 2 channels, 12 bits, 1GS memory


%% Step 1 - get System Info
[ret, sysInfo] = CsMl_GetSystemInfo(handle);
CsMl_ErrorHandler(ret, 1, handle);

%%
% Set up all the channels even though
% they might not all be used. For example
% in a 2 board master / slave system, in single channel
% mode only channels 1 and 3 are used.
for i = 1:sysInfo.ChannelCount
    chan(i).Channel    = i;
    chan(i).Coupling   = CsMl_Translate('AC', 'Coupling');                           % Set the coupling to input TD channel to DC
    chan(i).DiffInput  = 0;
    chan(i).InputRange = inputRange;    % FSIR 10000, 4000, 2000, 1000, 400, 200              % Set total input voltage range
    chan(i).Impedance  = 50;                                                         % Input impedance (according to cable)
    chan(i).DcOffset   = 0;                                                          % Baseline offset
    chan(i).DirectAdc  = 0;
    chan(i).Filter     = 0;                                         %  5-Pole with -3dB point at 70 MHz; - 1 turns on filter, 0 turns filter off (0 is default)
end

ret = CsMl_ConfigureChannel(handle, chan);
CsMl_ErrorHandler(ret, 1, handle);

