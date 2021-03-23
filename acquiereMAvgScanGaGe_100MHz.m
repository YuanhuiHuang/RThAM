% function [S_, z_] = acquiereMAvgScanGaGe_100MHz(pi,DAQ,z0)
% z0 = 0.30;
% dbstop if error
PlotFlag   = 1;
FilterFlag = 2; % 1 for temporal; 2 for spatial

%**************************************************************************
% saveName = 'Circuit25_Ground+Tubing3_6kV_V3330_Scan01';
% saveName = 'Circuit25_Yeast+Tubing3_6kV_6kHz_US_V3330_with_Box_without_tShielding_Scan01';
% saveName = 'OLine25_Yeast_tube3_surface_5kV_US_100MHFM18';
saveName = 'ChirpingTAM';
% saveName = 'OLine17_wire_US_V3330_RScan01';
% zsteps = num2str(z0*1000);
% saveName = [saveName '_' zsteps 'um'];
vAct = 25;%mm/s                               % Set velocity of the stages
nAvg = 1;% number of soft averages
hard_average = 1; % number of hard averages; Changing hard avg requires freeGage
inputRange = 400;% [mV] 10000, 4000, 2000, 1000, 400, 200, 100
segCount = nAvg;
% All dimensions are in mm
% x0 = 24;  % OLine 17
% y0 = 25;
% z0 = 0.6;   % OL17 V3330 Z0.6mm
% piMoveAbs(pi.piZ,z0);
x0 = 23;    % CPS 100MHz/3/3mm
y0 = 38;   % CPS 100MHz/3/3mm
z0 = 40;
% x0 = 33.45; y0 = 17.45;   % OLine 25 V3330 34.75  
% x0 = 28.65; y0 = 28.80;   % OilLine50 V3330
% x0 = 26.15; y0 = 28.5;   % OilLine50 V3330
% x0 = 24; y0 = 18.5;  % Oline25 V313
% x0 = 27.6; y0 = 7;    % OLine 25 HFM26
% z0 = 0.3;
% x0 = 33.75;    % OLine 25 V3330 34.5
% y0 = 22.05;
% x0 = 23.4;    % OLine 17 V3330 34.5
% y0 = 26.72;
% z0 = 0.4; % circuit 25 focueed around 6.5mm; circuit 50 around 4.3mm 13.1 V390-13.65; v3330-2.6on edge; 1.3onbend
% v3330 25 Ohm 0.85mm; 
% tubing1 0.75OD 0.5ID upper surface at 1.05; middle 0.97mm
% tubing2 0.56OD 0.28ID upper surface at 1.2; middle 1
ans = load('train.mat','y'); sound(ans.y);
piMoveAbs(pi.piX,x0);
pause(1);
piMoveAbs(pi.piY,y0);
pause(2);
piMoveAbs(pi.piZ,z0);
pause(1);
% Lx = 10;
% Ly = 5;
% Lx = 1.5;
% Ly = 1.2;
Lx = 0;
Ly = 4;
Lz = 0;

ds = 0.1;
dx = 2.*ds;
dy = ds;
dz = ds;

Fs = 50e6;
dt = 1/Fs;
% t_0 = 1.5e-6; t_end = 4e-6;    % us HFM18=3.4us/1.7us [1.5 3.74] 
t_0 = 0e-6; t_end = 25e-3;    % us HFM18=3.4us/1.7us % HFM26=3/3mm Z0=1.9 5.18us/2.59us
% t_0 = 4.3e-6; t_end = 6e-6;    % us HFM18=3.4us/1.7us % HFM26=3/3mm Z0=1.9 5.18us/2.59us
% t_0 = 2.15e-6; t_end = 3e-6;    % us HFM18=3.4us/1.7us % HFM26=3/3mm Z0=1.9 5.18us/2.59us
% t_0 = 3.2e-6; t_end = 3.7e-6;    % us HFM18=3.4us/1.7us
% t_0 = 8.1e-6;  t_end = 9.1e-6;    % us V3330 6/6.35mm F@8.65   [8.1 9.1] - [16.2 18.2]
% t_0 = 8.1e-6;  t_end = 18.2e-6;    % us V3330 6/6.35mm F@8.65   [8.1 9.1] - [16.2 18.2]
% t_0 = 24e-6;  t_end = 32e-6;    % us V3330 6/6.35mm F@8.65   [8.1 9.1] - [16.2 18.2]
% t_0 = 16.2e-6;  t_end = 18.2e-6;
% % t_0 = 8.25e-6; t_end = 8.9e-6;    % us
% t_0 = 0.3e-6;  t_end = 50.3e-6;    % us
% t_0 = 1.5e-6;  t_end = 6.5e-6;    % us Sonaxis
trigDelay = t_0 * Fs;
endpoint = t_end * Fs; % FPGA average take 65 KSamples per channel / 2 channel
t = [t_0+dt:dt:t_end];
% nSegments = (endpoint - trigDelay) / 32;
% Parameters for DAQ:
% trigDelay  = 0;% Focus at 1740 (1GS) / 870 (500MS)
nSamples   = (endpoint - trigDelay); %2048;        % Number of samples
detType    = 'TAM20';%TAM50: 500e6, TAM100: 1e9
if Lx==0
    saveName = [saveName '_' 'YPofile'];
elseif Ly==0
    saveName = [saveName '_' 'XProfile'];
else
    saveName = [saveName '_' 'RS'];
end
if strcmp(getenv('USERNAME'), 'yuanhui')
%     savePath = 'D:\Documents\MATLAB\TAM\Data\';
    savePath = 'C:\Users\yuanhui\MATLAB\TAM\Data\';
end
saveName = ['TAM100' '_' saveName '_' num2str(t_0*1e7) '-' num2str(t_end*1e7) 'us' '_' 'AVG' num2str(nAvg*hard_average) '_' num2str(z0*100)];
cdate = datestr(now,'yyyymmddHHMM');
saveName = isFileExisting(saveName,savePath);
saveDat = [savePath, cdate, '_', saveName, '.mat'];
%**************************************************************************

swapXY = 0;                     % 1: y-axis fast axis. 0: x-axis fast axis

[xAct, yAct] = pi2xGetPosition(PI);                                                  % Get position of the stages

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

[X,Y] = generateSequence(xLim, yLim, dx, dy);
Nx    = size(X,1);                                                         % Number of TD x positions
Ny    = size(X,2);                                                         % Number of TD y positions

% Parameters for DAQ (please do not change):
acqRes    = 32;
acqMode   = 'Single';                                                      % this is the single acquisition code
nSegments = ceil(nSamples/acqRes);
TriggerTimeout  = -1;   %  % Wait until trigger arrives [us] (-1: inf)

gageSetup_BAK20190323(DAQ, segCount, trigDelay, inputRange, nSegments, acqMode, detType, TriggerTimeout, hard_average);                                                                         % Set acquisition, channel and trigger parameters
pause(1);ret = CsMl_Commit(DAQ);pause(1);
while ret<0
    Setup(DAQ, segCount, trigDelay, inputRange, nSegments, acqMode, detType, TriggerTimeout, hard_average);                                                                         % Set acquisition, channel and trigger parameters
    ret = CsMl_Commit(DAQ);   % Pass parameters to DAQ system
end
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
Fs         = acqInfo.SampleRate;
positionXY = zeros(Nx*Ny,4);

fprintf('\nNumber of Measurements: %i \n\n', Nx*Ny);

% S = zeros(Nx*Ny,nPts,'int16');                                           % Initialize Signal Matrix
S = zeros(Nx*Ny,nPts);                                                     % Initialize Signal Matrix

counter =0;
   tt = (trigDelay+1):(trigDelay+nPts);
%    z_ = (tt/Fs - 19.44e-6/2)*1510e6;
   z_ = (tt/Fs)*1510e6;
   tt_ = tt/Fs*1e6;
   h_figure1 = figure; h_ax = axes; 
%    figure(h_figure1),
tic; Elapse = 0;                                                              % Start internal clock
%
for i = 1:Ny
    j = 1;
    counter = counter + 1;
    
    pi2xMoveAbs(PI, X(j,i), Y(i));                                         % Move Stage to beginning of next y-Line                                                             % Time to start pause
    [xAct, yAct] = genPausePi([X(j,i), Y(i)], [xAct, yAct], vAct);         % Pause the routine while moving to next position
                                                            
    CsMl_ErrorHandler(CsMl_Capture(DAQ), 1, DAQ);                           % Start acquisition and await trigger event
    while CsMl_QueryStatus(DAQ) ~= 0   end                                  % Wait until measurement is done (status = 0)
    
    if rem(i,20) == 0
        fprintf('%i \t Target position: %g \t %g \n', counter, X(j,i), Y(i));
    end
    
    S(counter,:) = gageAcqAvg(DAQ, rawData, nAvg, hard_average);                            % Acquire Signals
    
%             figure(h_figure1), 
            plot(h_ax, tt_,S(counter,:));xlim(1e6.*[t_0 t_end]);ylim([-inputRange/1000/2 inputRange/1000/2]);drawnow
%   [xAct, yAct] = pi2xGetPosition(pi);                                    % Get current position of the stage
    positionXY(counter,:) = [X(j,i), Y(i), xAct, yAct];
    
    for j = 2:Nx
        counter = counter + 1;
        
        pi2xMoveAbs(PI,X(j,i), 100);                                       % Move the stage to next x-position, don't move along y
        genPausePi([X(j,i), Y(i)], [xAct, yAct], vAct);                    % Pause the stage while moving to next position

        CsMl_ErrorHandler(CsMl_Capture(DAQ), 1, DAQ);                           % Start acquisition and await trigger event
        while CsMl_QueryStatus(DAQ) ~= 0   end                                  % Wait until measurement is done (status = 0)
        
        S(counter,:) = gageAcqAvg(DAQ, rawData, nAvg, hard_average);                         % Acquire Signals
%             figure(h_figure1), 
            plot(h_ax, tt_,S(counter,:));xlim(1e6.*[t_0 t_end]);ylim([-inputRange/1000/2 inputRange/1000/2]);drawnow
%       [xAct, yAct] = pi2xGetPosition(pi);                                % Get current position of the stage
        xAct = xAct+ dx;
        positionXY(counter,:) = [X(j,i), Y(i), xAct, yAct];
        
        if Nx~=1
            fprintf('*');
            if j==Nx
                Elapse = Elapse + toc; 
                fprintf('%i \t %g sec\t Target position: %g \t %g \n', counter, Elapse, X(j,i), Y(i));
                tic;
            end
        end
    end
    if Ny~=1
        fprintf('*');                                                  % Stop internal clock
        if i==Ny
            Elapse = Elapse + toc; 
            fprintf('%i \t %g sec\t Target position: %g \t %g \n', counter, Elapse, X(j,i), Y(i)); 
            tic;
        end
    end
end
Elapse=Elapse/60; fprintf(strcat('Total elapsed time is  ', num2str(Elapse),' mins\n'));

%
piSetVel(pi.piX, 1);
piSetVel(pi.piY, 1);
pi2xMoveAbs(PI, X(1,1), Y(1));

% if nargout == 1                                                            % Print only on screen when S gets loaded
%     S_ = S;
% end
% 
% if nargout > 0
%     S_ = S;
%     
%     if nargout > 1
%         tt = (trigDelay+1):(trigDelay+nSamples);
%         z_ = (tt/Fs - 1.744e-6)*1510e6;
%     end
% end

% freeGage(DAQ);                                                           % Free the system up

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


save(saveDat, 'S', 'xLim', 'yLim', 'dx', 'dy', 'dz', 'x0', 'y0', 'z0', 'positionXY', ...
              'trigDelay','-v7.3');

if PlotFlag
    figure(h_figure1),
    
   tt = (trigDelay+1):(trigDelay+nSamples);
%    z_ = (tt/Fs - 19.44e-6/2)*1510e6;
   z_ = (tt/Fs)*1510e6;
   tt_ = tt/Fs*1e6;
   Ly = max(Ly, Lx);
   
   if FilterFlag
       S2 = filtS(S, dt, ds, FilterFlag);
   else
       S2 = S;
   end
%    figure,
   if Ny == 1
       imagesc(tt_, [-Ly/2:dy:Ly/2], abs(S2)); colormap jet; colorbar; xlabel('\mus'); ylabel('mm'); grid on;
   else
       imagesc(tt_, [-Ly/2:ds:Ly/2], abs(S2)); colormap jet; colorbar; xlabel('\mus'); ylabel('mm'); grid on;
   end
end
% system('"C:\Program Files\SyncToy 2.1\SyncToyCmd.exe" "-R" "TAM_Data"')
vAct=25;
piSetVel(pi.piX, vAct);
piSetVel(pi.piY, vAct);
% end
ans = load('train.mat','y'); sound(ans.y);
% SendEmail_notification('yhhuang1987@gmail.com', 'TAM email', 'TAM email test');

