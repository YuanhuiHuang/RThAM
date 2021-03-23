function [S_] = acqMScan0(pi, DAQ)

%**************************************************************************
saveName = 'cScan01_R6GTest';

RepRate  = 1500;

Lx   = 0.5;   dx = 0.0025;         % [mm]
Ly   = 0;   dy = 0.0025;         % [mm]

x0   = 33;                         % [mm]
y0   = 23;                         % [mm]
%**************************************************************************

swapXY  = Ly;                      % 1: y-axis fast axis 0:x-axis fast axis

% Parameters for DAQ:
acqRes     = 16;
inputRange = 2000;                 % [mV]
trigDelay  =  1500;                % based on 1GSps
segCount   = 1;                    % this is the single acquisition code
nSamples   = 1024;
nSegments  = ceil(nSamples/acqRes);

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

% Parameters for stage:
vAct       = RepRate*dx;
bScanPause = 0.1;

[xAct, yAct] = pi2xGetPosition(pi);

piSetVel(pi.piX,vAct);
piSetVel(pi.piY,vAct);
vAct = piGetVel(pi.piX);

Setup(DAQ,segCount,trigDelay,inputRange,nSegments);                                                                         % Set acquisition, channel and trigger parameters
ret = CsMl_Commit(DAQ);                                                             % Pass parameters to DAQ system
CsMl_ErrorHandler(ret, 1, DAQ);

userName = getenv('USERNAME');
if strcmp(userName,'dominik.soliman')
    savePath = 'D:\Users\dominik.soliman\Documents\MATLAB\';
elseif strcmp(userName,'ara.ghazaryan')
    savePath = 'D:\Users\ara.ghazaryan\Documents\MATLAB\';
elseif strcmp(userName,'murad.omar')
    savePath = 'D:\Users\murad.omar\Documents\MATLAB\';
    savePath = [pwd, '\'];
end

waitFactor = 0.0;                                                                    % Extend timespan between measurements if vAct too low

Nx    = round(diff(xLim)/dx+1);
Ny    = round(diff(yLim)/dy+1);

y     = yLim(1):dy:yLim(2);
t_tot = diff(xLim)/vAct;

[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);
[ret, chInfo]  = CsMl_QueryChannel(DAQ, 1);

trigDelay  = acqInfo.TriggerDelay;
nPts       = acqInfo.SegmentSize;
Fs         = acqInfo.SampleRate;
InputRange = chInfo.InputRange;

% nPtsE    = 32;
positionXY = zeros(Nx*Ny, 2);

fprintf('\n**********************************************\n');
fprintf('Number of Measurements: \t\t %i \n', Nx*Ny);
fprintf('Estimated Measurement Time: \t %.3g minutes', Ny*(t_tot + bScanPause)/60);
fprintf('\n**********************************************\n\n');

S = zeros(Nx*Ny, nPts, 'int16');
% E = zeros(Nx*Ny, nPtsE, 'double');

counter     = 0;
t_start_all = tic;

pi2xMoveAbs(pi, xLim(1), y(1));
[xAct, yAct] = genPausePi([xLim(1), y(1)], [xAct, yAct], vAct);

direction = +1;

for i = 1:Ny
    if Ny > 10
        if rem(i,100) == 0
            fprintf('%6i \t B-Scan at y = %.4g \t Time left: %.3g minutes \n', counter, ...
                y(i), (Ny-i)*(t_tot + 0.12)/60);
        end
    else
        fprintf('%6i \t B-Scan at y = %.4g \t Time left: %.3g minutes \n', counter, ...
                y(i), (Ny-i)*(t_tot + 0.12)/60);
    end

    if direction > 0                                                                 % Positive x-direction
        direction = direction* -1;
        
        pi2xMoveAbs(pi, xAct, y(i));                                                 % Move to beginning of B-line
        pause(bScanPause); yAct = y(i);                                                     % Wait, until transducer arrives
        pi2xMoveAbs(pi, xLim(2), yAct);                                              % Start B-scan
        
        t_start = tic;
        
        for j = 1:Nx
            counter = counter + 1;

%           [S(counter, :), E(counter, :), t_acq, t_measure] = gageAcqDual(DAQ);     % Acquire signals and get acquisition time
            [S(counter, :), t_acq, t_measure] = gageAcq(DAQ);

            positionXY(counter, 1) = vAct*(toc(t_start) - t_acq);                    % x-position right after trigger event [mm]
%           positionXY(counter, 1) = toc(t_start); 

            if (toc(t_start) - t_acq) > diff(xLim)/vAct                              % Stop acquisition at end of B-line
                continue;
            end
            
            t_pause = tic;
            t_wait  = toc(t_pause);
            
            while t_wait < (dx/vAct - t_measure)*waitFactor                          % Wait until next measurement position is reached
                t_wait = toc(t_pause);
            end
        end

        xAct = xLim(2);
    else                                                                             % Negative x-direction
        direction = direction* -1;
        
        pi2xMoveAbs(pi, xAct, y(i));
        pause(bScanPause); yAct = y(i);
        pi2xMoveAbs(pi, xLim(1), yAct);

        t_start = tic;
        
        for j = 1:Nx
            counter = counter + 1;

%           [S(counter+Nx-2*j+1, :), E(counter+Nx-2*j+1, :), t_acq, t_measure] = gageAcqDual(DAQ);
            [S(counter+Nx-2*j+1, :), t_acq, t_measure] = gageAcq(DAQ);
            
            positionXY(counter+Nx-2*j+1, 1) = diff(xLim) - vAct*(toc(t_start) - t_acq);
%           positionXY(counter+Nx-2*j+1, 1) = toc(t_start);
            
            if (toc(t_start) - t_acq) > diff(xLim)/vAct
                continue;
            end

            t_pause = tic;
            t_wait  = toc(t_pause);
            
            while t_wait < (dx/vAct - t_measure)*waitFactor
                t_wait = toc(t_pause);
            end
        end
        
        xAct = xLim(1);
    end
    
    positionXY(1+(i-1)*Nx:i*Nx, 2) = y(i);                                           % y-position [mm]
end

% E = E/max(max(E));
% S = S(:, 513:end);

if nargout == 1
    S_ = S;
end

% if nargout == 2
%     S_ = S;
%     E_ = E;
% end

% freeGage(DAQ);
fprintf('\nSaving... \n\n');

ShiftCorrFlag = 1;

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

dbstop if error;

saveDat = [savePath cdate '_' saveName];

fprintf('Total measuring time: %.3g minutes \n\n', toc(t_start_all)/60);

save(saveDat, 'S', 'xLim', 'yLim', 'dx', 'dy', 'positionXY', 'vAct',...
    'trigDelay', 'Fs', 'InputRange', 'ShiftCorrFlag', '-v7.3');  %'-v7.3'

dbclear if error;
 
fprintf('Total time: %.3g minutes \n\n', toc(t_start_all)/60);
end