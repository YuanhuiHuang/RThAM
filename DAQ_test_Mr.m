% acquire mean spectrum of background
% %
% DAQ = gageInit();
PlotFlag   = 0;
FilterFlag = 0;

%**************************************************************************
% saveName = 'Circuit25_50umCopper_Scan01_8kV_18-21uS_50AVG';
% saveName = 'OLine25_Macrophage-1W-leftover-in-DI_50mL-Beacher_SMA_torqued_off-focus_Stage_Off_50OhmTermated_Sonaxis_56h_dBm';
saveName = 'DAQ_test';
finalTime = datenum(clock + [0, 0, 3, -4, 0, 0]);
% zsteps = num2str(z0*1000);
% saveName = [saveName '_' zsteps 'um'];
vAct = 25;%mm/s                               % Set velocity of the stages
nAvg = 100;% number of averages


% All dimensions are in mm
% x0 = 29;
% x0 = 33.75;    % OLine 25 V3330 34.5
% y0 = 22.05;
x0 = 25;    % OLine 25 V3330 34.5
y0 = 25;
z0 = 30;
% z0 = 2.6; % circuit 25 focueed around 6.5mm; circuit 50 around 4.3mm 13.1 V390-13.65 v3330-2.6
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
t_0 = 0e-6;    % us
t_end = 1e-3;  % ms
trigDelay = t_0 * Fs;
endpoint = t_end * Fs;
t = [t_0+dt:dt:t_end];
% nSegments = (endpoint - trigDelay) / 32;
% Parameters for DAQ:
inputRange = 200;% [mV] 10000, 4000, 2000, 1000, 400, 200 
% trigDelay  = 0;% Focus at 1740 (1GS) / 870 (500MS)
nSamples   = (endpoint - trigDelay); %2048;        % Number of samples
detType    = 'TAM50';%TAM50: 500e6, TAM100: 1e9

saveName = [saveName '_' num2str(t_0*1e7) '-' num2str(t_end*1e7) 'us' '_' 'AVG' num2str(nAvg) '_' num2str(z0*100)];

%**************************************************************************

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
segCount  = 1;                                                             % this is the single acquisition code
nSegments = ceil(nSamples/acqRes);
trigTimeout = 1e-6; % ms, -1 for inf

Setup(DAQ, segCount, trigDelay, inputRange, nSegments, 'Single', detType,trigTimeout);                                                                         % Set acquisition, channel and trigger parameters
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


cdate = datestr(now,'yyyymmddHHMM');
saveDat = [savePath, cdate, '_', 'TASS', '_', saveName];
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



% piSetVel(pi.piX, vAct);
% piSetVel(pi.piY, vAct);
% vAct = piGetVel(pi.piX);                                                   % Get real velocity of the stages

% accAct = piGetAcc(pi.piX);                                                 % Get Acceleration  of the stages
% decAct = piGetDec(pi.piX);                                                 % Get Decceleration of the stages

[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);                               % Get Acq. Info
trigDelay      = acqInfo.TriggerDelay;                                     % Save trigger delay for reconstruction

rawData    = 0;
nPts       = acqInfo.SegmentSize;                                          % Number of Samples
Fs         = acqInfo.SampleRate;
positionXY = zeros(Nx*Ny,4);

fprintf('\nNumber of Measurements: %i \n\n', Nx*Ny);

% S = zeros(Nx*Ny,nPts,'int16');                                           % Initialize Signal Matrix
S = zeros(2,nPts);                                                     % Initialize Signal Matrix
% SS = zeros(3200,nPts);
f = zeros(1,262145);  
fd_abs = zeros(2,262145);  

counter = uint64(0);
Ny=10;                                                            % Start internal clock

   tt = [(trigDelay+1):(trigDelay+nSamples)] ./ Fs;
   

% finalTime = datenum(clock + [0, 0, 0, 2, 0, 0]);


h_figure1 = figure; 
figure(h_figure1),
fcut=[0e6, 250e6];
        axes1 = axes('Parent',h_figure1);
        xlim(axes1,fcut./1e6);
grid on;

tic;  

% while datenum(clock) < finalTime
for i = 1:Ny
% while counter <=1
    counter = counter + 1;
    S(1,:) = gageAcq(DAQ, rawData, nAvg);                            % Acquire Signals
    SS(counter,:) = S(1,:);
    [f,fd_abs(counter,:)] = mySpectrum(tt,S(1,:),3);  % 2 dB;3 dBm
    if counter==1
        fd_temp = fd_abs(counter,:);
    end
%     if ~rem(counter,3)
%         toc;    counter
        fd_temp = (fd_temp*double(counter-1) + fd_abs(counter,:)) ./ double(counter);
        figure(h_figure1),
        plot(f(f>=fcut(1) & f<=fcut(2))./1e6,fd_temp(f>=fcut(1) & f<=fcut(2)));
        ylim(axes1,[-155 -115]);
        Title = ['Avg' ' ' num2str(nAvg) ' ' 'Counter' ' ' num2str(counter)];
        title(axes1,Title);
        xlabel(axes1,'Frequency / MHz'); ylabel(axes1,'Amplitude / dBm');
        grid on;
        drawnow;

        if ~rem(counter,400)
%               saveDat = [savePath, cdate, '_', saveName, '.mat'];
              saveDat = [savePath, cdate, '_', saveName,'_counter-',num2str(counter), '.mat'];
%               save(saveDat, 'tt', 'f', 'fd_abs', 'counter', 'S', 'SS', 'xLim', 'yLim', 'dx', 'dy', 'dz', 'x0', 'y0', 'z0', 'positionXY', ...
%               'trigDelay','-v7.3');
               
%                 figure,
%                plot(f(f>=1000),fd_abs(1,f>=1000),f(f>=1000),fd_abs(2,f>=1000));xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
%                 legend('Current','Accumulation'); title('Spectrum');
%                 drawnow;
        end
%     end
    fprintf('*');
end
% figure(h_figure1),

toc; fprintf('\n');                                                          % Stop internal clock

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
save(saveDat, 'tt', 'f', 'fd_abs', 'counter', 'S', 'SS', 'xLim', 'yLim', 'dx', 'dy', 'dz', 'x0', 'y0', 'z0', 'positionXY', ...
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

