%New acquisition code, needs to be tested, now it is possible to acquire
%at >10kHz; the bottleneck is the transfer rate
% function [tt, s, tStamp] = gageAcqMulti(handle,nAcq)
function [s, tStamp] = gageAcqMulti(handle,nAcq)

% tStart = tic;
% Start acquiring:
% ret = CsMl_Capture(handle);
% CsMl_ErrorHandler(ret, 1, handle);
% tt(1) = toc(tStart);

%% moved outside
% status = CsMl_QueryStatus(handle);
% 
% while status ~= 0
%     status = CsMl_QueryStatus(handle);
% end

% tt(2) = toc(tStart);

% Transfer channel:
transfer.Channel = 1;

% tt(3) = toc(tStart);


[ret, acqInfo] = CsMl_QueryAcquisition(handle);
% tt(4) = toc(tStart);

% Data:
rawdata               = 1;                                                           % 1) raw data, 0/nthg) voltages
% transfer.Mode         = CsMl_Translate('Default', 'TxMode');
% tt(5) = toc(tStart);
transfer.Length       = acqInfo.SegmentSize;
% transfer.Start        = -acqInfo.TriggerHoldoff;
transfer.Start        = 0;
nPts                  = transfer.Length-transfer.Start;
transfer.Length       = nPts;
transfer.StartSegment = 1;
transfer.SegmentCount = acqInfo.SegmentCount;
transfer.Channel      = 1;                                                           % 0) get all the channels

% tt(6) = toc(tStart);

% [ret, s, out] = CsMl_TransferEx(handle, transfer);
[ret, s] = CsMl_TransferEx(handle, transfer);
s = reshape(s, nPts, nAcq)';

% tt(7) = toc(tStart);

% transfer.Mode         = CsMl_Translate('TimeStamp', 'TxMode');
% transfer.Length       = acqInfo.SegmentCount;
% transfer.Segment      = 1;
% [ret, tStamp, tickfr] = CsMl_Transfer(handle, transfer);
[ret, tStamp] = CsMl_TransferTimeStampEx(handle, transfer.StartSegment, transfer.SegmentCount);
% CsMl_ErrorHandler(ret, 1, handle);

% tt(8) = toc(tStart);
end