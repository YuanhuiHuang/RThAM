function varargout = bscan(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bscan_OpeningFcn, ...
                   'gui_OutputFcn',  @bscan_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end

function bscan_OpeningFcn(hObject, eventdata, handles, varargin)
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to bscan (see VARARGIN)

    % Initialize Stages:
    if isempty(instrfind)
        setPath;
        pi = pi2xStart();
        pi2xOpen(pi);
        handles.pi = pi;
    end
    
    % Initialize DAQ Card
    handles.DAQ = gageInit();

    % Initial DAQ Setup Parameters:
    handles.SamplingRate    = 500e6;
    handles.Input1Range     = 2000;
%   handles.Input2Range     = 4000;
    handles.nSegments       = 2;
    handles.AcquisitionMode = 'Single';
    handles.DataType        = 1;
    
    handles.TriggerOffset   = 700;    
    handles.TriggerChannel  = -1;
    handles.TriggerLevel    = 40;
    handles.TriggerRange    = 10000;
    
    % Initial Measurement Parameters:
    handles.Measurement_Mode = 1;
    handles.NrAverages       = 1;
    
    handles.MoveToX     = 19;
    handles.MoveToY     = 20;
    handles.x0          = handles.MoveToX;
    handles.y0          = handles.MoveToY;
    handles.Lx          = 3;
    handles.Ly          = 3;
    handles.dx          = 0.004;
    handles.dy          = 1.0;
    handles.vAct        = 8; % 4.65
    handles.aAct        = 40;
    handles.tWaitBScan  = 0.1;
    handles.AccCorrFlag = 0;
    handles.SwapXYFlag  = 0;

    cdat = clock;
    if cdat(2) < 10
        handles.date = [num2str(cdat(1)) '0' num2str(cdat(2))];
    else
        handles.date = [num2str(cdat(1)) num2str(cdat(2))];
    end
    if cdat(3) < 10
        handles.date = [handles.date '0' num2str(cdat(3))];
    else
        handles.date = [handles.date num2str(cdat(3))];
    end
    clear cdat;
    
    handles.saveflag = 1;
    handles.savePath = 'D:\Users\dominik.soliman\Documents\MATLAB\';
    handles.saveName = [handles.date '_cScan01_'];
    handles.grid     = 0;
    
    handles.output = hObject;                                                  % Choose default command line output for bscan
    guidata(hObject, handles);                                                 % Update handles structure
    
    % Display Initial Values
    DispIni(hObject, eventdata, handles);
    
    % Set up initial parameters
    SetupMScan(hObject, eventdata, handles);
    
    % uiwait(handles.figure1);                                                 % UIWAIT makes bscan wait for user response (see UIRESUME)
end


%% ################ Setup

function SetupMScan(hObject, eventdata, handles)

    % --- Get System Info
    [ret, sysinfo] = CsMl_GetSystemInfo(handles.DAQ);
    CsMl_ErrorHandler(ret, 1, handles.DAQ);
    
    % --- Set Acquisition Parameters
    acqInfo.SampleRate      = handles.SamplingRate;                                      % Set sampling rate
    acqInfo.ExtClock        = 0;
    acqInfo.Mode            = CsMl_Translate(handles.AcquisitionMode, 'Mode');
    acqInfo.SegmentCount    = 1;                                                         % Number of consecutive signals to be read out
    acqInfo.Depth           = handles.nSegments*512;
    acqInfo.SegmentSize     = handles.nSegments*512;                                     % Number of Samples
    acqInfo.TriggerTimeout  = -1;                                                        % Wait until trigger signal arrives (neg: inf)
    acqInfo.TriggerHoldoff  = 0;                                                         % Dead time before awaiting a trigger signal
    acqInfo.TriggerDelay    = handles.TriggerOffset;                                     % Number of omitted samples at the beginning
    acqInfo.TimeStampConfig = 0;
    
    ret = CsMl_ConfigureAcquisition(handles.DAQ, acqInfo);
    CsMl_ErrorHandler(ret, 1, handles.DAQ);
    
    % --- Set Input Channel Parameters
    for i = 1:sysinfo.ChannelCount
        chan(i).Channel    = i;
        chan(i).Coupling   = CsMl_Translate('DC', 'Coupling');                           % Set the coupling to input TD channel to DC
        chan(i).DiffInput  = 0;
        chan(i).InputRange = handles.Input1Range;                                         % Set total input voltage range
        chan(i).Impedance  = 50;                                                         % Input impedance (according to cable)
        chan(i).DcOffset   = 0;                                                          % Baseline offset
        chan(i).DirectAdc  = 0;
        chan(i).Filter     = 0;
    end
    
%     chan(1).InputRange = handles.Input1Range;
%     chan(2).InputRange = handles.Input2Range;
    
    ret = CsMl_ConfigureChannel(handles.DAQ, chan);
    CsMl_ErrorHandler(ret, 1, handles.DAQ);
    
    % --- Set Trigger Parameters
    trig.Trigger     = 1;
    trig.Slope       = CsMl_Translate('Positive', 'Slope');
    trig.Level       = handles.TriggerLevel;                                             % Trigger threshold
    trig.Source      = handles.TriggerChannel;                                           % Trigger signal on channel -1
    trig.ExtCoupling = CsMl_Translate('DC', 'ExtCoupling');                              % Set the coupling to trigger channel to DC
    trig.ExtRange    = handles.TriggerRange;                                             % Set total trigger signal voltage range
    
    ret = CsMl_ConfigureTrigger(handles.DAQ, trig);
    CsMl_ErrorHandler(ret, 1, handles.DAQ);
    
    % --- Transmit Parameters to DAQ system
    ret = CsMl_Commit(handles.DAQ);                                                      % Pass parameters to DAQ system
    CsMl_ErrorHandler(ret, 1, handles.DAQ);

end


%% ################ Acquisition Code Continuous

function measureMScan(hObject, eventdata, handles)

% Error Warnings:
if handles.x0 < 1 || handles.x0 > 49
    error 'Wrong x-position!'; return;
end
if handles.y0 < 1 || handles.y0 > 49
    error 'Wrong y-range!'; return;
end
if (handles.x0+handles.Lx/2) > 49 || (handles.x0-handles.Lx/2) < 0
    error 'Out of x-range!'; return;
end
if (handles.y0+handles.Ly/2) > 49 || (handles.y0-handles.Ly/2) < 0
    error 'Out of y-range!'; return;
end
if handles.vAct < 1 || handles.vAct > 20
    error 'Wrong stage speed!'; return;
end
if handles.dx < 0.001 || handles.dx > 0.1
    error 'Wrong dx!'; return;
end
if handles.dy < 0.001 || handles.dy > 2.0
    error 'Wrong dy!'; return;
end

pi  = handles.pi;
DAQ = handles.DAQ;

if handles.SwapXYFlag
    tempPi = pi.piX;
    pi.piX = pi.piY;
    pi.piY = tempPi;
    clear tempPi;
end
    
[xAct, yAct] = pi2xGetPosition(pi);

piSetVel(pi.piX, handles.vAct);
piSetVel(pi.piY, handles.vAct);
piSetAcc(pi.piX, handles.aAct);
piSetAcc(pi.piY, handles.aAct);

vAct = piGetVel(pi.piX);
aAct = piGetAcc(pi.piX);                                                             % Get Acceleration  of the stages
dAct = piGetDec(pi.piX); 

Lx   = handles.Lx;
Ly   = handles.Ly;
dx   = handles.dx;
dy   = handles.dy;

xLim = [handles.x0-Lx/2 handles.x0+Lx/2];
yLim = [handles.y0-Ly/2 handles.y0+Ly/2];

if handles.SwapXYFlag
   tempLim = xLim;
   xLim    = yLim;
   yLim    = tempLim;
   clear tempLim;
end

waitFactor = 0.0;

Nx    = round(Lx/dx+1);
Ny    = round(Ly/dy+1);
y     = yLim(1):dy:yLim(2);

AccCorr = handles.AccCorrFlag;

if AccCorr
    t_acc = vAct/aAct;                                                               % Acceleration  time of the stage
    t_dec = vAct/dAct;                                                               % Decceleration time of the stage
else
    t_acc = 0;
    t_dec = 0;
end

x_acc = 0.5*aAct*t_acc^2;                                                            % Acceleration  distance of the stage
x_dec = 0.5*dAct*t_dec^2;                                                            % Decceleration distance of the stage
t_tot = (Lx-x_acc-x_dec)/vAct + t_acc + t_dec;

[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);
[ret, chInfo]  = CsMl_QueryChannel(DAQ, 1);

trigDelay  = acqInfo.TriggerDelay;
nPts       = acqInfo.SegmentSize;
Fs         = acqInfo.SampleRate;
InputRange = chInfo.InputRange;

positionXY = zeros(Nx*Ny, 2);

set(handles.Text_MeasurementsTotal, 'String', Nx*Ny);
set(handles.Text_TimeTotal, 'String', ...
    sprintf('%.2f', Ny*(t_tot + handles.tWaitBScan + 0.1)/60));

if handles.DataType
    S = zeros(Nx*Ny, nPts, 'int16');
else
    S = zeros(Nx*Ny, nPts, 'double');
end
% E = zeros(Nx*Ny, 32, 'double');

counter     = 0;
t_start_all = tic;

pi2xMoveAbs(pi, xLim(1), y(1));

[xAct, yAct] = genPausePi([xLim(1), y(1)], [xAct, yAct], vAct);

direction = +1;

for i = 1:Ny
%     if Ny > 10
%         if rem(i,10) == 0
%             if handles.Stop
%                 return;
%             end
%         end
%     end
    
    set(handles.Text_MeasurementNr, 'String', counter);
    set(handles.Text_BScan, 'String', sprintf('%.3f', y(i)));
    set(handles.Text_TimeLeft, 'String', ...
        sprintf('%.2f', (Ny-i)*(t_tot + handles.tWaitBScan + 0.1)/60));
    
    if direction > 0                                                                 % Positive x-direction
        direction = direction* -1;

        pi2xMoveAbs(pi, xAct, y(i));                                                 % Move to beginning of B-line
        pause(handles.tWaitBScan); yAct = y(i);                                                     % Wait, until transducer arrives

        if i > 1
            PlotBScan(hObject, eventdata, handles);
        end
    
        pi2xMoveAbs(pi, xLim(2), yAct);                                              % Start B-scan
        
        t_start = tic;
        
        for j = 1:Nx
            counter = counter + 1;

%           [S(counter, :), E(counter, :), t_acq, t_measure] = gageAcqDual(DAQ);
            [S(counter, :), t_acq, t_measure] = gageAcq(DAQ, handles.DataType);   % Acquire signals and get acquisition time

            if (toc(t_start) - t_acq) > t_tot                                     % Stop acquisition at end of B-line
                continue;
            end
            
            positionXY(counter, 1) = x_acc + vAct*(toc(t_start) - t_acq - t_acc);
%           positionXY(counter, 1) = vAct*(toc(t_start) - t_acq);                   % x-position right after trigger event [mm]
            
            if (toc(t_start) - t_acq) < t_acc                                        % During acceleration of the stage
                positionXY(counter, 1) = 0.5*aAct*(toc(t_start) - t_acq)^2;
            end
            
            if (toc(t_start) - t_acq) > (t_tot - t_dec)                              % During decceleration of the stage
                positionXY(counter, 1) = diff(xLim) - 0.5*dAct*(t_tot - ...
                                         (toc(t_start) - t_acq))^2;
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
        pause(handles.tWaitBScan); yAct = y(i);

        PlotBScan(hObject, eventdata, handles);

        pi2xMoveAbs(pi, xLim(1), yAct);

        t_start = tic;
        
        for j = 1:Nx
            counter = counter + 1;

%           [S(counter+Nx-2*j+1, :), E(counter+Nx-2*j+1, :), t_acq, t_measure] = gageAcqDual(DAQ);
            [S(counter+Nx-2*j+1, :), t_acq, t_measure] = gageAcq(DAQ, handles.DataType);
            
            if (toc(t_start) - t_acq) > Lx/vAct
                continue;
            end
            
            positionXY(counter+Nx-2*j+1, 1) = Lx - (x_acc + vAct*(toc(t_start) - t_acq - t_acc));
%           positionXY(counter+Nx-2*j+1, 1) = Lx - vAct*(toc(t_start) - t_acq);
            
            if (toc(t_start) - t_acq) < t_acc
                positionXY(counter+Nx-2*j+1, 1) = diff(xLim) - 0.5*aAct*(toc(t_start) - t_acq)^2;
            end
            
            if (toc(t_start) - t_acq) > (t_tot - t_dec)
                positionXY(counter+Nx-2*j+1, 1) = 0.5*dAct*(t_tot - (toc(t_start) - t_acq))^2;
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

    handles.Plot1_Data = S(1+(i-1)*Nx:i*Nx, :);
    handles.Plot2_Data = positionXY(1+(i-1)*Nx:i*Nx, 1);
    guidata(hObject, handles);
    
    if Ny == 1
        PlotBScan(hObject, eventdata, handles);
    end
end

% E = E/max(max(E));
% S = S(:, 513:end);

handles.Signals   = S;
handles.PositionX = positionXY;
guidata(hObject, handles);

if Ny < 20 && Ny > 1
   pause(2);
   handles.Plot1_Data = handles.Signals;
   handles.Plot2_Data = handles.PositionX(:,1);
   guidata(hObject, handles);
   PlotAll(hObject, eventdata, handles);
end

fprintf('Total measuring time: %.3g minutes\n\n', toc(t_start_all)/60);

ShiftCorrFlag = 1;

if handles.saveflag == 0 && Ny > 20
    handles.saveflag = 1;
    handles.saveName = [handles.saveName '_Temp'];
end
    
if handles.saveflag == 1
    fprintf('\nSaving... \n\n');
    saveDat = [handles.savePath handles.saveName];
    save(saveDat, 'S', 'xLim', 'yLim', 'dx', 'dy', 'positionXY', 'vAct',...
        'trigDelay', 'InputRange', 'ShiftCorrFlag', 'AccCorr');  %'-v7.3'
end

fprintf('\n\nTotal time: %.3g minutes\n\n', toc(t_start_all)/60);
end


%% ################ Acquisition Code Discrete

function measureMScanDisc(hObject, eventdata, handles)

% Error Warnings:
if handles.x0 < 1 || handles.x0 > 49
    error 'Wrong x-position!'; return;
end
if handles.y0 < 1 || handles.y0 > 49
    error 'Wrong y-range!'; return;
end
if (handles.x0+handles.Lx/2) > 49 || (handles.x0-handles.Lx/2) < 0
    error 'Out of x-range!'; return;
end
if (handles.y0+handles.Ly/2) > 49 || (handles.y0-handles.Ly/2) < 0
    error 'Out of y-range!'; return;
end
if handles.dx < 0.002 || handles.dx > 0.1
    error 'Wrong dx!'; return;
end
if handles.dy < 0.002 || handles.dy > 2.0
    error 'Wrong dy!'; return;
end

pi  = handles.pi;
DAQ = handles.DAQ;

if handles.SwapXYFlag
    tempPi = pi.piX;
    pi.piX = pi.piY;
    pi.piY = tempPi;
    clear tempPi;
end

[xAct, yAct] = pi2xGetPosition(pi);

handles.vAct = 10;
handles.aAct = 4000;

piSetVel(pi.piX, handles.vAct);
piSetVel(pi.piY, handles.vAct);
piSetAcc(pi.piX, handles.aAct);
piSetAcc(pi.piY, handles.aAct);

vAct = piGetVel(pi.piX);

Lx = handles.Lx;
Ly = handles.Ly;
dx = handles.dx;
dy = handles.dy;

xLim = [handles.x0-Lx/2 handles.x0+Lx/2];
yLim = [handles.y0-Ly/2 handles.y0+Ly/2];

if handles.SwapXYFlag
   tempLim = xLim;
   xLim    = yLim;
   yLim    = tempLim;
   clear tempLim;
end

[X,Y] = generateSequence(xLim, yLim, dx, dy);

Nx    = size(X,1);                                                                   % Number of TD x positions
Ny    = size(X,2);

[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);
[ret, chInfo]  = CsMl_QueryChannel(DAQ, 1);

trigDelay  = acqInfo.TriggerDelay;
nPts       = acqInfo.SegmentSize;
Fs         = acqInfo.SampleRate;
InputRange = chInfo.InputRange;

positionXY = zeros(Nx*Ny, 4);

set(handles.Text_MeasurementsTotal, 'String', Nx*Ny);
set(handles.Text_TimeTotal, 'String', ' ');

if handles.DataType
    S = zeros(Nx*Ny, nPts, 'int16');
else
    S = zeros(Nx*Ny, nPts, 'double');
end

counter = 0;
t_start_all = tic;

for i = 1:Ny
    j = 1;
    counter = counter + 1;
    
    pi2xMoveAbs(pi, X(j,i), Y(i));                                                   % Move Stage to beginning of next y-Line
    [xAct, yAct] = genPausePi([X(j,i), Y(i)], [xAct, yAct], vAct);                   % Pause the routine while moving to next position

    S(counter,:) = gageAcq(DAQ, handles.DataType, handles.NrAverages);                                   % Acquire Signals
    
    [xAct, yAct] = pi2xGetPosition(pi);                                              % Get current position of the stage
    positionXY(counter,:) = [X(j,i), Y(i), xAct, yAct];
    
    for j = 2:Nx
        counter = counter + 1;
        
        pi2xMoveAbs(pi, X(j,i), 100);
        genPausePi([X(j,i), Y(i)], [xAct, yAct], vAct);
                
        S(counter,:) = gageAcq(DAQ, handles.DataType, handles.NrAverages);

        [xAct, yAct] = pi2xGetPosition(pi);
        positionXY(counter,:) = [X(j,i), Y(i), xAct, yAct];
    end
    
    handles.Plot1_Data = S(1+(i-1)*Nx:i*Nx, :);
    handles.Plot2_Data = positionXY(1+(i-1)*Nx:i*Nx, 3);
    guidata(hObject, handles);
    PlotBScan(hObject, eventdata, handles);
end

handles.Signals   = S;
handles.PositionX = positionXY(:,3:4);
guidata(hObject, handles);

if Ny < 20 && Ny > 1
   pause(2);
   handles.Plot1_Data = handles.Signals;
   handles.Plot2_Data = handles.PositionX;
   guidata(hObject, handles);
   PlotAll(hObject, eventdata, handles);
end

fprintf('Total measuring time: %.3g minutes\n\n', toc(t_start_all)/60);

if handles.saveflag == 0 && Ny > 20
    handles.saveflag = 1;
    handles.saveName = [handles.saveName '_Temp'];
end

if handles.saveflag == 1
    fprintf('\nSaving... \n\n');
    saveDat = [handles.savePath handles.saveName];
    save(saveDat, 'S', 'xLim', 'yLim', 'dx', 'dy', 'positionXY',...
        'trigDelay', 'InputRange');  %'-v7.3'
end

fprintf('\n\nTotal time: %.3g minutes\n\n', toc(t_start_all)/60);
end


%% ################ GUI functions

function PlotBScan(hObject, eventdata, handles)
    imagesc(([(handles.TriggerOffset+1) (handles.TriggerOffset+(handles.nSegments*512))]/handles.SamplingRate-1.86e-6)*1510e6, ...
            [handles.x0-handles.Lx/2 handles.x0+handles.Lx/2], handles.Plot1_Data, 'Parent', handles.Plot1);
    colormap(gray);
    set(handles.Plot1, 'units', 'normalized', 'FontSize', 9);
    xlabel(handles.Plot1, 'z_{VD}  (µm)', 'FontWeight', 'bold', 'units', ...
           'normalized', 'FontSize', 10);
    ylabel(handles.Plot1, 'x position (mm)', 'FontWeight', 'bold', 'units', ...
           'normalized', 'FontSize', 10);
       
    if handles.grid
       grid(handles.Plot1);
    end

    plot(handles.Plot2, handles.Plot2_Data);
    set(handles.Plot2, 'XLim', [1 length(handles.Plot2_Data)]);
    set(handles.Plot2, 'YLim', [0 handles.Lx]);
    set(handles.Plot2, 'units', 'normalized', 'FontSize', 9);
    xlabel(handles.Plot2, 'Measurement Nr.', 'FontWeight', 'bold', 'units', ...
           'normalized', 'FontSize', 10);
    ylabel(handles.Plot2, 'x (mm)', 'FontWeight', 'bold', 'units', ...
           'normalized', 'FontSize', 10);
end


function PlotAll(hObject, eventdata, handles)
    imagesc(([(handles.TriggerOffset+1) (handles.TriggerOffset+(handles.nSegments*512))]/handles.SamplingRate-1.86e-6)*1510e6, ...
            [handles.y0-handles.Ly/2 handles.y0+handles.Ly/2], handles.Plot1_Data, 'Parent', handles.Plot1);
    colormap(gray);
    set(handles.Plot1, 'units', 'normalized', 'FontSize', 9);
    xlabel(handles.Plot1, 'z_{VD}  (µm)', 'FontWeight', 'bold', 'units', ...
           'normalized', 'FontSize', 10);
    ylabel(handles.Plot1, 'y position (mm)', 'FontWeight', 'bold', 'units', ...
           'normalized', 'FontSize', 10);
       
    if handles.grid
        grid(handles.Plot1);
    end

    plot(handles.Plot2, handles.Plot2_Data);
    set(handles.Plot2, 'XLim', [1 length(handles.Plot2_Data)]);
    set(handles.Plot2, 'YLim', [0 handles.Lx]);
    set(handles.Plot2, 'units', 'normalized', 'FontSize', 9);
    xlabel(handles.Plot2, 'Measurement Nr.', 'FontWeight', 'bold', 'units', ...
           'normalized', 'FontSize', 10);
    ylabel(handles.Plot2, 'x (mm)', 'FontWeight', 'bold', 'units', ...
           'normalized', 'FontSize', 10);
end


function Button_Plot1_Callback(hObject, eventdata, handles)
    figure('units', 'normalized', 'position', [0.004 0.03 0.992 0.9]);

    Numy = round(handles.Ly/handles.dy+1);

    t_foc = 1.86e-6;
    v_s   = 1510;
    
    S     = single(handles.Plot1_Data);
    
    Ntime = size(S,2);
    
    ChebyFlag = 1;
    BandpFlag = 1;
    
    if ChebyFlag
        [b, a] = cheby1(4, .01, 2*0.01, 'high');
        
        for j = 1:Ntime
            ss = squeeze(double(S(:, j)));
            S(:, j) = single(filtfilt(b, a, ss));
        end
    end
    
    if BandpFlag
        S = S';
        
        dt = 1/handles.SamplingRate;
        t_0 = 0:dt:(Ntime-1)*dt;
        t_0 = t_0 + handles.TriggerOffset*dt - t_foc;
        
        for i = 1:size(S,1)
            S_filt = filterData(S(:,i), t_0, [25e6 125e6], 'BP');
            S(:,i) = S_filt;
        end
        
        S = S';
    end
    
    if Numy < 10 && Numy > 1
        imagesc(([(handles.TriggerOffset+1) (handles.TriggerOffset+(handles.nSegments*512))]/handles.SamplingRate-t_foc)*v_s*1e6, ...
                [handles.y0-handles.Ly/2 handles.y0+handles.Ly/2], S);
        ylabel(gca, 'y position (mm)', 'FontWeight', 'bold', 'units', ...
               'normalized', 'FontSize', 10)
    else
        imagesc(([(handles.TriggerOffset+1) (handles.TriggerOffset+(handles.nSegments*512))]/handles.SamplingRate-t_foc)*v_s*1e6, ...
                [handles.x0-handles.Lx/2 handles.x0+handles.Lx/2], S);
        ylabel(gca, 'x position (mm)', 'FontWeight', 'bold', 'units', ...
               'normalized', 'FontSize', 10)
    end
    
    if handles.grid
        grid(gca);
    end
    
    colormap(gray);
    set(gca, 'units', 'normalized', 'FontSize', 9);
    xlabel(gca, 'z_{VD}  (µm)', 'FontWeight', 'bold', 'units', ...
           'normalized', 'FontSize', 10);

end


function Toggle_Grid_Callback(hObject, eventdata, handles)
    handles.grid = get(handles.Toggle_Grid, 'Value');
    guidata(hObject, handles);
    
    Numy = round(handles.Ly/handles.dy+1);

    if Numy < 10 && Numy > 1
        PlotAll(hObject, eventdata, handles);
    else
        PlotBScan(hObject, eventdata, handles);
    end
end


function Move_x_Callback(hObject, eventdata, handles)
    handles.MoveToX = str2double(get(handles.Move_x, 'String'));
    set(handles.position_x, 'String', handles.MoveToX);
    guidata(hObject, handles);
    position_x_Callback(hObject, eventdata, handles);
end


function Move_y_Callback(hObject, eventdata, handles)
    handles.MoveToY = str2double(get(handles.Move_y, 'String'));
    set(handles.position_y, 'String', handles.MoveToY);
    guidata(hObject, handles);
    position_y_Callback(hObject, eventdata, handles);
end


function Button_Move_Callback(hObject, eventdata, handles)
    pi2xMoveAbs(handles.pi, handles.MoveToX, handles.MoveToY);
end


function Radio_MeasureCont_Callback(hObject, eventdata, handles)
    handles.Measurement_Mode = 1;
    set(handles.Radio_MeasureDisc, 'Value', 0);
    set(handles.Input_Averages, 'String', 1);
    guidata(hObject, handles);
end


function Radio_MeasureDisc_Callback(hObject, eventdata, handles)
    handles.Measurement_Mode = 2;
    set(handles.Radio_MeasureCont, 'Value', 0);
    guidata(hObject, handles);
end


function Input_Averages_Callback(hObject, eventdata, handles)
    handles.NrAverages = str2double(get(handles.Input_Averages, 'String'));
    guidata(hObject, handles);
end


function Button_Measure_Callback(hObject, eventdata, handles)
%     handles.Stop = 0;
%     guidata(hObject, handles);

    if handles.Measurement_Mode == 1
        measureMScan(hObject, eventdata, handles);
    else
        measureMScanDisc(hObject, eventdata, handles);
    end
end


function Button_Stop_Callback(hObject, eventdata, handles)
    handles.Stop = 1;
    guidata(hObject, handles);
end


function position_x_Callback(hObject, eventdata, handles)
    handles.x0 = str2double(get(handles.position_x, 'String'));
    guidata(hObject, handles);
end


function range_x_Callback(hObject, eventdata, handles)
    handles.Lx = str2double(get(handles.range_x, 'String'));
    guidata(hObject, handles);
end


function position_y_Callback(hObject, eventdata, handles)
    handles.y0 = str2double(get(handles.position_y, 'String'));
    guidata(hObject, handles);
end


function range_y_Callback(hObject, eventdata, handles)
    handles.Ly = str2double(get(handles.range_y, 'String'));
    guidata(hObject, handles);
end


function step_x_Callback(hObject, eventdata, handles)
    handles.dx = str2double(get(handles.step_x, 'String'));
    guidata(hObject, handles);
end


function step_y_Callback(hObject, eventdata, handles)
    handles.dy = str2double(get(handles.step_y, 'String'));
    guidata(hObject, handles);
end


function xy_speed_Callback(hObject, eventdata, handles)
    handles.vAct = str2double(get(handles.xy_speed, 'String'));
    guidata(hObject, handles);
end


function Check_SwapXY_Callback(hObject, eventdata, handles)
    handles.SwapXYFlag = get(handles.Check_SwapXY, 'Value');
    guidata(hObject, handles);
end


function Check_AccCorr_Callback(hObject, eventdata, handles)
    handles.AccCorrFlag = get(handles.Check_AccCorr, 'Value');
    guidata(hObject, handles);
end


function Input_Acc_Callback(hObject, eventdata, handles)
    handles.aAct = str2double(get(handles.Input_Acc, 'String'));
    guidata(hObject, handles);
end


function Input_tWaitY_Callback(hObject, eventdata, handles)
    handles.tWaitBScan = str2double(get(handles.Input_tWaitY, 'String'));
    guidata(hObject, handles);
end


function Button_Initialize_DAQ_Callback(hObject, eventdata, handles)
    handles.DAQ = gageInit();
    guidata(hObject, handles);
end


function Button_Terminate_DAQ_Callback(hObject, eventdata, handles)
    freeGage(handles.DAQ);
end


function Button_Initialize_Stages_Callback(hObject, eventdata, handles)
    pi = pi2xStart();
    pi2xOpen(pi);
    handles.pi  = pi;
    guidata(hObject, handles);
end


function Button_Terminate_Stages_Callback(hObject, eventdata, handles)
    clear pi;
    fclose(instrfind);
    delete(instrfind);
end


function Check_Save_Callback(hObject, eventdata, handles)
    handles.saveflag = get(handles.Check_Save, 'Value');
    
%     if handles.saveflag == 0
%         set(handles.Text_Filename, 'Visible', 'off');
%         set(handles.Input_Filename, 'Visible', 'off');
%     else
%         set(handles.Text_Filename, 'Visible', 'on');
%         set(handles.Input_Filename, 'Visible', 'on');
%     end
        
    guidata(hObject, handles);
end


function Input_Filename_Callback(hObject, eventdata, handles)
    handles.saveName = get(handles.Input_Filename, 'String');
    guidata(hObject, handles);
end


function Input_Path_Callback(hObject, eventdata, handles)
    handles.savePath = get(handles.Input_Path, 'String');
    guidata(hObject, handles);
end


function List_InputRange_Callback(hObject, eventdata, handles)
    InpRang = get(handles.List_InputRange, 'Value');

    switch InpRang
        case 1
            handles.Input1Range = 10000;
        case 2
            handles.Input1Range = 4000;
        case 3
            handles.Input1Range = 2000;
        case 4
            handles.Input1Range = 1000;
        case 5
            handles.Input1Range = 400;
        case 6
            handles.Input1Range = 200;
    end
    
    guidata(hObject, handles);
    SetupMScan(hObject, eventdata, handles);
end


function Input_NrSegments_Callback(hObject, eventdata, handles)
    handles.nSegments = str2double(get(handles.Input_NrSegments, 'String'));
    guidata(hObject, handles);
    SetupMScan(hObject, eventdata, handles);
end


function Input_SamplingRate_Callback(hObject, eventdata, handles)
    handles.SamplingRate = 1e6*str2double(get(handles.Input_SamplingRate, 'String'));
    guidata(hObject, handles);
    SetupMScan(hObject, eventdata, handles);
end


function List_DataType_Callback(hObject, eventdata, handles)
    DatTyp = get(handles.List_DataType, 'Value');

    switch DatTyp
        case 1
            handles.DataType = 1;
        case 2
            handles.DataType = 0;
    end
    
    guidata(hObject, handles);
    SetupMScan(hObject, eventdata, handles);
end


function List_TriggerRange_Callback(hObject, eventdata, handles)
    TrigRang = get(handles.List_TriggerRange, 'Value');

    switch TrigRang
        case 1
            handles.TriggerRange = 10000;
        case 2
            handles.TriggerRange = 4000;
        case 3
            handles.TriggerRange = 2000;
        case 4
            handles.TriggerRange = 1000;
        case 5
            handles.TriggerRange = 400;
        case 6
            handles.TriggerRange = 200;
    end
    
    guidata(hObject, handles);
    SetupMScan(hObject, eventdata, handles);
end


function Input_TriggerOffset_Callback(hObject, eventdata, handles)
    handles.TriggerOffset = str2double(get(handles.Input_TriggerOffset, 'String'));
    guidata(hObject, handles);
    SetupMScan(hObject, eventdata, handles);
end


function Input_TriggerLevel_Callback(hObject, eventdata, handles)
    handles.TriggerLevel = str2double(get(handles.Input_TriggerLevel, 'String'));
    guidata(hObject, handles);
    SetupMScan(hObject, eventdata, handles);
end


function Input_TriggerChannel_Callback(hObject, eventdata, handles)
    handles.TriggerChannel = str2double(get(handles.Input_TriggerChannel, 'String'));
    guidata(hObject, handles);
    SetupMScan(hObject, eventdata, handles);
end


function Text_MeasurementNr_Callback(hObject, eventdata, handles)
end
function Text_BScan_Callback(hObject, eventdata, handles)
end
function Text_TimeLeft_Callback(hObject, eventdata, handles)
end
function Text_MeasurementsTotal_Callback(hObject, eventdata, handles)
end
function Text_TimeTotal_Callback(hObject, eventdata, handles)
end


function DispIni(hObject, eventdata, handles)
    if handles.Measurement_Mode == 1
        set(handles.Radio_MeasureCont, 'Value', 1);
        set(handles.Radio_MeasureDisc, 'Value', 0);
    else
        set(handles.Radio_MeasureCont, 'Value', 0);
        set(handles.Radio_MeasureDisc, 'Value', 1);
    end

    set(handles.Input_Averages, 'String', handles.NrAverages);
    set(handles.Move_x, 'String', handles.MoveToX);
    set(handles.Move_y, 'String', handles.MoveToY);
    set(handles.position_x, 'String', handles.x0);
    set(handles.position_y, 'String', handles.y0);
    set(handles.range_x, 'String', handles.Lx);
    set(handles.range_y, 'String', handles.Ly);
    set(handles.step_x, 'String', handles.dx);
    set(handles.step_y, 'String', handles.dy);
    set(handles.xy_speed, 'String', handles.vAct);
    set(handles.Input_Acc, 'String', handles.aAct);
    set(handles.Input_tWaitY, 'String', handles.tWaitBScan);
    set(handles.Check_AccCorr, 'Value', handles.AccCorrFlag);
    set(handles.Check_SwapXY, 'Value', handles.SwapXYFlag);
    set(handles.Check_Save, 'Value', handles.saveflag);
    set(handles.Input_Filename, 'String', handles.saveName);
    set(handles.Input_Path, 'String', handles.savePath);

    switch handles.Input1Range
        case 10000
            InpRang = 1;
        case 4000
            InpRang = 2;
        case 2000
            InpRang = 3;
        case 1000
            InpRang = 4;
        case 400
            InpRang = 5;
        case 200
            InpRang = 6;
    end
    
    set(handles.List_InputRange, 'Value', InpRang);
    
    switch handles.DataType
        case 0
            DatTyp = 2;
        case 1
            DatTyp = 1;
    end
    
    set(handles.List_DataType, 'Value', DatTyp);
    
    set(handles.Input_NrSegments, 'String', handles.nSegments);
    SampRat = 1e-6*handles.SamplingRate;
    set(handles.Input_SamplingRate, 'String', SampRat);
    
    switch handles.TriggerRange
        case 10000
            TrigRang = 1;
        case 4000
            TrigRang = 2;
        case 2000
            TrigRang = 3;
        case 1000
            TrigRang = 4;
        case 400
            TrigRang = 5;
        case 200
            TrigRang = 6;
    end
    
    set(handles.List_TriggerRange, 'Value', TrigRang);
    
    set(handles.Input_TriggerOffset, 'String', handles.TriggerOffset);
    set(handles.Input_TriggerLevel, 'String', handles.TriggerLevel);
    set(handles.Input_TriggerChannel, 'String', handles.TriggerChannel);
end


function varargout = bscan_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;                                             % Get default command line output from handles structure
end


function figure1_CloseRequestFcn(hObject, eventdata, handles) 
    % Close connection to stages:
    
    if isempty(instrfind) == 0
        fclose(instrfind);
        delete(instrfind);
    end
    
    % Close connection to DAQ Card
    freeGage(handles.DAQ);
    
    delete(hObject);
end


%% ################ Layout

function range_y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function position_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function range_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function step_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function xy_speed_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_TriggerOffset_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_NrSegments_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function List_InputRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function step_y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function position_y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_Filename_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_Path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function List_TriggerRange_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_SamplingRate_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_TriggerLevel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_TriggerChannel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function List_DataType_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Text_MeasurementNr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Text_BScan_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Text_TimeLeft_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Text_MeasurementsTotal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Text_TimeTotal_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Move_x_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Move_y_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_Averages_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_Acc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

function Input_tWaitY_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end
