function [ret, AcqInfo, ChanInfo, TrigInfo] = gageSetup_TAM_SW(handle, AcqInfo, ChanInfo)

% Sets the acquisition, channel and trigger parameters for the system and
% calls ConfigureAcquisition, ConfigureChannel and ConfigureTrigger.
% Version setup_DAQ_TAM
% The used DAQ is CS12502, 2 channels, 12 bits, 1GS memory


%% Step 1 - get System Info
[ret, sysInfo] = CsMl_GetSystemInfo(handle); CsMl_ErrorHandler(ret, 1, handle);

%% Step 2 - set acqInfo
% Step 2.1 - Get acquistion Info
[ret, acqInfo] = CsMl_QueryAcquisition(handle);
% Step 2.2 - setup acqInfo.Mode using hardware averaging FPGA image
if (AcqInfo.isUsingHWAvg == true)
    % Check to see which optional fpga images are available
    [ret, options] = CsMl_GetExtendedOptions(handle);
    % Calculate the active channel count using the original
    % mode, before we add the MulRec Averaging constant
    ChannelCount = AcqInfo.Mode * sysInfo.BoardCount;

    % This next part determines if multiple record averaging  is available
    % and which fpga image (1 or 2) it is on. If you know that your CompuScope 
    % system has multiple record averaging and which image it is on you can 
    % skip this step and just "or" (or add) the appropriate constant to the 
    % acquisition mode. The constant for image 1 is 0x40000000 and for image 2 
    % is 0x80000000.
    mulrecavg_option = CsMl_Translate('mulrec averaging', 'Options');
    if options(1).OptionConstant == mulrecavg_option
        mode = AcqInfo.Mode + options(1).ModeConstant;
    elseif options(2).OptionConstant == mulrecavg_option
        mode = AcqInfo.Mode + options(2).ModeConstant;
    else
        % system does not support mulrec averaging with TD, we'll try
        % regular mulrec averaging which has a value of 16
        disp('System does not support Multiple Record Averaging TD');
        disp('Trying to load Multiple Record Averaging');
        if options(1).OptionConstant == 16
            mode = AcqInfo.Mode + options(1).ModeConstant;
        elseif options(2).OptionConstant == 16
            mode = AcqInfo.Mode + options(2).ModeConstant;
        else
            fprintf(('\nSystem does not support Multiple Record Averaging ! \n \n'));
            mode = AcqInfo.acqMode;
            AcqInfo.nSWAvg = AcqInfo.nHWAvg * AcqInfo.nSWAvg;
            acqInfo.SegmentCount = AcqInfo.nSWAvg;
            AcqInfo.nHWAvg = 0;
            AcqInfo.isUsingHWAvg = false;
%             CsMl_FreeSystem(handle);
%             return;    
        end
    end
    ret = CsMl_SetMulrecAverageCount(handle, AcqInfo.nHWAvg);
%     ret = CsMl_GetMulrecAverageCount(handle);
    CsMl_ErrorHandler(ret);
elseif (AcqInfo.isUsingHWAvg == false)
    mode = AcqInfo.acqMode;
end
acqInfo.Mode            = mode;     % acquisition mode (1 = Single, 2 = Dual, 4 = Quad, 8 = Octal). When in Single mode, the other chan cannot be used as trigger source

acqInfo.SampleRate      = AcqInfo.Fs;
acqInfo.ExtClock        = 0; % a flag to set external clocking on (1) or off (0)
acqInfo.TriggerTimeout  = AcqInfo.TriggerTimeout; % how long to wait before forcing a trigger (in
                                    %microseconds). A value of -1 means wait indefinitely.
acqInfo.TriggerHoldoff  = AcqInfo.TriggerHoldoff; % the amount of ensured pre-trigger data in samples
acqInfo.TriggerDelay    = AcqInfo.TriggerDelay; % how long to delay the start of the depth counter
                                        %after the trigger event has occurred, in samples
acqInfo.SegmentCount    = AcqInfo.SegmentCount; % the number of segments to acquire
acqInfo.Depth           = AcqInfo.Depth; % post-trigger depth, in samples
acqInfo.SegmentSize     = AcqInfo.SegmentSize; % post and pre-trigger depth
acqInfo.TimeStampConfig = AcqInfo.TimeStampConfig;       
% acqInfo.SampleResolution = -2097152; % by default resolution is -2097152, but not 2^32, because for 1024 12bit-sequence adding up it is enough.
% acqInfo.SampleSize = 4; % 4 for hardware average and 2 for none
ret = CsMl_ConfigureAcquisition(handle, acqInfo);
CsMl_ErrorHandler(ret, 1, handle);

% [ret, AcqInfo] = CsMl_QueryAcquisition(handle);
AcqInfo.Mode = acqInfo.Mode;
% flags.Coerce = 0; flags.OnChange = 1;
% [ret] = CsMl_Commit(handle, flags);

%%
% Set up all the channels even though
% they might not all be used. For example
% in a 2 board master / slave system, in single channel
% mode only channels 1 and 3 are used.
for i = 1:sysInfo.ChannelCount
    chan(i).Channel    = i;
    if i == 1 % always signal channel
        chan(i).Coupling   = CsMl_Translate('DC', 'Coupling');                           % Set the coupling to input TD channel to DC
    elseif i == 2 % E-field probe or trigger
        chan(i).Coupling   = CsMl_Translate('DC', 'Coupling');                           % Set the coupling to input TD channel to DC
    end
    chan(i).DiffInput  = 0;
    chan(i).InputRange = ChanInfo(i).InputRange;    % FSIR 10000, 4000, 2000, 1000, 400, 200              % Set total input voltage range
    chan(i).Impedance  = 50;                                                         % Input impedance (according to cable)
    chan(i).DcOffset   = 0;                                                          % Baseline offset
    chan(i).DirectAdc  = 0;
    chan(i).Filter     = 0;      % 15 to 6 mV noise using it if use 20 MHz transducer          %  5-Pole with -3dB point at 70 MHz;  1 turns on filter, 0 turns filter off (0 is default)
end

ret = CsMl_ConfigureChannel(handle, chan);
CsMl_ErrorHandler(ret, 1, handle);
ChanInfo = chan;
% 
% for i = 1:sysInfo.ChannelCount
%    [ret, ChanInfo(i)] = CsMl_QueryChannel(handle, i);
%    CsMl_ErrorHandler(ret, 1, handle);
% end

% flags.Coerce = 0; flags.OnChange = 1;
% [ret] = CsMl_Commit(handle, flags);

%% --- Set Trigger Parameters
% for i = 1:sysInfo.TriggerCount
%     trig(i).Trigger = i;
%     % % it looks like the external trigger has to work with Trigger engine #1
%     if i == 3
%         trig(i).Slope = CsMl_Translate('Positive', 'Slope');
%         trig(i).Level = 10;
%         trig(i).Source = 2;
%         trig(i).ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');
%         trig(i).ExtImpedance = 	CsMl_Translate('HiZ', 'ExtImpedance'); % the external trigger impedance in Ohms. Set 1000000 for HiZ
%         if ChanInfo(2).InputRange > 2000
%             trig(i).ExtRange = 10000;
%         else 
%             trig(i).ExtRange = 2000;
%         end
%     elseif i == 4
%         trig(i).Slope = CsMl_Translate('Positive', 'Slope');
%         trig(i).Level = 10;
%         trig(i).Source = 2;
%         trig(i).ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');
%         trig(i).ExtImpedance = 	CsMl_Translate('HiZ', 'ExtImpedance'); % the external trigger impedance in Ohms. Set 1000000 for HiZ
%         if ChanInfo(2).InputRange > 2000
%             trig(i).ExtRange = 10000; % +- 5000 mV
%         else 
%             trig(i).ExtRange = 2000; % +- 1000 mV
%         end
% %     elseif i == 1
% %         trig(i).Slope = CsMl_Translate('Negative', 'Slope');
% %         trig(i).Level = -80;
% %         trig(i).Source = 1; 
% %         trig(i).ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');
% %         trig(i).ExtImpedance = 	CsMl_Translate('50', 'ExtImpedance'); % the external trigger impedance in Ohms. Set 1000000 for HiZ
% %         if ChanInfo(1).InputRange > 2000
% %             trig(i).ExtRange = 10000; % +- 5000 mV
% %         else 
% %             trig(i).ExtRange = 2000; % +- 1000 mV
% %         end
% %     elseif i == 2
% %         trig(i).Slope = CsMl_Translate('Positive', 'Slope');
% %         trig(i).Level = 80;
% %         trig(i).Source = 1; 
% %         trig(i).ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');
% %         trig(i).ExtImpedance = 	CsMl_Translate('50', 'ExtImpedance'); % the external trigger impedance in Ohms. Set 1000000 for HiZ
% %         if ChanInfo(1).InputRange > 2000
% %             trig(i).ExtRange = 10000; % +- 5000 mV
% %         else 
% %             trig(i).ExtRange = 2000; % +- 1000 mV
% %         end
% %     % % if causing problem, comment external trigger.
% %     % Using FPGA image, problems happen with External Trigger Setup % 
% %     % Using FPGA image, Only Dual Acq, Trigger Source Ch1-2 %
%     elseif i == 5 %% global trigger, external TTL
%         trig(i).Slope = CsMl_Translate('Positive', 'Slope');
%         trig(i).Level = 10;
%         trig(i).ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');
%         trig(i).ExtImpedance = 	CsMl_Translate('HiZ', 'ExtImpedance'); % the external trigger impedance in Ohms. Set 1000000 for HiZ
%         trig(i).ExtRange = 10000;
%         if (AcqInfo.isUsingHWAvg == false)
%             trig(i).Source = 2;
%         else
%             trig(i).Source = 0;
%         end
%     else
%         trig(i).Slope = CsMl_Translate('Positive', 'Slope');
%         trig(i).Level = 10;
%         trig(i).Source = 2; 
%         trig(i).ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');
%         trig(i).ExtImpedance = 	CsMl_Translate('HiZ', 'ExtImpedance'); % the external trigger impedance in Ohms. Set 1000000 for HiZ
%         trig(i).ExtRange = 2000;
%     end
% end

trig.Trigger = 1;
trig.Slope = CsMl_Translate('Positive', 'Slope');
trig.Level = 10;
trig.Source = -1;
trig.ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');
trig.ExtImpedance = CsMl_Translate('50', 'ExtImpedance'); % the external trigger impedance in Ohms. Set 1000000 for HiZ
trig.ExtRange = 10000;

ret = CsMl_ConfigureTrigger(handle, trig);
CsMl_ErrorHandler(ret, 1, handle);

% [ret, TrigInfo(1)] = CsMl_QueryTrigger(handle, trig.Trigger);
% CsMl_ErrorHandler(ret, 1, handle);
% [ret, TrigInfo(2)] = CsMl_QueryTrigger(handle, trig(2).Trigger);
% CsMl_ErrorHandler(ret, 1, handle);
TrigInfo = trig;

% flags.Coerce = 0; flags.OnChange = 1;
% [ret] = CsMl_Commit(handle, flags);

[ret] = CsMl_Commit(handle);
% CsMl_ErrorHandler(ret, 1, handle);

