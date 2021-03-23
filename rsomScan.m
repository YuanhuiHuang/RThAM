function [S_, z_] = rsomScan(pi, DAQ)
dbstop if error;
MeasureFocus = 0;
PlotFlag     = 1;
AxesFlag     = 0;
FilterFlag   = 0;       % 1: Bandpass Filter / 2: Spatial & Bandpass Filter

%==========================================================================
% saveName = 'OLine17_wire_6kV_V3330_Scan01';
saveName = 'Oline25_Wire_6kV_Sona50_';

% All dimensions are in mm
% x0 = 34;    % OLine 25 V3330 34.75
% y0 = 20.90;
% z0 = 1.25; % circuit 25 focueed around 6.5mm; circuit 50 around 4.3mm 13.1 V390-13.65; v3330-2.6on edge; 1.3onbend
% x0 = 24;  % OLine 17
% y0 = 25;
% z0 = 0.70;   % OL17 V3330 Z0.6mm
x0 = 26.5;    % OLine 25 V3330
y0 = 18.5;
z0 = 0.20;
piMoveAbs(pi.piZ,z0);

Lx = 9;
Ly = 8;
Lz = 0;


RepRate    = 850;               % Repetition rate of the FID Pulser
% RepRate    = 1e3;               % FID Pulser rate, max 2 kHz

% Parameters for DAQ:
inputRange = 400;               % % [mV] 10000, 4000, 2000, 1000, 400, 200

transducer = 'TAM50';
switch transducer
    case 'TAM50'
%         trigDelay  = 8500;               % Focus at 1740 (1GS) / 870 (500MS)
%         nSamples   = 1024; %2048;        % Number of samples
%         ds = 0.01;
        Fs = 500e6;
        dt = 1/Fs;
%         t_0 = 16.5e-6;        t_end = 17.5e-6;  % us
%         t_0 = 8e-6;        t_end = 9e-6;  % us
        t_0 = 1.5e-6;  t_end = 7e-6;    % us
        trigDelay = t_0 * Fs;
        endpoint = t_end * Fs;
%         trigDelay  = 34500;               % Focus at 1740 (1GS) / 870 (500MS)
        nSamples   = (endpoint - trigDelay);
%         nSamples   = 4096; %2048;        % Number of samples
        ds = 0.025;
    case 'TAM100'
        Fs = 1000e6;
        dt = 1/Fs;
        t_0 = 18e-6;    % us
        t_end = 19e-6;  % us
        trigDelay = t_0 * Fs;
        endpoint = t_end * Fs;
%         trigDelay  = 34500;               % Focus at 1740 (1GS) / 870 (500MS)
        nSamples   = (endpoint - trigDelay);
%         nSamples   = 4096; %2048;        % Number of samples
        ds = 0.005;
    case 'RSOM100'
        trigDelay  = 18000;               % Focus at 1740 (1GS) / 870 (500MS)
        nSamples   = 1024; %2048;        % Number of samples
        ds = 0.008;
    case 'RSOM50'
        trigDelay  = 1250;               % Focus at 1740 (1GS) / 870 (500MS)
        nSamples   = 700; %2048;        % Number of samples
        ds = 0.05;
end

cdate = datestr(now,'yyyymmddHHMM');
saveName = [saveName '_' num2str(t_0*1e7) '-' num2str(t_end*1e7) 'us' '_' num2str(z0*1000)];
saveName = [cdate '_' saveName '_' transducer];

dx = ds;
dy = ds;
dz = ds;
%==========================================================================

acqRes  = 32;                    % Minimum number of samples
acqMode = 'Single';

% pi2xServoOn(pi,1);

swapXY = ~Ly;                     % 1: y-axis fast axis. 0: x-axis fast axis

if ~isequal(rem(Lx,dx),0)
    Lx = ceil(Lx/dx)*dx;
end
if ~isequal(rem(Ly,dy),0)
    Ly = ceil(Ly/dy)*dy;
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

[xAct, yAct] = pi2xGetPosition(pi);

vAct = RepRate*dx;

piSetVel(pi.piX, vAct);
piSetVel(pi.piY, vAct);

accAct = piGetAcc(pi.piX);
decAct = piGetDec(pi.piX);

userName = getenv('USERNAME');
if strcmp(userName, 'dominik.soliman')
    savePath = 'D:\Users\dominik.soliman\Documents\MATLAB\';
elseif strcmp(userName, 'murad.omar')
%     savePath = 'D:\Users\murad.omar\Documents\MATLAB\';
    savePath = [pwd, '\'];
elseif strcmp(userName, 'mathias.schwarz')
    savePath = 'D:\Users\mathias.schwarz\Documents\MATLAB\Data\';
elseif strcmp(userName, 'yuanhui.huang')
    savePath = 'D:\Users\yuanhui.huang\Documents\MATLAB\TAM\Data\';
end
saveDat = [savePath, saveName];
%Make sure the file doesn't already exist:
filesInDir = dir([savePath '*.mat']);
nFiles = length(filesInDir);
for ii = 1:nFiles
    fileExists = strcmp(filesInDir(ii).name(1:end-4), saveName);
%     fprintf('%i\n', ii);
    if fileExists
        choice = questdlg('The file name already exists, break?', ...
            'File name menu', ...
            'Continue','Break','Break');
        switch choice
            case 'Continue'
                break;
            case 'Break'
                return;
        end
    end
end

bScanPause = 0.1;                             % To get rid of vibrations

Nx    = round(diff(xLim)/dx + 1);
Ny    = round(diff(yLim)/dy + 1);
Ntot  = Nx*Ny;

t_tot = diff(xLim)/vAct;

trigDelay = floor(trigDelay/acqRes)*acqRes;
nSamples  = ceil(nSamples/acqRes)*acqRes;
nSegments = nSamples/acqRes;

% To inform the DAQ that we are acquiring in multirec mode:
segCount  = Nx;

Setup(DAQ, segCount, trigDelay, inputRange, nSegments, acqMode, transducer);       % Setup DAQ
CsMl_ResetTimeStamp(DAQ);
ret = CsMl_Commit(DAQ);
CsMl_ErrorHandler(ret, 1, DAQ);

[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);
CsMl_ErrorHandler(ret, 1, DAQ);
nPts = acqInfo.SegmentSize;
Fs   = acqInfo.SampleRate;
rawData = 1;

[ret, chInfo] = CsMl_QueryChannel(DAQ,1);
CsMl_ErrorHandler(ret, 1, DAQ);
InputRange = chInfo.InputRange;

% y = yLim(1):dy:yLim(2);
y = linspace(yLim(1), yLim(2), Ny);

positionXY = zeros(Ntot, 2);

S = zeros(Ntot, nPts, 'int16');

startTimeStr = datestr(now,'HH:MM:SS');
fprintf('\n**********************************************\n');
fprintf('Sampling rate is: \t\t\t\t %g MSps\n', Fs/1e6);
fprintf('Number of Measurements: \t\t %i \n', Ntot);
fprintf('Estimated Measurement Time: \t %.3g minutes\n', Ny*(t_tot + bScanPause)/60);
fprintf('Start time is:\t\t\t\t\t %s', startTimeStr);
fprintf('\n**********************************************\n\n');

tic;

pi2xMoveAbs(pi, xLim(1), y(1));

[xAct, yAct] = genPausePi([xLim(1),y(1)], [xAct, yAct], vAct);

% input('Move?');
direction = +1;

if Ntot > 50000
    NPrint   = 50;
    PlotFlag = 0;
else
    NPrint = 1;
end

for i = 1:Ny
    if direction > 0                      % Positive direction
        direction = direction*-1;
        
        if rem(i,NPrint) == 0
            fprintf('%6i \t B-Scan at %.5g \t Time left: %.3g minutes \n', ...
                    (i-1)*Nx+1, y(i), (Ny-i)*(t_tot + bScanPause)/60);
        end
        
        pi2xMoveAbs(pi, xLim(2), yAct);   % Move in x
        
        % Reset Time Stamp:
        CsMl_ResetTimeStamp(DAQ);
        
        % Start acquiring:
        ret = CsMl_Capture(DAQ);
        CsMl_ErrorHandler(ret, 1, DAQ);
        xAct = xLim(2);
        
        % Wait for measurement to finish:
        status = CsMl_QueryStatus(DAQ);
        
        while status ~= 0
            status = CsMl_QueryStatus(DAQ);
        end
        
        % Move to the next y-line
        pi2xMoveAbs(pi, xAct, yAct+ dy);
        yAct = yAct + dy;
        
        % Fetch the data:
        [s, tStamp] = fetchMulti(DAQ, Nx, acqMode, trigDelay,rawData);
        positionXY((1+(i-1)*Nx):Nx*i, 1) = tStamp*1e-6*vAct;
        S((1+(i-1)*Nx):Nx*i, :) = s;
        
%       pause(bScanPause);                % Change pause with data transfer
    else                                  % Negative direction
        direction = direction*-1;
        
        pi2xMoveAbs(pi, xLim(1), yAct);   % Move in x
        
        % Reset time Stamp:
        CsMl_ResetTimeStamp(DAQ);
        
        % Start acquiring:
        ret = CsMl_Capture(DAQ);
        CsMl_ErrorHandler(ret, 1, DAQ);
        xAct = xLim(1);
        
        % Wait for measurement to finish:
        status = CsMl_QueryStatus(DAQ);
        
        while status ~= 0
            status = CsMl_QueryStatus(DAQ);
        end
        
        % Move to the next y-line:
        pi2xMoveAbs(pi, xAct, yAct+dy);
        yAct = yAct+dy;
        
        %Fetch the data:
        [s, tStamp] = fetchMulti(DAQ, Nx, acqMode, trigDelay,rawData);
        positionXY(Nx*i:-1:(1+(i-1)*Nx), 1) = diff(xLim) - tStamp*1e-6*vAct;
        S(Nx*i:-1:(1+(i-1)*Nx), :) = s;
        
    end
    
    positionXY((1+(i-1)*Nx):i*Nx, 2) = yAct;
end

fprintf('\nAcquisition time: %g minutes\n', toc/60);

if MeasureFocus
   S = reshape(S, Ny, Nx, nPts);
end

if nargout > 0
    S_ = S;
    if nargout > 1
        tt = (trigDelay+1):(trigDelay+nSamples);
        z_ = (tt/Fs - 1.744e-6)*1510e6;
    end
end

fprintf('\nSaving...\n');

% cdate = datestr(now,'yyyymmddHHMMSS');
% cdate = datestr(now,'yyyymmddHHMM');
% 
% cdat = clock;
% if cdat(2) < 10
%     cdate = [num2str(cdat(1)) '0' num2str(cdat(2))];
% else
%     cdate = [num2str(cdat(1)) num2str(cdat(2))];
% end
% if cdat(3) < 10
%     cdate = [cdate '0' num2str(cdat(3))];
% else
%     cdate = [cdate num2str(cdat(3))];
% end
% if cdat(4) < 10
%     cdate = [cdate '0' num2str(cdat(4))];
% else
%     cdate = [cdate num2str(cdat(4))];
% end
% if cdat(5) < 10
%     cdate = [cdate '0' num2str(cdat(5))];
% else
%     cdate = [cdate num2str(cdat(5))];
% end

ShiftCorrFlag = 1;



% saveDat = [savePath, cdate, '_', saveName, '.mat'];
% saveDat = [savePath, saveName];
save(saveDat, 'S', 'xLim', 'yLim', 'dx', 'dy', 'dz', 'z0', 'positionXY', 'vAct',...
    'trigDelay', 'Fs', 'InputRange', 'ShiftCorrFlag', '-v7.3');

fprintf('\nTotal time: %g minutes\n', toc/60);

if PlotFlag
%    figure('units', 'normalized', 'position', [0.004 0.03 0.99 0.89]);
   figure;
   tt = (trigDelay+1):(trigDelay+nSamples);
   switch transducer
       case 'RSOM100'
           z_ = (tt/Fs - 1.744e-6)*1510e6;
       case 'RSOM50'
           z_ = (tt/Fs - 2.569e-6)*1510e6;
       case 'TAM50'
           z_ = (tt/Fs - 19.5e-6/2)*1510e6;
           tt_ = tt/Fs*1e6;
           z_ = tt_;
       case 'TAM100'
           z_ = (tt/Fs - 19.5e-6/2)*1510e6;
           tt_ = tt/Fs*1e6;
           z_ = tt_;
   end
   Ly = max(Ly, Lx); 
   
   if FilterFlag == 1
       S2 = filtsig(S, dy*1e-3, 0, 1);
   elseif FilterFlag == 2
       S2 = filtsig(S, dy*1e-3, 1, 1);
   else
       S2 = S;
   end
   
   if Ny == 1 && AxesFlag == 1
       imagesc(z_, [-Ly/2:ds:Ly/2], S2); colormap jet;  colorbar;
       xlabel('\mus'); ylabel('mm'); grid on;
   else
       imagesc(z_, [-Ly/2:ds:Ly/2], S2); colormap jet; colorbar;
       xlabel('\mus'); ylabel('mm'); grid on;
   end
end

pi2xMoveAbs(pi, x0, y0);
% pi2xError(pi);
% pi2xServoOn(pi,0);
% system('"C:\Program Files\SyncToy 2.1\SyncToyCmd.exe" "-R" "TAM_Data"')
end
