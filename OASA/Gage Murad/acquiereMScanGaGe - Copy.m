function S_ = acquiereMScanGaGeAra(DAQ);

%**************************************************************************
saveName = '20140128_bScan01_10uSpheres_-300_2';

vAct = 10;                                                                           % Set velocity of the stages
nAvg = 100;

% Parameters for DAQ:
acqRes     = 8;
inputRange = 100;                                                          % [mV]
trigDelay  = 100;                                                         % based on 1GSps
segCount   = 1;                                                            % this is the single acquisition code
nSamples   = 512; nSegments = ceil(nSamples/acqRes);

Setup(DAQ,segCount,trigDelay,inputRange,nSegments);                                                                         % Set acquisition, channel and trigger parameters
ret = CsMl_Commit(DAQ);                                                             % Pass parameters to DAQ system
CsMl_ErrorHandler(ret, 1, DAQ);

% DAQ = gageInit();

[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);                               % Get Acq. Info
trigDelay      = acqInfo.TriggerDelay;                                     % Save trigger delay for reconstruction

rawData    = 0;
nPts       = acqInfo.SegmentSize;                                          % Number of Samples

fprintf('Number of Measurements is: %i \n', Nx*Ny);

% S = zeros(Nx*Ny,nPts,'int16');                                           % Initialize Signal Matrix
S = zeros(nPts);                                                     % Initialize Signal Matrix

counter = 0;
tic;                                                                       % Start internal clock
    S(counter,:) = gageAcq(DAQ, rawData, nAvg);                            % Acquire Signals
toc;                                                                       % Stop internal clock

if nargout == 1                                                            % Print only on screen when S gets loaded
    S_ = S;
end

% freeGage(DAQ);                                                           % Free the system up

save(saveName, 'S', 'xLim', 'yLim', 'dx', 'dy', 'positionXY', 'trigDelay');
end