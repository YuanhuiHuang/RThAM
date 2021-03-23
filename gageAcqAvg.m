function [sAvg, ret] = gageAcqAvg(DAQ, rawdata, nAvg, hard_average, Chan)
% function [sAvg, t_acq, t_tot] = gageAcq(DAQ, rawdata, nAvg)
% t_start_acq_all = tic;

% Define how the data is transferred to Matlab from the DAQ system
%  transfer.Mode    = CsMl_Translate('Default', 'TxMode');
% %     if hard_average~=0
% %         transfer.Mode = CsMl_Translate('DATA32', 'TxMode');
% %     end

if nargin < 5
    Chan = 1;
    if nargin <4
        hard_average = 0;
        transfer.Mode    = CsMl_Translate('Default', 'TxMode');
        if nargin <3
            nAvg    = 1;
            if nargin < 2
                rawdata = 1;
            end
        end
    end
end

% transfer.Segment = 1;

[ret, acqInfo]   = CsMl_QueryAcquisition(DAQ);
% Data:
% rawdata               = 1;                          % 1) raw data, 0/nthg) voltages
transfer.Length       = acqInfo.SegmentSize;
transfer.Start   = -acqInfo.TriggerHoldoff;
nPts                  = transfer.Length;
% transfer.Length       = nPts;
transfer.StartSegment = 1;
transfer.SegmentCount = acqInfo.SegmentCount;       % 0) get all the channels
transfer.Mode = CsMl_Translate('DATA32', 'TxMode');
transfer.Channel = Chan;

s=zeros(transfer.SegmentCount,transfer.Length);
% if rawdata==1
%     if hard_average==0
%         s    = zeros(1, nPts, 'int16');
%         sAvg = zeros(1, nPts, 'int16');
%     elseif hard_average
%         s    = zeros(1, nPts, 'int32');
%         sAvg = zeros(1, nPts, 'int32');
%     end
% elseif rawdata==0
%     s    = zeros(1, nPts, 'double');
%     sAvg = zeros(1, nPts, 'double');
% end


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
    if ~rawdata
        s(i,:) = (((double(acqInfo.SampleOffset) - double(raw_data) / double(hard_average)) / double(acqInfo.SampleResolution)) * (double(chanInfo.InputRange) / 2000)) + (double(chanInfo.DcOffset) / 1000);    
    elseif rawdata
        s(i,:) = raw_data;
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
end

if nAvg>1
    % sAvg = sAvg + (s-sAvg)./nAvg;
    sAvg = mean(s,1);
else
    sAvg = s;
end

end
