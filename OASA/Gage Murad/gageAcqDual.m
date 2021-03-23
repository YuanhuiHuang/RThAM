function [s, e, t_acq, t_tot] = gageAcqDual(handle, nAvg)
tic;

transfer.Mode    = CsMl_Translate('Default', 'TxMode');
transfer.Segment = 1;

[ret, acqInfo]   = CsMl_QueryAcquisition(handle);

transfer.Start   = -acqInfo.TriggerHoldoff;
transfer.Length  = acqInfo.SegmentSize;
nPts             = transfer.Length;
Fs               = acqInfo.SampleRate;

if nargin == 1
    nAvg = 1;
end

E = zeros(nAvg, nPts);
S = zeros(nAvg, nPts);

for i = 1:nAvg
    ret = CsMl_Capture(handle);
    CsMl_ErrorHandler(ret, 1, handle);
    
    status = CsMl_QueryStatus(handle);
    
    while status ~= 0
        status = CsMl_QueryStatus(handle);
    end
    
    t_trans_start = tic;
    
    % Transfer the data:
    transfer.Channel = 1;
    rawdata          = 1; % 1: rawdata, 0/nthg: voltage
    
    [ret, S(i,:)]    = CsMl_Transfer(handle, transfer, rawdata);
    CsMl_ErrorHandler(ret, 1, handle);
    
    % Transfer the laser power:
    transfer.Channel   = 2;
    rawdata            = 0;
    
    [ret, E(i,:)] = CsMl_Transfer(handle, transfer, rawdata);
    CsMl_ErrorHandler(ret, 1, handle);
end

t_trans = toc(t_trans_start);                                                        % Time for data transmission
t_acq   = nPts/Fs + t_trans;                                                         % Total acquisition time (samples + data transmission) 

if nAvg > 1
    s = squeeze(mean(S));
else
    s = squeeze(S);
end

e = squeeze(E);
e = e(1:32);

% e = squeeze(mean(mean(E)));

t_tot = toc;
end