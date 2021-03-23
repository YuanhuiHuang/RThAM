function [sAvg, t_acq, t_tot] = gageAcq(handle, rawdata, nAvg)
t_start_acq_all = tic;

% Define how the data is transferred to Matlab from the DAQ system
transfer.Mode    = CsMl_Translate('Default', 'TxMode');
transfer.Segment = 1;

[ret, acqInfo]   = CsMl_QueryAcquisition(handle);

transfer.Start   = -acqInfo.TriggerHoldoff;
transfer.Length  = acqInfo.SegmentSize;
nPts             = transfer.Length;
Fs               = acqInfo.SampleRate;

if nargin == 1
    rawdata = 1;
    nAvg    = 1;
elseif nargin == 2
    nAvg = 1;
end

if rawdata
    s    = zeros(1, nPts, 'int16');
    sAvg = zeros(1, nPts, 'int16');
else
    s    = zeros(1, nPts, 'double');
    sAvg = zeros(1, nPts, 'double');
end

for i = 1:nAvg

    ret = CsMl_Capture(handle);                                                          % Start acquisition and await trigger event
    CsMl_ErrorHandler(ret, 1, handle);
    
    status = CsMl_QueryStatus(handle);
    
    while status ~= 0                                                                    % Wait until measurement is done (status = 0)
        status = CsMl_QueryStatus(handle);
    end
    
    transfer.Channel = 1;
    % rawdata        = 1;                                                                % 1: rawdata (ADC), 0: voltages
    
    t_trans_start = tic;
    
    [ret, s] = CsMl_Transfer(handle, transfer, rawdata);                                 % Transmit raw ADC data to Matlab
    CsMl_ErrorHandler(ret, 1, handle);

    sAvg = (s + sAvg*(i-1))/i;
end

t_trans = toc(t_trans_start);                                                        % Time for data transmission
t_acq   = nPts/Fs + t_trans;                                                         % Total acquisition time (samples + data transmission)
t_tot   = toc(t_start_acq_all);

end
