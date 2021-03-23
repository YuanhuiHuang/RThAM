function [S_, z_] = find_focus(pi,DAQ)
%% find_focus
% 20151105 by Yuanhui 
% mstart();
% piMoveAbs(pi.piZ, 2);
% 
% DAQ = gageInit();

PlotFlag   = 1;
FilterFlag = 0;

%**************************************************************************
saveName = 'Circuit25_fish+wire_7kV_Scan01';

vAct = 25;%mm/s                                                                           % Set velocity of the stages
nAvg = 50;% number of averages

% All dimensions are in mm
x0 = 26.4;
y0 = 23;
z0 = 5;

% range of travel
Lx = 0;
Ly = 0;
Lz = 10;


ds = 0.02;
dx = ds;
dy = ds;
dz = ds;

Fs = 500e6;
dt = 1/Fs;
t_0 = 17e-6;    % us
t_end = 19.5e-6;  % us
trigDelay = t_0 * Fs;
endpoint = t_end * Fs;
t = [t_0+dt:dt:t_end];
% nSegments = (endpoint - trigDelay) / 32;
% Parameters for DAQ:
inputRange = 2000;% [mV] 10000, 4000, 2000, 1000, 400, 200 
% trigDelay  = 0;% Focus at 1740 (1GS) / 870 (500MS)
nSamples   = (endpoint - trigDelay); %2048;        % Number of samples
detType    = 'TAM50';%TAM50: 500e6, TAM100: 1e9
%**************************************************************************

saveName = [saveName '_' num2str(t_0*1e7) '-' num2str(t_end*1e7) 'us' '_' 'AVG' num2str(nAvg)];

piMoveAbs(pi.piX, x0);
piMoveAbs(pi.piY, y0);


swapXY = Ly;                     % 1: y-axis fast axis. 0: x-axis fast axis

[xAct, yAct] = pi2xGetPosition(pi);            % Get position of the stages
zAct = piGetPosition(pi.piZ);

if ~isequal(rem(Lx,dx),0)
    Lx = ceil(Lx/dx)*dx;
end
if ~isequal(rem(Ly,dy),0)
    Ly = ceil(Ly/dy)*dy;
end
if ~isequal(rem(Lz,dz),0)
    Lz = ceil(Lz/dz)*dz;
end

if swapXY
    pi2.piX = pi.piY; pi2.piY = pi.piX; pi = pi2;
    
    intermediate = x0;
    x0 = y0;
    y0 = intermediate;

    intermediate = Lx;
    Lx = Ly;
    Ly = intermediate;
    
    intermediate = dx;
    dx = dy;
    dy = intermediate;
end

xLim = [x0-Lx/2 x0+Lx/2];
yLim = [y0-Ly/2 y0+Ly/2];
zLim = [z0-Lz/2 z0+Lz/2];

[X,Y] = generateSequence(xLim, yLim, dx, dy);
Nx    = size(X,1);                                                         % Number of TD x positions
Ny    = size(X,2);                                                         % Number of TD y positions
Z = [zLim(1):dz:zLim(2)]';
Nz = size(Z,1);

% Parameters for DAQ (please do not change):
acqRes    = 32;
segCount  = 1;                                                             % this is the single acquisition code
nSegments = ceil(nSamples/acqRes);

Setup(DAQ, segCount, trigDelay, inputRange, nSegments, 'Single', detType);                                                                         % Set acquisition, channel and trigger parameters
ret = CsMl_Commit(DAQ);                                                             % Pass parameters to DAQ system
CsMl_ErrorHandler(ret, 1, DAQ);

userName = getenv('USERNAME');
if strcmp(userName, 'dominik.soliman')
    savePath = 'D:\Users\dominik.soliman\Documents\MATLAB\';
elseif strcmp(userName, 'murad.omar')
%     savePath = 'D:\Users\murad.omar\Documents\MATLAB\';
    savePath = [pwd, '\'];
elseif strcmp(userName, 'rami.shnaiderman')
    savePath = [pwd, '\'];
elseif strcmp(userName, 'yuanhui.huang')
    savePath = 'D:\Users\yuanhui.huang\Documents\MATLAB\TAM\Data\';
end

% DAQ = gageInit();

piSetVel(pi.piX, vAct);
piSetVel(pi.piY, vAct);
piSetVel(pi.piZ, vAct);
vAct = piGetVel(pi.piX);                                                   % Get real velocity of the stages

accAct = piGetAcc(pi.piX);                                                 % Get Acceleration  of the stages
decAct = piGetDec(pi.piX);                                                 % Get Decceleration of the stages

[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);                               % Get Acq. Info
trigDelay      = acqInfo.TriggerDelay;                                     % Save trigger delay for reconstruction

rawData    = 0;
nPts       = acqInfo.SegmentSize;                                          % Number of Samples
Fs         = acqInfo.SampleRate;
positionXY = zeros(Nx*Ny,4);
positionZ  = zeros(Nz,4);


% fprintf('\nNumber of Measurements: %i \n\n', Nx*Ny);
fprintf('\nNumber of Measurements: %i \n\n', Nz);

% S = zeros(Nx*Ny,nPts,'int16');                                           % Initialize Signal Matrix
% S = zeros(Nx*Ny,nPts);                                                     % Initialize Signal Matrix
S = zeros(Nz,nPts);                                                     % Initialize Signal Matrix

counter = 0;
tic;                                                                       % Start internal clock

%% scan
for i = 1:Nz
    j = 1;
    counter = counter + 1;
    
%     pi2xMoveAbs(pi, X(j,i), Y(i));                                         % Move Stage to beginning of next y-Line                                                             % Time to start pause
    piMoveAbs(pi.piZ, Z(i));
%     [xAct, yAct] = genPausePi([X(j,i), Y(i)], [xAct, yAct], vAct);         % Pause the routine while moving to next position
    [zAct, yAct] = genPausePi([Z(i), Y(1)], [zAct, yAct], vAct);         % Pause the routine while moving to next position
    
    if rem(i,100) == 0
        fprintf('%i \t Target position: %g \n', counter, Z(i));
    end
    
    S(counter,:) = gageAcq(DAQ, rawData, nAvg);                            % Acquire Signals
    
%   [xAct, yAct] = pi2xGetPosition(pi);                                    % Get current position of the stage
%     positionXY(counter,:) = [X(j,i), Y(i), xAct, yAct];
    positionZ(counter,:) = [Z(i), Y(1), zAct, yAct];
    
    for j = 2:Nx
        counter = counter + 1;
        
%         pi2xMoveAbs(pi,X(j,i), 100);                                       % Move the stage to next x-position, don't move along y
        piMoveAbs(pi.piZ, Z(i));
%         genPausePi([X(j,i), Y(i)], [xAct, yAct], vAct);                    % Pause the stage while moving to next position
        [zAct, yAct] = genPausePi([Z(i), Y(1)], [zAct, yAct], vAct); 
        S(counter,:) = gageAcq(DAQ, rawData, nAvg);                        % Acquire Signals

%       [xAct, yAct] = pi2xGetPosition(pi);                                % Get current position of the stage
        zAct = zAct+ dz;
%         positionXY(counter,:) = [X(j,i), Y(i), xAct, yAct];
        positionZ(counter,:) = [Z(i), Y(1), zAct, yAct];
    end
end

toc; fprintf('\n');                                                          % Stop internal clock

piSetVel(pi.piX, 1);
piSetVel(pi.piY, 1);
piSetVel(pi.piZ, 1);
pi2xMoveAbs(pi, X(1,1), Y(1));
piSetVel(pi.piZ, Z(1));
% if nargout == 1                                                            % Print only on screen when S gets loaded
%     S_ = S;
% end

if nargout > 0
    S_ = S;
    
    if nargout > 1
        tt = (trigDelay+1):(trigDelay+nSamples);
        z_ = (tt/Fs - 1.744e-6)*1510e6;
    end
end

% freeGage(DAQ);                                                           % Free the system up

cdat = clock;
if cdat(2) < 10
    cdate = [num2str(cdat(1)) '0' num2str(cdat(2))];
else
    cdate = [num2str(cdat(1)) num2str(cdat(2))];
end
if cdat(3) < 10
    cdate = [cdate '0' num2str(cdat(3))];
else
    cdate = [cdate num2str(cdat(3))];
end

saveDat = [savePath, cdate, '_', saveName, '.mat'];

save(saveDat, 'S', 'xLim', 'yLim', 'dx', 'dy', 'x0', 'y0', 'positionXY', ...
              'trigDelay');
%% show_figure
if PlotFlag
   figure;
    
   tt = (trigDelay+1):(trigDelay+nPts);
%    z_ = (tt/Fs - 19.44e-6/2)*1510e6;
   z_ = [-Lz/2:dz:Lz/2];
   tt_ = tt/Fs*1e6;
   Ly = max(Ly, Lx);
   
   if FilterFlag
       S2 = filtS(S, dy*1e-3, 1, 1);
   else
       S2 = S;
   end
   
   if Nz == 1
       imagesc(tt_, z_, S2); colormap jet; colorbar; xlabel('\mus'); ylabel('mm'); grid on;
   else
       imagesc(tt_, z_, S2); colormap jet; colorbar; xlabel('\mus'); ylabel('mm'); grid on;
   end
   
   Max_Time = max(abs(S2),[],1);
   figure,plot(tt_,Max_Time);
   Max_Z = max(abs(S2),[],2);
   figure,plot([-Lz/2:dz:Lz/2],Max_Z);
   
end

end
