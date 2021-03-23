%Acquire signals from the DAQ Card

function [sAvg] = gageAcq(handle,m, rawdata, nAvg)
% m is the point
% t_start_acq_all = tic;

% Define how the data is transferred to Matlab from the DAQ system
transfer.Mode    = CsMl_Translate('Default', 'TxMode');
transfer.Segment = 1;
[ret, sysinfo] = CsMl_GetSystemInfo(handle);
[ret, acqInfo]   = CsMl_QueryAcquisition(handle); %to get the parameters set in Setup.m
transfer.Start   = -acqInfo.TriggerHoldoff;
transfer.Length  = acqInfo.SegmentSize;
nPts             = transfer.Length;
Fs               = acqInfo.SampleRate;
MaskedMode = bitand(acqInfo.Mode, 15);

ChannelsPerBoard = sysinfo.ChannelCount / sysinfo.BoardCount;
ChannelSkip = ChannelsPerBoard / MaskedMode;

if nargin == 2
    rawdata = 1;
    nAvg    = 1;
elseif nargin == 3
    nAvg = 1;
end

if rawdata
    s    = zeros(1, nPts, 'int16');
    sAvg = zeros(1, nPts, 'int16');
else
    s    = zeros(1, nPts, 'double');
    sAvg = zeros(1, nPts, 'double');
end

for ii = 1:ChannelSkip:sysinfo.ChannelCount
    ii

    ret = CsMl_Capture(handle);     %the acquisition is initiated    % Start acquisition and await ger event
    CsMl_ErrorHandler(ret, 1, handle);
    
    status = CsMl_QueryStatus(handle);%The state of the CompuScope system is queried using CsMl_QueryStatus(handle) until the acquisition has completed.
    
    while status ~= 0                 % continue querying until acquisition is done (status = 0)
        status = CsMl_QueryStatus(handle);
    end
    
%     t_trans_start = tic; 
    
    transfer.Channel = ii;
    
     for j = 1:nAvg
    % Transfer the data
        % rawdata        = 1;                                                                % 1: rawdata (ADC), 0: voltages
%     [ret, data, actual] = CsMl_Transfer(handle, transfer);
    [ret, s,actual] = CsMl_Transfer(handle, transfer, rawdata);                                 % Transmit raw ADC data to Matlab
    CsMl_ErrorHandler(ret, 1, handle);
%   sAvg = (s + sAvg*(i-1))/i;
    sAvg = sAvg + s/nAvg;
    
     end
     
    length = size(s, 2);
    if length > actual.ActualLength
        data(actual.ActualLength:end) = [];
        length = size(data, 2);
    end;        
    
    % Get channel info for file header    
    [ret, chanInfo] = CsMl_QueryChannel(handle, ii);
    % Save each channel to a seperate file
    filename = sprintf('Acquire_CH%d_p%d.bin', ii,m);
    % Get information for ASCII file header    
    info.Start = actual.ActualStart;
    info.Length = actual.ActualLength;
    info.SampleSize = acqInfo.SampleSize;
    info.SampleRes = acqInfo.SampleResolution;
    info.SampleOffset = acqInfo.SampleOffset;
    info.InputRange = chanInfo.InputRange;
    info.DcOffset = chanInfo.DcOffset;
    info.SegmentCount = acqInfo.SegmentCount;
    info.SegmentNumber = transfer.Segment;
    
    
    act_date = strcat(date,'\'); % actual date for actual file path
    path_main = (strcat('H:\measurement\',act_date)); % path where data is stored
    cd(path_main) % set the current directory to path_main
    path_act = strcat('slice_',num2str(1));
            
    % check if folder already exists
    chk_folder =  exist(strcat(path_main,path_act),'dir');
    if chk_folder == 0
       mkdir(path_act)
    end
    clear chk_folder
    
    % SAVING/WRITING DATA INTO FILES
    % file path - variable
    cd(path_act)     
    CsMl_SaveFile(filename, s, info);
    
end

% t_trans = toc(t_trans_start);                                                        % Time for data transmission
% t_acq   = nPts/Fs + t_trans;                                                         % Total acquisition time (samples + data transmission)
% t_tot   = toc(t_start_acq_all);

end
