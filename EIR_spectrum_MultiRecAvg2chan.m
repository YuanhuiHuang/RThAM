% acquire mean spectrum of background
% %
% DAQ = gageInit();
PlotFlag   = 1;
FilterFlag = 0;

%**************************************************************************
% saveName = 'Circuit25_50umCopper_Scan01_8kV_18-21uS_50AVG';
% saveName = 'OLine25_oldDI_tank_SMA_torqued_noFG_off-focus_Stage_Off_NOT-Termated_Sonaxis_16h_dBm';
% saveName = 'OLine25_15MHz_V313_DI_vs_Sniffer_3day';
saveName = 'Test';
finalTime = datenum(clock + [0, 0, 1, -10, 0, 0]);
% zsteps = num2str(z0*1000);
% saveName = [saveName '_' zsteps 'um'];
vAct = 25;%mm/s                               % Set velocity of the stages
nAvg = 100;% number of averages
hard_average = 1024;   % FPGA accept only >1
segCount = nAvg;
% All dimensions are in mm
% x0 = 29;
% x0 = 33.75;    % OLine 25 V3330 34.5   
% y0 = 22.05;
% x0 = 23.4;    % OLine 17 V3330 34.5
% y0 = 26.72;
% x0 = 34.50;    % OLine 25 V3330 34.75
% y0 = 18.14;
x0 = 24; y0 = 18.5; 
z0 = 10;
% % z0 = 2.6; % circuit 25 focueed around 6.5mm; circuit 50 around 4.3mm 13.1 V390-13.65 v3330-2.6
% piMoveAbs(pi.piZ,z0);
% piMoveAbs(pi.piX,x0);
% piMoveAbs(pi.piY,y0);
% piClose(pi);

Lx = 0;
Ly = 0;
Lz = 0;

ds = 0.05;
dx = ds;
dy = ds;
dz = ds;

Fs = 500e6;
dt = 1/Fs;
t_0 = 0e-6;    % s
t_end = 0.125e-3;  % s % FPGA average take 65 KSamples per channel / 2 channel
trigDelay = t_0 * Fs;
endpoint = t_end * Fs;
t = [t_0+dt:dt:t_end];
% nSegments = (endpoint - trigDelay) / 32;
% Parameters for DAQ:
inputRange = 200;% [mV] 10000, 4000, 2000, 1000, 400, 200 
% trigDelay  = 0;% Focus at 1740 (1GS) / 870 (500MS)
nSamples   = (endpoint - trigDelay); %2048;        % Number of samples
detType    = 'TAM50';%TAM50: 500e6, TAM100: 1e9

if strcmp(getenv('USERNAME'), 'yuanhui.huang')
    savePath = 'D:\Users\yuanhui.huang\Documents\MATLAB\TAM\Data\';
end
saveName = ['TASS' '_' saveName '_' num2str(t_0*1e7) '-' num2str(t_end*1e7) 'us' '_' 'AVG' num2str(nAvg*hard_average) '_' num2str(z0*100)];
cdate = datestr(now,'yyyymmddHHMM');
saveName = isFileExisting(saveName,savePath);
% **************************************************************************
% 
swapXY = Ly;                     % 1: y-axis fast axis. 0: x-axis fast axis

% [xAct, yAct] = pi2xGetPosition(pi);                                                  % Get position of the stages

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
acqMode   = 'Dual';
% To inform the DAQ that we are acquiring in multirec mode:
% segCount = nAvg; 
% segCount  = 1;                                                             % this is the single acquisition code
nSegments = ceil(nSamples/acqRes);
TriggerTimeout  = 0;                                              % Wait until trigger arrives [us] (-1: inf)

Setup(DAQ, segCount, trigDelay, inputRange, nSegments, acqMode, detType, TriggerTimeout, hard_average);                                                                         % Set acquisition, channel and trigger parameters
ret = CsMl_Commit(DAQ);
while ret<0
    Setup(DAQ, segCount, trigDelay, inputRange, nSegments, acqMode, detType, TriggerTimeout, hard_average);                                                                         % Set acquisition, channel and trigger parameters
    ret = CsMl_Commit(DAQ);   % Pass parameters to DAQ system
end
CsMl_ErrorHandler(ret, 1, DAQ);
% hard_average = CsMl_GetMulrecAverageCount(DAQ);


% piSetVel(pi.piX, vAct);
% piSetVel(pi.piY, vAct);
% vAct = piGetVel(pi.piX);                                                   % Get real velocity of the stages

% accAct = piGetAcc(pi.piX);                                                 % Get Acceleration  of the stages
% decAct = piGetDec(pi.piX);                                                 % Get Decceleration of the stages

[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);                               % Get Acq. Info
trigDelay      = acqInfo.TriggerDelay;                                     % Save trigger delay for reconstruction

rawData    = 0; % 1) raw data, 0/nthg) voltages
nPts       = acqInfo.SegmentSize;                                          % Number of Samples
Fs         = acqInfo.SampleRate;
positionXY = zeros(Nx*Ny,4);

Ny=1500;    
% S = zeros(Nx*Ny,nPts,'int16');                                           % Initialize Signal Matrix
S = zeros(segCount,nPts,2);                                                    % Initialize Signal Matrix
SS = zeros(Ny,nPts,2);        % 3000 waveforms for 2 channels take 22.4 GB memory
NFFT = 2^nextpow2(nPts)/2+1;
f = zeros(1,NFFT);  
fd_abs = zeros(NFFT,2);  
fd_totAvg = zeros(NFFT,2);  

counter = 0;
                                                        % Start internal clock
fprintf('\nNumber of Measurements: %i \n\n', Nx*Ny);
   tt = [(trigDelay+1):(trigDelay+nSamples)] ./ Fs;
   

% finalTime = datenum(clock + [0, 0, 0, 2, 0, 0]);
            
fcut=[0e6, 250e6];
h_figure(1) = figure('Position',[388 619 560 420]); 
h_axes(1) = axes('Parent',h_figure(1));
xlim(h_axes(1),fcut./1e6);
grid on;
h_figure(2) = figure('Position',[963 619 560 420]); 
h_axes(2) = axes('Parent',h_figure(2));
xlim(h_axes(2),fcut./1e6);
grid on;

hard_average = CsMl_GetMulrecAverageCount(DAQ);
CsMl_ResetTimeStamp(DAQ);

tic;  
% while datenum(clock) < finalTime
for i = 1:Ny
% while counter <=2
    counter = counter + 1;
%     S(1,:) = gageAcq(DAQ, rawData, nAvg);                            % Acquire Signals
%         Reset Time Stamp:
%         CsMl_ResetTimeStamp(DAQ);
        % Start acquiring:
%         tic;
        ret = CsMl_Capture(DAQ);
        CsMl_ErrorHandler(ret, 1, DAQ);
        % Wait for measurement to finish:
        status = CsMl_QueryStatus(DAQ);
        while status ~= 0        status = CsMl_QueryStatus(DAQ);    end
%         t_Capture(i)=toc;
        % Fetch the data:
        [SS(counter,:,1),tStamp,SS(counter,:,2)] = fetchMultiAvg(DAQ, segCount, acqMode, trigDelay,rawData,0,nAvg,hard_average);
%         t_Fetch(i)=toc;
        for Chan=1:2
%             fcut=[1e6, 110e6];
%             SS(counter,:,Chan) = mean(S(:,:,Chan),1);                       % This is only for fast check while acquiring
            [f,fd_abs(:,Chan)] = mySpectrum(tt,SS(counter,:,Chan),3);  % 2 dB;3 dBm
            if counter==1
                fd_totAvg(:,Chan) = fd_abs(:,Chan);
            end
    %     if ~rem(counter,3)
    %         toc;    counter
            fd_totAvg(:,Chan) = (fd_totAvg(:,Chan)*(counter-1) + fd_abs(:,Chan)) ./ counter;
            figure(h_figure(Chan)),
            plot(f(f>=fcut(1) & f<=fcut(2))./1e6,fd_totAvg((f>=fcut(1) & f<=fcut(2)),Chan));
%             ylim(h_axes(Chan),[-110 -80]);
%             xlabel(h_axes(Chan),'Frequency / MHz'); ylabel(h_axes(Chan),'Amplitude / dBm');
            Title = ['Channel ' num2str(Chan) ':' 'Avg' ' ' num2str(nAvg*hard_average) ' ' 'Counter' ' ' num2str(counter)];
            title(h_axes(Chan),Title);
            drawnow;
            fcut=[0e6, 250e6];
        end
%         t_Plot(i)=toc;
        if ~rem(counter,200)
%               saveDat = [savePath, cdate, '_', saveName, '.mat'];
%               saveDat = [savePath, cdate, '_', saveName,'_counter-',num2str(counter), '.mat'];
%               save(saveDat, 'tt', 'f', 'fd_totAvg', 'counter', 'S', 'SS', 'xLim', 'yLim', 'dx', 'dy', 'dz', 'x0', 'y0', 'z0', 'positionXY', ...
%               'trigDelay','-v7.3');
            fprintf('\n');  toc;
               
%                 figure,
%                plot(f(f>=1000),fd_abs(1,f>=1000),f(f>=1000),fd_abs(2,f>=1000));xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
%                 legend('Current','Accumulation'); title('Spectrum');
%                 drawnow;
        end
%     end
    fprintf('*');
end
% figure(h_figure1),

fprintf('\n');  toc;                                                         % Stop internal clock

% piSetVel(pi.piX, 1);
% piSetVel(pi.piY, 1);
% pi2xMoveAbs(pi, X(1,1), Y(1));

% if nargout == 1                                                            % Print only on screen when S gets loaded
%     S_ = S;
% end

% if nargout > 0
%     S_ = S;
%     
%     if nargout > 1
%         tt = (trigDelay+1):(trigDelay+nSamples);
%         z_ = (tt/Fs - 1.744e-6)*1510e6;
%     end
% end

% freeGage(DAQ);                                                           % Free the system up

saveDat = [savePath, cdate, '_', saveName, '.mat'];
save(saveDat, 'tt', 'f', 'fd_totAvg', 'counter', 'S', 'SS', 'xLim', 'yLim', 'dx', 'dy', 'dz', 'x0', 'y0', 'z0', 'positionXY', ...
              'trigDelay','-v7.3');

if PlotFlag
   figure;
    
   tt = (trigDelay+1):(trigDelay+nSamples);
%    z_ = (tt/Fs - 19.44e-6/2)*1510e6;
   z_ = (tt/Fs)*1510e6;
   tt_ = tt/Fs*1e6;
   Ly = max(Ly, Lx);
   
   if FilterFlag
       S2 = filtS(S, dy*1e-3, 1, 1);
   else
       S2 = S;
   end
   
   if Ny == 1
       imagesc(tt_, [-Ly/2:ds:Ly/2], S2); colormap jet; colorbar; xlabel('\muS'); ylabel('mm'); grid on;
       
%        fd_abs = 10.*log10(2.*(fd_abs./2).^2); %dB
       figure,plot(f(f>=1000),fd_abs(1,f>=1000),f(f>=1000),fd_abs(2,f>=1000));xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
       legend('Current','Accumulation'); title('Spectrum');
       
       figure,plot(tt_,S(1,:),tt_,S(2,:));xlabel('Time / \muS'); ylabel('Amplitude / Volt');
       legend('Current','Accumulation'); title('Raw sequence');
   else
       imagesc(tt_, [-Ly/2:ds:Ly/2], S2); colormap jet; colorbar; xlabel('\muS'); ylabel('mm'); grid on;
%        fd_abs = 20.*log10(2.*(fd_abs./2).^2); %dB
       figure,plot(f(f>=1000),fd_abs(1,f>=1000),f(f>=1000),fd_abs(2,f>=1000));xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
       legend('Current','Accumulation');title('Spectrum');
       
       figure,plot(tt_,S(1,:),tt_,S(2,:));xlabel('Time / \muS'); ylabel('Amplitude / Volt');
       legend('Current','Accumulation'); title('Raw sequence');
   end
end

% end

