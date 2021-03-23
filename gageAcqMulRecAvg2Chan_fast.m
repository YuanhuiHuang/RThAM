function [sAvg, ret, tStamp] = gageAcqMulRecAvg2Chan_fast(DAQ, AcqInfo, ChanInfo)
% function [sAvg, t_acq, t_tot] = gageAcq(DAQ, rawdata, nAvg)
% t_start_acq_all = tic;

% Define how the data is transferred to Matlab from the DAQ system
%  transfer.Mode    = CsMl_Translate('Default', 'TxMode');
% %     if hard_average~=0
% %         transfer.Mode = CsMl_Translate('DATA32', 'TxMode');
% %     end
% v2, yuanhui 20190319. Reconsult FPGA avg and software avg

if AcqInfo.isUsingHWAvg == false
    transfer.Mode = CsMl_Translate('Default', 'TxMode');
elseif AcqInfo.isUsingHWAvg == true
    transfer.Mode = CsMl_Translate('DATA32', 'TxMode');
end
% [ret, acqInfo] = CsMl_QueryAcquisition(DAQ);
% acqInfo = AcqInfo;
transfer.SegmentCount = AcqInfo.SegmentCount;
transfer.StartSegment = 1;
transfer.Segment = 1;
transfer.Start = -AcqInfo.TriggerHoldoff;
transfer.Length = AcqInfo.SegmentSize;    

MaskedMode = bitand(AcqInfo.Mode, 15);
ChannelSkip = AcqInfo.ChannelCount / MaskedMode;

data=zeros(transfer.Length,transfer.SegmentCount,AcqInfo.nChan);
if AcqInfo.isUsingHWAvg == false
    if AcqInfo.nChan == 1
        transfer.Channel = AcqInfo.isUsingChan;
    else
        transfer.Channel = 0;
    end
    [ret, data, dataInfo] = CsMl_TransferEx(DAQ, transfer); 
    CsMl_ErrorHandler(ret);
    dataInfo.SegmentCount = transfer.SegmentCount;
    dataInfo.Length =  transfer.Length;    
    [retval, data] = CsMl_ExtractEx(DAQ, data, dataInfo, 0);
%     data = squeeze(mean(double(data),2));
elseif AcqInfo.isUsingHWAvg == true
    % % CsMl_TransferEx is not proved/provided for FPGA averaging
    for iChan = 1:ChannelSkip:AcqInfo.nChan
        if AcqInfo.nChan == 1
            transfer.Channel = AcqInfo.isUsingChan;
        else
            transfer.Channel = iChan;
        end
        for jSegm = 1:AcqInfo.SegmentCount
            transfer.Segment = jSegm;
            [ret, data(:,jSegm,iChan), actual] = CsMl_Transfer(DAQ, transfer,1); 
            CsMl_ErrorHandler(ret);
            data(:,jSegm,iChan) = (((AcqInfo.SampleOffset - double(data(:,jSegm,iChan)) / double(AcqInfo.nHWAvg)) / AcqInfo.SampleResolution) * (ChanInfo(iChan).InputRange / 2000)) + (ChanInfo(iChan).DcOffset / 1000);    
%             data = squeeze(mean(double(data),3));
        end
    end
end

if AcqInfo.tStampOn==1
    [ret, tStamp] = CsMl_TransferTimeStampEx(DAQ, transfer.StartSegment, transfer.SegmentCount);
    CsMl_ErrorHandler(ret);
elseif AcqInfo.tStampOn==0
    tStamp = 0;
end

if (AcqInfo.isAvg == true) && (AcqInfo.nSWAvg > 1)
    sAvg = mean(data,2);
elseif (AcqInfo.isAvg == false) || (AcqInfo.nSWAvg == 1)
    sAvg = data;
end



end

