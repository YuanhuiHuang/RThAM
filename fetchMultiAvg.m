% Fetch a multirecord data, now it is possible to acquire
% at >10kHz; the bottleneck is the transfer rate
% function [s1, tStamp, s2] = fetchMulti(DAQ, nAcq, acqMode, trigDelay,ISRawData,tStampOn)
function [s, tStamp, varargout] = fetchMultiAvg(DAQ, nAcq, acqMode, ...
                        trigDelay,ISRawData,tStampOn, nAvg, hard_average)
if nargin < 8
    hard_average = 1;
    transfer.Mode    = CsMl_Translate('Default', 'TxMode');
    if nargin < 7
        nAvg = 1;
        if nargin <6
            tStampOn=1;
            if nargin < 5
                ISRawData = 	1;% 1) raw data, 0/nthg) voltages
                if nargin < 4
                    trigDelay = 0;
                    if nargin < 3
                        acqMode = 'single';
                    end
                end
            end
        end
    end
elseif (nargin==8)&&(hard_average>1)
    transfer.Mode = CsMl_Translate('DATA32', 'TxMode');
end

acqMode = lower(acqMode);

switch acqMode
    case 'single'                                   % do nothing
%         transfer.Channel = 1;
        ChanCount = 1;
    case 'dual'                                     % do nothing
%         transfer.Channel = 0;                       % get all the channels 
        % transferEx is not available for hardware average mode because it provides only data format of 16 bit.
        ChanCount = 2;
    otherwise
        error 'Invalid acquisition mode\n';
end

[ret, acqInfo]        = CsMl_QueryAcquisition(DAQ);

% Data:
% ISRawData               = 1;                          % 1) raw data, 0/nthg) voltages
transfer.Length       = acqInfo.SegmentSize;
transfer.Start        = trigDelay;
nPts                  = transfer.Length;
% transfer.Length       = nPts;
transfer.StartSegment = 1;
transfer.SegmentCount = acqInfo.SegmentCount;       % 0) get all the channels

if nAvg<=1
    s=zeros(transfer.SegmentCount, transfer.Length, ChanCount);
elseif nAvg>1
    s    = zeros(1, transfer.Length, ChanCount);
end

for Chan = 1:ChanCount
    transfer.Channel = Chan;
    % Get channel info for file header    
    [ret, chanInfo] = CsMl_QueryChannel(DAQ, Chan);            
    CsMl_ErrorHandler(ret, 1, DAQ);

    for i = 1:acqInfo.SegmentCount
        transfer.Segment = i;
        % In this sample we are transferring the raw data (which is co-added)
        % and doing the conversion to voltages ourselves. In the conversion we
        % are also dividing the data by the number of averages to end up with
        % the averaged data. Otherwise, our Dc offset would be wrong.
        % Alternatively, we could transfer the data back as voltages (by not
        % using the last 1 in CsMl_Transfer), but we would have to multiply the
        % Dc offset by the number of averages when (and if) we converted the
        % data to voltages
    
        [ret, raw_data, actual] = CsMl_Transfer(DAQ, transfer, 1);
        CsMl_ErrorHandler(ret, 1, DAQ);

    	% Note: to optimize the transfer loop, everything from
    	% this point on in the loop could be moved out and done
    	% after all the channels are transferred.
        
        % Convert to volts and divide by the number of averages
%       data = (((acqInfo.SampleOffset - double(raw_data / averagecount)) / acqInfo.SampleResolution) * (chanInfo.InputRange / 2000)) + (chanInfo.DcOffset / 1000);    

        
        if nAvg<=1
            if ~ISRawData
                s(i,:,Chan) = (((double(acqInfo.SampleOffset) - double(raw_data) / double(hard_average)) / double(acqInfo.SampleResolution)) * (double(chanInfo.InputRange) / 2000)) + (double(chanInfo.DcOffset) / 1000);
            elseif ISRawData
                s(i,:,Chan) = raw_data;
            end
        elseif nAvg>1
            s(1,:,Chan) = s(1,:,Chan) + ((((double(acqInfo.SampleOffset) - double(raw_data) / double(hard_average)) / double(acqInfo.SampleResolution)) * (double(chanInfo.InputRange) / 2000)) + (double(chanInfo.DcOffset) / 1000) - s(1,:,Chan)) ./ nAvg;
        end
        
%         % Get information for ASCII file header
%         info.Start = actual.ActualStart;
%         info.Length = actual.ActualLength;
%         info.SampleSize = acqInfo.SampleSize;
%         info.SampleRes = acqInfo.SampleResolution;
%         info.SampleOffset = acqInfo.SampleOffset;
%         info.InputRange = chanInfo.InputRange;
%         info.DcOffset = chanInfo.DcOffset;
%         info.SegmentCount = acqInfo.SegmentCount;
%         info.SegmentNumber = i;
%         % There's no time stamp info with multiple record averaging
%         info.TimeStamp = 0;

%         filename = sprintf(format_string, 'MulRecAveraging', transfer.Channel, i);
%         CsMl_SaveFile(filename, data, info);
    end;
    
end;   
    
% Adjust the size so only the actual length of data is saved to the
% file
if size(s, 2) > actual.ActualLength
    s(:,actual.ActualLength:end,:) = [];
end;    

if Chan==2
    varargout{1} = s(:,:,2);
    s(:,:,2) = [];
elseif Chan==1
    varargout{1} = 0;
end


% [ret, s, out] = CsMl_TransferEx(DAQ, transfer);
% CsMl_ErrorHandler(ret, 1, DAQ);
if tStampOn==1
    [ret, tStamp] = CsMl_TransferTimeStampEx(DAQ, transfer.StartSegment, transfer.SegmentCount);
    CsMl_ErrorHandler(ret, 1, DAQ);
elseif tStampOn==0
    tStamp = 0;
end

% 
% switch acqMode
%     case 'single'                                   % do nothing
%         s = reshape(s, nPts, nAcq)';
%         if nAvg > 1
%             s = mean(s,1);
%         end
%         if (1 == ISRawData)
%             return;
%         end
% % If ISRawData is not 1, or is not even passed as a parameter
% % convert the data to volts
% % Get the SampleResolution and SampleOffset from QueryAcqusition rather
% % then from GetSystemInfo because these values might change if FPGA images
% % are loaded
%         [ret, chan] = CsMl_QueryChannel(DAQ, transfer.Channel);
%         if hard_average>1
%             s = (((acqInfo.SampleOffset - double(s)./hard_average) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000);
%         else
%             s = (((acqInfo.SampleOffset - double(s)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000);
%         end
% 
%     case 'dual'                                     % do nothing
% %       dataInfo.DataFormat   = out.DataFormat;
% %       dataInfo.ChannelCount = out.ChannelCount;
% %       dataInfo.Length       = transfer.Length;
% %       dataInfo.SegmentCount = transfer.SegmentCount;
% %       [ret, s]              = CsMl_ExtractEx(DAQ, s, dataInfo);
%         if hard_average>1
%             DataType = 'int32';
%         else
%             DataType = 'int16';
%         end
%         s1           = zeros(1,length(s)/2, DataType);
%         s2           = s1;
%         
%         s1(1:2:end)          = s(1:4:end);
%         s1(2:2:end)          = s(2:4:end);
%         s2(1:2:end)          = s(3:4:end);
%         s2(2:2:end)          = s(4:4:end);
%         
% %         s1(1:2:end)  = ss1;
% %         s1(2:2:end)  = ss2;
% %         s2(1:2:end)  = ss3;
% %         s2(2:2:end)  = ss4;
%         
%         s1            = reshape(s1, nPts, nAcq)';
%         s2            = reshape(s2, nPts, nAcq)';
%         
% %         if hard_average>=1
% %             s1 = s1 ./ hard_average;
% %             s2 = s2 ./ hard_average;
% %         end
%         if hard_average >1
%             if nAvg>1
%                 [ret, chan] = CsMl_QueryChannel(DAQ, 1); 
%                 s = mean((((acqInfo.SampleOffset - double(s1) / double(hard_average)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000),1);
%                 [ret, chan] = CsMl_QueryChannel(DAQ, 2); 
%                 varargout{1} = mean((((acqInfo.SampleOffset - double(s2) / double(hard_average)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000),1);
%             elseif nAvg==1
%                 [ret, chan] = CsMl_QueryChannel(DAQ, 1); 
%                 s = (((acqInfo.SampleOffset - double(s1) / double(hard_average)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000);
%                 [ret, chan] = CsMl_QueryChannel(DAQ, 2); 
%                 varargout{1} = (((acqInfo.SampleOffset - double(s2)/ double(hard_average)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000);
%             end
%         else
%             if nAvg>1
%                 [ret, chan] = CsMl_QueryChannel(DAQ, 1); 
%                 s = mean((((acqInfo.SampleOffset - double(s1)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000),1);
%                 [ret, chan] = CsMl_QueryChannel(DAQ, 2); 
%                 varargout{1} = mean((((acqInfo.SampleOffset - double(s2)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000),1);
%             elseif nAvg==1
%                 [ret, chan] = CsMl_QueryChannel(DAQ, 1); 
%                 s = (((acqInfo.SampleOffset - double(s1)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000);
%                 [ret, chan] = CsMl_QueryChannel(DAQ, 2); 
%                 varargout{1} = (((acqInfo.SampleOffset - double(s2)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000);
%             end
%         end
%     otherwise
%         error 'Invalid acquisition mode\n';
% end



end
