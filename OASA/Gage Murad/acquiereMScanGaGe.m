function S_ = acquiereMScanGaGe(pi,DAQ)
[xAct, yAct] = pi2xGetPosition(pi);                                                  % Get position of the stages

%**************************************************************************
saveName = '20140128_bScan01_10uSpheres_-300_2';

vAct = 10;                                                                           % Set velocity of the stages
nAvg = 100;

x0 = 33.10;     Lx = 0;    dx = 0.0025;
y0 = 28.01;     Ly = 2;    dy = 0.0025;

xLim = [x0-Lx/2 x0+Lx/2];
yLim = [y0-Ly/2 y0+Ly/2];
%**************************************************************************

[X,Y] = generateSequence(xLim, yLim, dx, dy);
Nx    = size(X,1);                                                         % Number of TD x positions
Ny    = size(X,2);                                                         % Number of TD y positions

% Parameters for DAQ:
acqRes     = 32;
inputRange = 2000;                                                          % [mV]
trigDelay  = 1000;                                                         % based on 1GSps
segCount   = 1;                                                            % this is the single acquisition code
nSamples   = 1024; nSegments = ceil(nSamples/acqRes);

Setup(DAQ,segCount,trigDelay,inputRange,nSegments);                                                                         % Set acquisition, channel and trigger parameters
ret = CsMl_Commit(DAQ);                                                             % Pass parameters to DAQ system
CsMl_ErrorHandler(ret, 1, DAQ);

% DAQ = gageInit();

piSetVel(pi.piX, vAct);
piSetVel(pi.piY, vAct);
vAct = piGetVel(pi.piX);                                                   % Get real velocity of the stages

accAct = piGetAcc(pi.piX);                                                 % Get Acceleration  of the stages
decAct = piGetDec(pi.piX);                                                 % Get Decceleration of the stages

[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);                               % Get Acq. Info
trigDelay      = acqInfo.TriggerDelay;                                     % Save trigger delay for reconstruction

rawData    = 0;
nPts       = acqInfo.SegmentSize;                                          % Number of Samples
positionXY = zeros(Nx*Ny,4);

fprintf('Number of Measurements is: %i \n', Nx*Ny);

% S = zeros(Nx*Ny,nPts,'int16');                                           % Initialize Signal Matrix
S = zeros(Nx*Ny,nPts);                                                     % Initialize Signal Matrix

counter = 0;
tic;                                                                       % Start internal clock

for i = 1:Ny
    j = 1;
    counter = counter + 1;
    
    pi2xMoveAbs(pi, X(j,i), Y(i));                                         % Move Stage to beginning of next y-Line
%   tPS = tic;                                                             % Time to start pause
    [xAct, yAct] = genPausePi([X(j,i), Y(i)], [xAct, yAct], vAct);         % Pause the routine while moving to next position
    
    if rem(i,50) == 0
        fprintf('%i \t Target position: %g \t %g \n', counter, X(j,i), Y(i));
    end
    
    S(counter,:) = gageAcq(DAQ, rawData, nAvg);                            % Acquire Signals
    
%   [xAct, yAct] = pi2xGetPosition(pi);                                    % Get current position of the stage
    positionXY(counter,:) = [X(j,i), Y(i), xAct, yAct];
    
    for j = 2:Nx
        counter = counter + 1;
        
        pi2xMoveAbs(pi,X(j,i), 100);                                       % Move the stage to next x-position, don't move along y
        genPausePi([X(j,i), Y(i)], [xAct, yAct], vAct);                    % Pause the stage while moving to next position
        
        S(counter,:) = gageAcq(DAQ, rawData, nAvg);                        % Acquire Signals

%       tPS = tic;
%       fprintf('%i \t Target position: %g \t %g \n',counter,X(j,i),Y(i));

%       [xAct, yAct] = pi2xGetPosition(pi);                                % Get current position of the stage
        xAct = xAct+ dx;
        positionXY(counter,:) = [X(j,i), Y(i), xAct, yAct];
    end
end

toc;                                                                       % Stop internal clock

if nargout == 1                                                            % Print only on screen when S gets loaded
    S_ = S;
end

% freeGage(DAQ);                                                           % Free the system up

save(saveName, 'S', 'xLim', 'yLim', 'dx', 'dy', 'positionXY', 'trigDelay');
end
