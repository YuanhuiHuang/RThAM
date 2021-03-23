function [S_, z_] = acquiereMAvgScanGaGe(pi,DAQ,z0)
% z0 = 0.30;
% dbstop if error
PlotFlag   = 1;
FilterFlag = 2; % 1 for temporal; 2 for spatial

%**************************************************************************
% saveName = 'Circuit25_Ground+Tubing3_6kV_V3330_Scan01';
% saveName = 'Circuit25_Yeast+Tubing3_6kV_6kHz_US_V3330_with_Box_without_tShielding_Scan01';
% saveName = 'OLine25_Yeast_tube3_surface_5kV_US_100MHFM18';
% saveName = 'NOilLine50_deeperCopper_enameled_focus_searching_10kV_V3330';
% saveName = 'WNOil2Line50_8dayFish_10kV_V3330';
saveName = '20170908_extTrig_test';
% saveName = 'OLine17_wire_US_V3330_RScan01';
% zsteps = num2str(z0*1000);
% saveName = [saveName '_' zsteps 'um'];
vAct = 25;%mm/s                               % Set velocity of the stages
nAvg = 1;% number of soft averages
hard_average = 1024; % number of hard averages; Changing hard avg requires freeGage
inputRange = 200;% [mV] 10000, 4000, 2000, 1000, 400, 200, 100
segCount = nAvg;
% All dimensions are in mm
% x0 = 24;  % OLine 17
% y0 = 25;
% z0 = 0.6;   % OL17 V3330 Z0.6mm
% piMoveAbs(pi.piZ,z0);
% x0 = 26;    % Oline 25 100MHz/1.5/1.5mm
% y0 = 15.35;   % Oline 25 100MHz/1.5/1.5mm
% x0 = 33.45; y0 = 17.45;   % OLine 25 V3330 34.75  
% x0 = 28; y0 = 30.10;   % OilLine50 V3330
% x0 = 25; y0 = 25;   % TwinWOilLine50 V3330
% x0 = 29.10; y0 = 29.60;   % OilLine50 V3330
x0 = 27.6; y0 = 29.15;   % OilLine50 V3330
% x0 = 24; y0 = 18.5;  % Oline25 V313
% x0 = 27.6; y0 = 7;    % OLine 25 HFM26
% x0 = 30; y0 = 26.5;    % NOilLine 50 HFM26
% z0 = 0.3;
% x0 = 33.75;    % OLine 25 V3330 34.5
% y0 = 22.05;
% x0 = 23.4;    % OLine 17 V3330 34.5
% y0 = 26.72;
% z0 = 0.4; % circuit 25 focueed around 6.5mm; circuit 50 around 4.3mm 13.1 V390-13.65; v3330-2.6on edge; 1.3onbend
% v3330 25 Ohm 0.85mm; 
% tubing1 0.75OD 0.5ID upper surface at 1.05; middle 0.97mm
% tubing2 0.56OD 0.28ID upper surface at 1.2; middle 1
% piMoveAbs(pi.piX,x0);
% piMoveAbs(pi.piY,y0);
piMoveAbs(pi.piZ,z0);
% Lx = 10;
% Ly = 5;
% Lx = 4;
% Ly = 1.2;
Lx = 1.5;
Ly = 1.5;
Lz = 0;

ds = 0.010;
dx = 2*ds;
dy = ds;
dz = ds;

Fs = 500e6;
dt = 1/Fs;
t_0 = 0e-6; t_end = 4e-6;    % us HFM18=3.4us/1.7us [1.5 3.74] 
% t_0 = 2e-6; t_end = 6e-6;    % us HFM18=3.4us/1.7us % HFM26=3/3mm Z0=1.9 5.18us/2.59us
% t_0 = 4.8e-6; t_end = 6e-6;    % us HFM18=3.4us/1.7us % HFM26=3/3mm Z0=1.9 5.18us/2.59us
% t_0 = 3.2e-6; t_end = 3.7e-6;    % us HFM18=3.4us/1.7us
% t_0 = 8.1e-6;  t_end = 9.1e-6;    % us V3330 6/6.35mm F@8.65   [8.1 9.1] - [16.2 18.2]
% % t_0 = 8.1e-6;  t_end = 18.2e-6;    % us V3330 6/6.35mm F@8.65   [8.1 9.1] - [16.2 18.2]
% t_0 = 24e-6;  t_end = 32e-6;    % us V3330 6/6.35mm F@8.65   [8.1 9.1] - [16.2 18.2]
% t_0 = 16.2e-6;  t_end = 18.2e-6;
% t_0 = 19.6e-6;  t_end = 23.6e-6; % silicon oil
% t_0 = 19e-6;  t_end = 22e-6; % silicon oil 2cSt
% t_0 = 9e-6;  t_end = 24e-6; % silicon oil 2cSt
% t_0 = 9.8e-6;  t_end = 23.6e-6; % silicon oil
% t_0 = 15e-6;  t_end = 17e-6; % silicon oil
% t_0 = 9.8e-6;  t_end = 11.8e-6; % silicon oil
% t_0 = 3e-6;  t_end = 10e-6; % silicon oil
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
detType    = 'TAM50';%TAM50: 500e6, TAM100: 1e9
if Lx==0
    saveName = [saveName '_' 'BScany'];
elseif Ly==0
    saveName = [saveName '_' 'BScanx'];
else
    saveName = [saveName '_' 'TAM'];
end
if strcmp(getenv('USERNAME'), 'yuanhui.huang')
    savePath = 'D:\Users\yuanhui.huang\Documents\MATLAB\TAM\Data\';
end
saveName = ['TAM' '_' saveName '_' num2str(t_0*1e7) '-' num2str(t_end*1e7) 'us' '_' 'AVG' num2str(nAvg*hard_average) '_' num2str(z0*100)];
cdate = datestr(now,'yyyymmddHHMM');
saveName = isFileExisting(saveName,savePath);
saveDat = [savePath, cdate, '_', saveName, '.mat'];
%**************************************************************************

swapXY = Ly;                     % 1: y-axis fast axis. 0: x-axis fast axis

[xAct, yAct] = pi2xGetPosition(pi);                                                  % Get position of the stages

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

Setup(DAQ, segCount, trigDelay, inputRange, nSegments, acqMode, detType, TriggerTimeout, hard_average);                                                                         % Set acquisition, channel and trigger parameters
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
   h_figure1 = figure; 
%    figure(h_figure1),
tic; Elapse=0;                                                             % Start internal clock
for i = 1:Ny
    j = 1;
    counter = counter + 1;
    
    pi2xMoveAbs(pi, X(j,i), Y(i));                                         % Move Stage to beginning of next y-Line                                                             % Time to start pause
    [xAct, yAct] = genPausePi([X(j,i), Y(i)], [xAct, yAct], vAct);         % Pause the routine while moving to next position
                                                            
    CsMl_ErrorHandler(CsMl_Capture(DAQ), 1, DAQ);                           % Start acquisition and await trigger event
    while CsMl_QueryStatus(DAQ) ~= 0   end                                  % Wait until measurement is done (status = 0)
    

    
    S(counter,:) = gageAcqAvg(DAQ, rawData, nAvg, hard_average);                            % Acquire Signals
    
            figure(h_figure1), plot(tt_,S(counter,:));drawnow
%   [xAct, yAct] = pi2xGetPosition(pi);                                    % Get current position of the stage
    positionXY(counter,:) = [X(j,i), Y(i), xAct, yAct];
    
    for j = 2:Nx
        counter = counter + 1;
        
        pi2xMoveAbs(pi,X(j,i), 100);                                       % Move the stage to next x-position, don't move along y
        genPausePi([X(j,i), Y(i)], [xAct, yAct], vAct);                    % Pause the stage while moving to next position

        CsMl_ErrorHandler(CsMl_Capture(DAQ), 1, DAQ);                           % Start acquisition and await trigger event
        while CsMl_QueryStatus(DAQ) ~= 0   end                                  % Wait until measurement is done (status = 0)
        
        S(counter,:) = gageAcqAvg(DAQ, rawData, nAvg, hard_average);                         % Acquire Signals
%             figure(h_figure1), plot(tt_,S(counter,:));drawnow
%       [xAct, yAct] = pi2xGetPosition(pi);                                % Get current position of the stage
        xAct = xAct+ dx;
        positionXY(counter,:) = [X(j,i), Y(i), xAct, yAct];
        
        fprintf('*');
        if j==round(Nx)
            Elapse = Elapse + toc; 
            fprintf('%i \t %g sec\t Target position: %g \t %g \n', counter, Elapse, X(j,i), Y(i));
            tic;
        end
    end
    
%     if rem(i,10) == 0
%         fprintf('%i \t Target position: %g \t %g \n', counter, X(j,i), Y(i));
%     end
    
    fprintf('*');                                                  % Stop internal clock
        if i==round(Ny)
            Elapse = Elapse + toc;
            fprintf('%i \t %g sec\t Target position: %g \t %g \n', counter, Elapse, X(j,i), Y(i)); 
            tic;
        end
end

Elapse=Elapse/60; fprintf(strcat('Total elapsed time is ', num2str(Elapse),' mins\n'));

piSetVel(pi.piX, 1);
piSetVel(pi.piY, 1);
pi2xMoveAbs(pi, X(1,1), Y(1));

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
%    figure;
    
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
       figure(h_figure1),imagesc(tt_, [-Ly/2:dy:Ly/2], abs(S2)); colormap jet; colorbar; xlabel('\mus'); ylabel('mm'); grid on;
   else
       figure(h_figure1),imagesc(tt_, [-Ly/2:ds:Ly/2], abs(S2)); colormap jet; colorbar; xlabel('\mus'); ylabel('mm'); grid on;
   end
end
% system('"C:\Program Files\SyncToy 2.1\SyncToyCmd.exe" "-R" "TAM_Data"')
vAct=25;
piSetVel(pi.piX, vAct);
piSetVel(pi.piY, vAct);
% end
% SendEmail_notification('yhhuang1987@gmail.com', 'TAM email', 'TAM email test');

