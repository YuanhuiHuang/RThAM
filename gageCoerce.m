function [ret, AcqInfo, ChanInfo, TrigInfo] = gageCoerce(handle, AcqInfo, ChanInfo, isShowSetup, isShowAcq)
% GageCoerce sample program

% This program demonstrates how to configure a system's capture, channel
% and trigger parameters, do a capture and retrieve the captured data. The
% data is saved to a seperate file for each channel and also displayed. In
% this program, the Coerce flag is set so if an incorrect parameters is
% given the driver will coerce the value to a correct one.
if nargin <4
    isShowSetup = true;
end

if nargin <5
    isShowAcq = false;
end

[ret, sysinfo] = CsMl_GetSystemInfo(handle);
CsMl_ErrorHandler(ret);
s = sprintf('-----Board name: %s\n', sysinfo.BoardName);
disp(['Trying configuration for ' s]);

%% % Setup(handle);

[ret, AcqInfo, ChanInfo, TrigInfo] = gageSetup_TAM(handle, AcqInfo, ChanInfo); % Set acquisition, channel and trigger parameters
% CsMl_ResetTimeStamp(handle);
AcqInfo.ChannelCount = sysinfo.ChannelCount;
flags.Coerce = 0;  flags.OnChange = 1;
[ret] = CsMl_Commit(handle, flags);
disp(['First Setup configuration Commit Error occurred ' num2str(ret)]);
if ret == -36 
    disp('Perhaps Dual acquisition mode is requried.')
    AcqInfo.acqMode     = CsMl_Translate('Dual', 'Mode'); % Single | Dual acquisition code
end

if ret<1
    disp(['Coerce configuration for ' s]);
    [ret, AcqInfo, ChanInfo, TrigInfo] = gageSetup_TAM(handle, AcqInfo, ChanInfo); % Set acquisition, channel and trigger parameters
    flags.Coerce = 0;  flags.OnChange = 0;
    [ret] = CsMl_Commit(handle, flags);
    disp(['Second Setup configuration Commit Error occurred ' num2str(ret)]);
end
disp(' ');

%%
% % If the return value is greater than 1 something has been coerced. If
% % this is the case we print out all the acquisition, channel and trigger
% % parameters.
if ret<1
    answer = questdlg('Cannot config DAQ. freeGage?', ...
        'DAQ Error', ...
        'freeGage','Show Coerce config','freeGage');
    % Handle response
    switch answer
        case 'freeGage'
            disp([answer ' coming right up.'])
            freeGage(handle);
            return;
        case 'Show Coerce config'
            disp([answer ' coming right up.'])
            isShowSetup = true;
    end
    
    if isShowSetup == true
    if ret < 1
        disp('One or more capture parameters was invalid and has been coerced.');
        disp('If key info is not right, remove external trigger config in Setup and try again.');
    else
        disp('Configuration of current Setup.');
    end
    [ret, acqstruct] = CsMl_QueryAcquisition(handle);
    AcqInfo.SampleResolution = acqstruct.SampleResolution;
    AcqInfo.SampleOffset = acqstruct.SampleOffset;
    if ret < 1
        disp('Could not get acquisition information');
    else
        disp(' ');
        disp('Current acquisition parameters...');
        disp(' ');
        
        str = sprintf('Sample Rate: %d Hz', acqstruct.SampleRate);
        disp(str);

        if acqstruct.ExtClock == 1
            s = 'On';
        else
            s = 'Off';
        end;
        str = sprintf('External Clock: %s', s);
        disp(str);        

        MaskedMode = bitand(acqstruct.Mode, 15);
        if MaskedMode == 8
            s = 'Octal';
        elseif MaskedMode == 4
            s = 'Quad';
        elseif MaskedMode == 2
            s = 'Dual';
        elseif MaskedMode == 1
            s = 'Single';
        else
            s = sprintf('%d', MaskedMode);
        end;
        str = sprintf('Mode: %s', s);
        disp(str);        

        str = sprintf('Segment Count: %d', acqstruct.SegmentCount);
        disp(str);        

        str = sprintf('Depth: %d', acqstruct.Depth);
        disp(str);        

        str = sprintf('Segment Size: %d', acqstruct.SegmentSize);
        disp(str);        

        str = sprintf('Trigger Timeout: %d microseconds', acqstruct.TriggerTimeout);
        disp(str);        

        str = sprintf('Trigger Delay: %d samples', acqstruct.TriggerDelay);
        disp(str);     

        str = sprintf('Trigger Holdoff: %d samples', acqstruct.TriggerHoldoff);
        disp(str);        
    end
    disp(' ');
    
    MaskedMode = bitand(acqstruct.Mode, 15);
    ChannelsPerBoard = sysinfo.ChannelCount / sysinfo.BoardCount;
    ChannelSkip = ChannelsPerBoard / MaskedMode;    
    
    for i = 1:ChannelSkip:sysinfo.ChannelCount
        [ret, chanstruct(i)] = CsMl_QueryChannel(handle, i);
        ChanInfo(i).InputRange = chanstruct(i).InputRange;
        ChanInfo(i).DcOffset = chanstruct(i).DcOffset;
        if ret < 1
            str = sprintf('Could not get channel info for Channel %d', i);
            disp(str);
            disp(' ');
            continue;
        end;
        str = sprintf('Current channel %d parameters ...', i);
        disp(' ');
        disp(str);
        disp(' ');
        
        if chanstruct(i).Coupling == 2
            s = 'AC';
        elseif chanstruct(i).Coupling == 1
            s = 'DC';
        else
            s = sprintf('%d', chanstruct(i).Coupling);
        end;
        str = sprintf('Coupling: %s', s);
        disp(str);                    

        if chanstruct(i).DiffInput == 1
            s = 'On';
        else
            s = 'Off';
        end;
        str = sprintf('Differential Input: %s', s);
        disp(str);                                

        str = sprintf('Input Range: %d mV', chanstruct(i).InputRange);
        disp(str);                                

        str = sprintf('Impedance: %d Ohms', chanstruct(i).Impedance);
        disp(str);                                

        str = sprintf('DC Offset: %d mV', chanstruct(i).DcOffset);
        disp(str);                                

        if chanstruct(i).DirectAdc == 1
            s = 'On';
        else
            s = 'Off';
        end;
        str = sprintf('Direct ADC: %s', s);
        disp(str);                                
    end
    disp(' ');
 % ******************************************************
 % % don't query about external trigger upon Error, otherwise Matlab quits
 % % here we quiry trig engine 5 because external trigger is asigned to 5
%     [ret, trigstruct] = CsMl_QueryTrigger(handle, 3);
    disp('Could not get trigger info for trigger');    
    for i = 1:sysinfo.TriggerCount
        trigstruct = TrigInfo(i);
        ret = -1;
        if ret < 1
            fprintf ('Current trigger parameters - Engine %d \n', i);
            if trigstruct.Source ~= 0
                if trigstruct.Slope == 0
                    s = 'Falling';
                elseif trigstruct.Slope == 1
                    s = 'Rising';
                else
                    s = sprintf('%d', trigstruct.Slope);
                end;
                str = sprintf('Slope: %s', s);
                disp(str);

                str = sprintf('Level: %d%%', trigstruct.Level);
                disp(str);

                if trigstruct.Source == -1
                    s = 'External';
                elseif trigstruct.Source == 0
                    s = 'Disabled';
                else
                    s = sprintf('Channel %d', trigstruct.Source);
                end;
                str = sprintf('Source: %s', s);
                disp(str);

                if trigstruct.ExtCoupling == 2
                    s = 'AC';
                    str = sprintf('External Coupling: %s', s);
                elseif trigstruct.ExtCoupling == 1
                    s = 'DC';
                    str = sprintf('External Coupling: %s', s);
                else
                    s = sprintf('%s', s);
                    str = sprintf('External Coupling: %d', trigstruct.ExtCoupling);
                end;
                disp(str);

                str = sprintf('External Range: %d mV', trigstruct.ExtRange);
                disp(str);
            end
        end
        disp(' ');
    end
end   
end

%%
if isShowAcq == true
    if AcqInfo.isUsingHWAvg == false
        transfer.Mode = CsMl_Translate('Default', 'TxMode');
    elseif AcqInfo.isUsingHWAvg == true
        transfer.Mode = CsMl_Translate('DATA32', 'TxMode');
    end
    % [ret, acqInfo] = CsMl_QueryAcquisition(handle);
    % acqInfo = AcqInfo;
    transfer.SegmentCount = AcqInfo.SegmentCount;
    transfer.StartSegment = 1;
    transfer.Segment = 1;
    transfer.Start = -AcqInfo.TriggerHoldoff;
    transfer.Length = AcqInfo.SegmentSize;    

    ret = CsMl_Capture(handle);
    %     [ret] = CsMl_ForceCapture(handle);
    CsMl_ErrorHandler(ret, 1, handle);
    % 
    status = CsMl_QueryStatus(handle);
    while status ~= 0
        if status == 0
            disp('0 = Ready for acquisition or data transfer');
        elseif status == 1
            disp('1 = Waiting for trigger event');
        elseif status == 2
            disp('2 = Triggered but still busy acquiring');
        elseif status == 3
            disp('3 = Data transfer is in progress');
        else
            disp('Status unkown.')
        end
        pause(1);
        status = CsMl_QueryStatus(handle);
    end
    % 
    % % Regardless  of the Acquisition mode, numbers are assigned to channels in a 
    % % CompuScope system as if they all are in use. 
    % % For example an 8 channel system channels are numbered 1, 2, 3, 4, .. 8. 
    % % All modes make use of channel 1. The rest of the channels indices are evenly
    % % spaced throughout the CompuScope system. To calculate the index increment,
    % % user must determine the number of channels on one CompuScope board and then
    % % divide this number by the number of channels currently in use on one board.
    % % The latter number is lower 12 bits of acquisition mode.
    % 
    MaskedMode = bitand(AcqInfo.Mode, 15);
    ChannelsPerBoard = sysinfo.ChannelCount / sysinfo.BoardCount;
    ChannelSkip = ChannelsPerBoard / MaskedMode;
    xaxis = MaskedMode;
    yaxis = sysinfo.BoardCount;
    % 
    % % If we have more than 4 channels in the x-axis, let's increase
    % % the number of rows so it looks better.
    % 
    % if xaxis > 4
    %     xaxis = xaxis / 2;
    %     yaxis = yaxis * 2;
    % end;

    %%
    %     % Transfer the data
    if AcqInfo.isUsingHWAvg == false
        transfer.Channel = 0;
        [ret, raw_data, dataInfo] = CsMl_TransferEx(handle, transfer); 
        CsMl_ErrorHandler(ret);
        dataInfo.SegmentCount = transfer.SegmentCount;
        dataInfo.Length =  transfer.Length;    
        [retval, data] = CsMl_ExtractEx(handle, raw_data, dataInfo, 0);
        data = squeeze(mean(double(data),2));
    elseif AcqInfo.isUsingHWAvg == true
        % % CsMl_TransferEx is not proved for FPGA averaging
        for i = 1:ChannelSkip:sysinfo.ChannelCount
            transfer.Channel = i;
            for j = 1:AcqInfo.SegmentCount
                transfer.Segment = j;
                [ret, raw_data(:,i), actual] = CsMl_Transfer(handle, transfer,1); 
                CsMl_ErrorHandler(ret);
                data(:,i) = (((AcqInfo.SampleOffset - double(raw_data(:,i)) / double(AcqInfo.nHWAvg)) / AcqInfo.SampleResolution) * (ChanInfo(i).InputRange / 2000)) + (ChanInfo(i).DcOffset / 1000);    
                data(:,i) = squeeze(mean(double(data(:,i)),3));
            end
        end
    end

    %     CsMl_ErrorHandler(ret, 1, handle);
    %     
    % 	% Note: to optimize the transfer loop, everything from
    % 	% this point on in the loop could be moved out and done
    % 	% after all the channels are transferred.
    %     
    %     % Adjust the size so only the actual length of data is saved to the
    %     % file
    %     length = size(data, 2);
    %     if length > actual.ActualLength
    %         data(actual.ActualLength:end) = [];
    %         length = size(data, 2);
    %     end;        
    %     
    %     % Get channel info for file header    
    %     [ret, chanInfo] = CsMl_QueryChannel(handle, i);    
    %     % Save the data to a file, one for each channel
    %     filename = sprintf('Coerce_CH%d.dat', i);
    %     % Get information for ASCII file header
    %     info.Start = actual.ActualStart;
    %     info.Length = actual.ActualLength;
    %     info.SampleSize = acqInfo.SampleSize;
    %     info.SampleRes = acqInfo.SampleResolution;
    %     info.SampleOffset = acqInfo.SampleOffset;   
    %     info.InputRange = chanInfo.InputRange;
    %     info.DcOffset = chanInfo.DcOffset;
    %     info.SegmentCount = acqInfo.SegmentCount;
    %     info.SegmentNumber = transfer.Segment;    
    % 
    %     CsMl_SaveFile(filename, data, info);
    %     % Adjust the horizontal axis and plot the data
    ImageNumber = 1;
    h_Fig = figure(10086);
    % h_Fig = figure();
    for i = 1:ChannelSkip:sysinfo.ChannelCount
        figure(h_Fig),
        subplot(xaxis, yaxis, ImageNumber); 
        plot(data(:,i));
        ylim([-ChanInfo(i).InputRange +ChanInfo(i).InputRange] .* 1.5 ./ 2000);
    %         xlim([0 actual.ActualLength]);
        grid on; grid minor;
        str = sprintf('Channel %d', i);
        title(str);    
        ImageNumber = ImageNumber + 1;
    end
end
    % ret = CsMl_FreeSystem(handle);
    