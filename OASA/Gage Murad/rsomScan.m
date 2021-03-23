function S_ = rsomScan(pi,DAQ)

%====================================================================
saveName = 'bScan01M_suturesCross2250';

RepRate  = 2000;
acqRes   = 16;          % Minimum # of samples

Lx = 4.5;   dx = 0.0025;
Ly = 4.5;   dy = 0.0025;

swapXY  = Ly;           % 1: y-axis fast axis. 0: x-axis fast axis

% Parameters for DAQ; segCount is defined below:
inputRange = 1000;      % [mV]
trigDelay  = 3100;      % based on 1GSps - Focus at 1740
trigDelay  = floor(trigDelay/16)*16;
nSamples   = 600; nSamples = ceil(nSamples/acqRes)*acqRes;

x0   = 31;%32
y0   = 27;%27 
%====================================================================

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

%====================================================================

vAct = RepRate*dx;

[xAct, yAct] = pi2xGetPosition(pi);

piSetVel(pi.piX,vAct);
piSetVel(pi.piY,vAct);
accAct = piGetAcc(pi.piX);
decAct = piGetDec(pi.piX);

%=====================================================================

userName = getenv('USERNAME');

if strcmp(userName,'dominik.soliman')
    savePath = 'D:\Users\dominik.soliman\Documents\MATLAB\';
elseif strcmp(userName,'murad.omar')
    savePath = 'D:\Users\murad.omar\Documents\MATLAB\';
    savePath = [pwd, '\'];
end

% Define grid [mm]:
bScanPause = 0.1;                              % To get rid of vibrations

Nx = round(diff(xLim)/dx+ 1);
Ny = round(diff(yLim)/dy+ 1);

t_tot = diff(xLim)/vAct;

% To inform the DAQ that we are acquiring in multirec mode:
segCount   = Nx;
trigDelayI = 0;
nSegmentsI = (nSamples+ trigDelay)/16;

Setup(DAQ,segCount,trigDelayI,inputRange,nSegmentsI);
CsMl_ResetTimeStamp(DAQ);
ret = CsMl_Commit(DAQ);
CsMl_ErrorHandler(ret, 1, DAQ);

[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);
CsMl_ErrorHandler(ret, 1, DAQ);

nPts = nSamples;                               % nPts = acqInfo.SegmentSize;
% trigDelay = acqInfo.TriggerDelay;
Fs   = acqInfo.SampleRate;
[ret, chInfo] = CsMl_QueryChannel(DAQ,1);

InputRange = chInfo.InputRange;

y = yLim(1):dy:yLim(2);

positionXY = zeros(Nx*Ny,2);

S = zeros(Nx*Ny,nPts,'int16');

fprintf('\n**********************************************\n');
fprintf('Number of Measurements: \t\t %i \n', Nx*Ny);
fprintf('Estimated Measurement Time: \t %.3g minutes', Ny*(t_tot + bScanPause)/60);
fprintf('\n**********************************************\n\n');

% counter = 0;

tic;

pi2xMoveAbs(pi,xLim(1),y(1));

[xAct, yAct] = genPausePi([xLim(1),y(1)], [xAct, yAct], vAct);

direction = +1;

for i = 1:Ny
    if direction > 0 % positive direction
        direction = direction*-1;
        
        if rem(i,25) == 0
            fprintf('%i \t Target position: %g\t%g\n',(i-1)*Nx+1,xLim(2),y(i));
        end
        
        pi2xMoveAbs(pi,xLim(2),yAct);  % Move in x
        
        % Reset Time Stamp:
        CsMl_ResetTimeStamp(DAQ);
        
        % Start acquiring:
        ret = CsMl_Capture(DAQ);
        CsMl_ErrorHandler(ret, 1, DAQ);
        xAct = xLim(2);
        
        %Wait for measurement to finish:
        status = CsMl_QueryStatus(DAQ);
        while status ~= 0
            status = CsMl_QueryStatus(DAQ);
        end
        
        %Move to the next y-line
        pi2xMoveAbs(pi,xAct,yAct+ dy);
        yAct = yAct + dy;
        
        %Fetch the data:
        [s, tStamp] = gageAcqMulti(DAQ,Nx);
        positionXY((1+(i-1)*Nx):Nx*i,1) = tStamp*1e-6*vAct;
        S((1+(i-1)*Nx):Nx*i,:) = s(:,trigDelay+1:end);
        
%         pause(bScanPause);%Change the pause with the data transfer
    else % negative direction
        direction = direction*-1;
        
        pi2xMoveAbs(pi,xLim(1),yAct); % Move in x
        
        % Reset time Stamp:
        CsMl_ResetTimeStamp(DAQ);
        
        % Start acquiring:
        ret = CsMl_Capture(DAQ);
        CsMl_ErrorHandler(ret, 1, DAQ);
        xAct = xLim(1);
        
        %Wait for measurement to finish:
        status = CsMl_QueryStatus(DAQ);
        while status ~= 0
            status = CsMl_QueryStatus(DAQ);
        end
        
        %Move to the next y-line:
        pi2xMoveAbs(pi,xAct,yAct+ dy);
        yAct = yAct+ dy;
        
        %Fetch the data:
        [s, tStamp] = gageAcqMulti(DAQ,Nx);
        positionXY(Nx*i:-1:(1+(i-1)*Nx),1) = diff(xLim) - tStamp*1e-6*vAct;
        S(Nx*i:-1:(1+(i-1)*Nx),:) = s(:,trigDelay+1:end);
        
    end
    
    positionXY((1+(i-1)*Nx):i*Nx,2) = yAct;
end

fprintf('\nAcquisition time: %g minutes\n', toc/60);

if nargout == 1
    S_ = S;
end

fprintf('\nSaving...\n');

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

ShiftCorrFlag = 1;

dbstop if error;

saveDat = [savePath, cdate, '_', saveName, '.mat'];

save(saveDat, 'S', 'xLim', 'yLim', 'dx', 'dy', 'positionXY', 'vAct',...
    'trigDelay', 'Fs', 'InputRange', 'ShiftCorrFlag', '-v7.3');

fprintf('\nTotal time: %g minutes\n', toc/60);
end