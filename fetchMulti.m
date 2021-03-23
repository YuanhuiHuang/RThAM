% Fetch a multirecord data, now it is possible to acquire
% at >10kHz; the bottleneck is the transfer rate
% function [s1, tStamp, s2] = fetchMulti(DAQ, nAcq, acqMode, trigDelay,rawdata,tStampOn)
function [s, tStamp, varargout] = fetchMulti(DAQ, nAcq, acqMode, trigDelay,rawdata,tStampOn, nAvg)
if nargin < 6
    nAvg = 1;
    if nargin <5
        tStampOn=1;
        if nargin < 5
            rawdata = 	1;% 1) raw data, 0/nthg) voltages
            if nargin < 4
                trigDelay = 0;

                if nargin < 3
                    acqMode = 'single';
                end
            end
        end
    end
end
acqMode = lower(acqMode);

switch acqMode
    case 'single'                                   % do nothing
        transfer.Channel = 1;
    case 'dual'                                     % do nothing
        transfer.Channel = 0;                       % get all the channels
    otherwise
        error 'Invalid acquisition mode\n';
end

[ret, acqInfo]        = CsMl_QueryAcquisition(DAQ);

% Data:
% rawdata               = 1;                          % 1) raw data, 0/nthg) voltages
transfer.Length       = acqInfo.SegmentSize;
transfer.Start        = trigDelay;
nPts                  = transfer.Length;
transfer.Length       = nPts;
transfer.StartSegment = 1;
transfer.SegmentCount = acqInfo.SegmentCount;       % 0) get all the channels

s=zeros(transfer.SegmentCount,transfer.Length);
[ret, s, out] = CsMl_TransferEx(DAQ, transfer);

if tStampOn==1
    [ret, tStamp] = CsMl_TransferTimeStampEx(DAQ, transfer.StartSegment, transfer.SegmentCount);
    CsMl_ErrorHandler(ret, 1, DAQ);
elseif tStampOn==0
    tStamp = 0;
end

switch acqMode
    case 'single'                                   % do nothing
        s = reshape(s, nPts, nAcq)';
        if nAvg > 1
            s = mean(s,1);
        end
        if (1 == rawdata)
            return;
        end
% If rawdata is not 1, or is not even passed as a parameter
% convert the data to volts
% Get the SampleResolution and SampleOffset from QueryAcqusition rather
% then from GetSystemInfo because these values might change if FPGA images
% are loaded
        [ret, chan] = CsMl_QueryChannel(DAQ, transfer.Channel);
        s = (((acqInfo.SampleOffset - double(s)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000);

    case 'dual'                                     % do nothing
%       dataInfo.DataFormat   = out.DataFormat;
%       dataInfo.ChannelCount = out.ChannelCount;
%       dataInfo.Length       = transfer.Length;
%       dataInfo.SegmentCount = transfer.SegmentCount;
%       [ret, s]              = CsMl_ExtractEx(DAQ, s, dataInfo);

        s1           = zeros(1,length(s)/2,'int16');
        s2           = s1;
        
        s1(1:2:end)          = s(1:4:end);
        s1(2:2:end)          = s(2:4:end);
        s2(1:2:end)          = s(3:4:end);
        s2(2:2:end)          = s(4:4:end);
        
%         s1(1:2:end)  = ss1;
%         s1(2:2:end)  = ss2;
%         s2(1:2:end)  = ss3;
%         s2(2:2:end)  = ss4;
        
        s1            = reshape(s1, nPts, nAcq)';
        s2            = reshape(s2, nPts, nAcq)';

        if nAvg>1
            [ret, chan] = CsMl_QueryChannel(DAQ, 1); 
            s = mean((((acqInfo.SampleOffset - double(s1)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000),1);
            [ret, chan] = CsMl_QueryChannel(DAQ, 2); 
            varargout{1} = mean((((acqInfo.SampleOffset - double(s2)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000),1);
        elseif nAvg==1
            [ret, chan] = CsMl_QueryChannel(DAQ, 1); 
            s = (((acqInfo.SampleOffset - double(s1)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000);
            [ret, chan] = CsMl_QueryChannel(DAQ, 2); 
            varargout{1} = (((acqInfo.SampleOffset - double(s2)) / acqInfo.SampleResolution) * (chan.InputRange / 2000)) + (chan.DcOffset / 1000);
        end
    otherwise
        error 'Invalid acquisition mode\n';
end



end
