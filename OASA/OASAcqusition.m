% 
if exist ('piStage', 'var')
    disp('Warning the defined handles and variables would be deleted!');
    return;
end
close all; clear all; clc
%% Declare global variabels
 global mlc;
 global NofAverages nSamples xLim yLim dx dy ;
 global s_LPSP s_VISNIR selectedWLsInit  powersInit actualPowersInit saveName ;
 global signalBeg signalEnd;
% %% Initiate PI STAGES 
% if exist ('piStage', 'var') 
%     return; 
% end
% global piStage;
 pathPi = 'D:\Users\mir.seyedebrahimi\Documents\MATLAB\piHydra_Stage'; 
 if exist(pathPi)
  addpath (pathPi);
 else 
  display ('Please specify/add the folder with PI MATLAB functions');
  return;
 end; 

% piStage = piStart(7); 
% pause (2);
% piOpen(piStage); 
% piSetVel(piStage, 1);
% %piSetVel(piStage, 10); 
%                            
%                            % meat 21,6 
% piSetVel(piStage, 20);
% % [vActX,vActY] = piGetVel(piStage);
% piSetAcc(piStage, 1000);
% piSetDec(piStage, 1000);
% clear pathPi;
% piMoveAbs(piStage, 1,25);

%% INITIATE laser 
mlc = helmholtz.ibmi.hwcontrol.laser.MLaserControlInnolas.getInstance();
initlaser = mlc.initLaser; %turns on laser
mlc.tune(1400);                                                                                                                                                                                                                   
clear initlaser;
  %% Servo initialization 
arduinoSwitch = arduino('com9', 'uno', 'Libraries', 'Servo');
pause (1);
s_LPSP = servo(arduinoSwitch, 'D4', 'MinPulseDuration', 375*10^-6, 'MaxPulseDuration',1125*10^-6); % initial and end rot. deg.
s_VISNIR = servo(arduinoSwitch, 'D8', 'MinPulseDuration', 375*10^-6, 'MaxPulseDuration',1125*10^-6);

  LPSP_FilterSelect (s_LPSP, 'NIR');
  VIS_NIR_Select (s_VISNIR , 'NIR');
 pause (2);
 
  LPSP_FilterSelect (s_LPSP, 'VIS');
  VIS_NIR_Select (s_VISNIR , 'VIS');

  display ('Arduino was successfuly initialised & set to VIS range');
  
%% Init Half Wave rotation stage
 if exist('HWPRotor','var')
     return;
 end
display ('Initializing and homing Half Wave Plate rotor');
global HWPRotor; % make h a global variable so it can be used outside the main
fpos    = get(0,'DefaultFigurePosition'); % figure default position
fpos(3) = 650; % figure window size;Width
fpos(4) = 450; % Height
f = figure('Position', fpos,'Menu','None','Name','APT GUI');
HWPRotor = actxcontrol('MGMOTOR.MGMotorCtrl.1',[20 20 600 400 ], f);
HWPRotor.StartCtrl;
SN = 83827793; % put in the serial number of the hardware
%if exist('s_LPSP','var')
   LPSP_FilterSelect (s_LPSP,  'blk');
%end 
set(HWPRotor,'HWSerialNum', SN);
HWPRotor.Identify;
% pause(5); % waiting for the GUI to load up;
HWPRotor.MoveHome(0,1==0);
 %initPos = 70;
  initPos = LookupParamSin(650,0.5) % choose once according to look up table
  move_to_pos (HWPRotor,initPos); % use this function to move to desired position
  display (['HWP Initialised, Homed and set to: ' num2str(initPos)]);
%if exist('arduinoSwitch','var')
   LPSP_FilterSelect (s_LPSP,  'VIS'); %%?
%end 
clear initPos fpos SN f;
%% TURN laser ON
%%                       
                   
lamp = mlc.lampON(); %lamp on

qswtich = mlc.qswitchON();% turn                                                                                                                                                                                                                                                                                                                                                                                                laser on

%% Powermeter INITIALISATION   <-    here 

% addpath  D:\MATLAB\Dropbox\PowerCorrection

                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      
nameOfCOMPORT = 'COM7';
PowerMeterHandle = serial(nameOfCOMPORT); %assigns the object s to serial port
%pause (1);
set(PowerMeterHandle, 'InputBufferSize', 512); %number of bytes in inout buffer
set(PowerMeterHandle, 'FlowControl', 'none');
set(PowerMeterHandle, 'BaudRate', 9600 ); % 9600 19200 38400
set(PowerMeterHandle, 'Parity', 'none');
set(PowerMeterHandle, 'DataBits', 8);
set(PowerMeterHandle, 'StopBit', 1);
set(PowerMeterHandle, 'Timeout',10);                                                                                  
%clc;
fopen(PowerMeterHandle);           %opens the serial port
%pause (1);
display ('Inicialization complete');
display ('Starting acquisition');
fprintf(PowerMeterHandle,['$FE' 13 10]); % Force power mode
WLBeg = 420;
fprintf(PowerMeterHandle,['$WL ' num2str(WLBeg) 13]); % First wavelenght is set
% fwrite(s,['$RE' 13 10]);  % reset instrument
pause (1);

%% Setup DAQ
%  if exist('DAQ','var')
%      return;
%  end
%   freeGage(131083);
% global DAQ;
% Parameters for DAQ:
RepRate    = 50;                    % Repitition rate of Innolas laser
inputRange = 10000;                    % [mV]
trigDelay  = 1000;                     % Focus: 870 (500MS) / 1740 (1GS) according to depth selection...
nSamples   = 5*512;                   % Number of samples


trigDelay  = ceil(trigDelay/32)*32; %? why 32
nSamples   = ceil(nSamples/32)*32;
acqRes     = 32; %?
segCount   = 1;                       % this is the single acquisition code
nSegments  = ceil(nSamples/acqRes);
NofAverages = 50;

DAQ = 0;
systems= CsMl_Initialize;
CsMl_ErrorHandler(systems);
[ret, DAQ] = CsMl_GetSystem;
%CsMl_ErrorHandler(ret);
[ret, sysinfo] = CsMl_GetSystemInfo(DAQ);
CsMl_ErrorHandler(ret);
Setup(DAQ,trigDelay, nSamples);
ret = CsMl_Commit(DAQ);                                                    % Pass parameters to DAQ system
CsMl_ErrorHandler(ret, 1, DAQ);
[ret, acqInfo] = CsMl_QueryAcquisition(DAQ);
[ret, chInfo]  = CsMl_QueryChannel(DAQ, 1);
CsMl_ResetTimeStamp(DAQ);
transfer.Mode = CsMl_Translate('Default', 'TxMode');
transfer.Segment = 1;
transfer.Start = -acqInfo.TriggerHoldoff;
transfer.Length = acqInfo.SegmentSize;
transfer.Channel = 1;
trigDelay  = acqInfo.TriggerDelay;
nPts       = acqInfo.SegmentSize;
Fs         = acqInfo.SampleRate;
InputRange = chInfo.InputRange;

clear RepRate inputRange ret;                    % Repitition rate of Innolas laser


%%  **************************************************************************
 %% COUNTOUR the imaging perimeter 
% rounds = 2; 
% disp (sprintf('Countouring the scanning area perimeter %d times', rounds));
% piSetVel(piStage, 5);
% % piMoveAbs(pi,xLim(1),yLim(1));
% % while ~piIsIdle(pi) 
% %     pause(0.1);
% % end
% 
% if ~exist('xLim', 'var')||~exist('yLim', 'var')
%    xLim =[0 26];
%    yLim =[0 26];
% end
% 
% 
% for iiR = 1:rounds
%     for pos = 1:4 
%     switch pos 
%         case 1
%             piX = xLim(1);
%             piY = yLim(1);
%         case 2
%             piX = xLim(1);
%             piY = yLim(2);
%         case 3
%             piX = xLim(2);
%             piY = yLim(2);
%         case 4                     
%             piX = xLim(2);
%             piY = yLim(1);            
%     end              
%                 piMoveAbs(piStage,piX,piY);
%                 pause(0.001);
%                 while ~piIsIdle(piStage) 
%                    piIsIdle(piStage) 
%                 end
%             
%     end 
% end %iiR
% piSetVel(piStage, 20);
% disp ('Done!');
%  
 %% !!!!!!!!!!!!!!!!!      FULL SCAN SEQUENCE  !!!!!!!!!!!!!!!!!!
%  PREPARATION!!! 
global xLimDefault yLimDefault dxDefault dyDefault clasterizationParameter;


% xLim=[12 14];% meat 13,6 
% yLim =[5 7];
%  xLim=[21 23];% meat light 
%  yLim =[5 7];
%  xLim=[4 6];% fat
%  yLim =[5 7];
%   xLim=[12 14];% Water
%   yLim =[12 14];000,,,,
%    xLim=[20 23];% smpl5
%    yLim =[11 14];
%    xLim=[20 23];% smpl6
%    yLim =[19 21];
%     xLim=[11 15];% Cartilage
%     yLim =[18 22];
%     xLim=[4 6];% Sample 8
%     yLim =[19 23];
%       


% piMoveAbs(piStage, 20.5,15); 
 

xLim=[17 23];% Sample 8
yLim =[10 20];
% piMoveAbs(piStage, mean(xLim ),mean(yLim )); 


                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
dx = 0.5;
dy = 0.5;

xLimDefault = xLim;
yLimDefault = yLim;
dxDefault = dx;
dyDefault = dy;
Nx = diff (xLim)/dx;
Ny = diff (yLim)/dy;
signalBeg = 50;
signalEnd = 1000;
xLimOld = xLim;
yLimOld = yLim;
testPower = 0.3;
% NofAverages = 20;
rounds = 2;
% selectedWLsInit  = [420:5:700]; 
% powersInit = [0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.2 0.2 0.2 0.2 0.2 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4 0.4]; 
% 
% powersInit = [powersInit 0.4*ones((numel(selectedWLsInit) - numel(powersInit)),1)']; 

% selectedWLsInit  = [900:50:1100 1120:20:1400 1410:10:1780 1800:20:1940];

% powersInit = [0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 ]; 
% selectedWLsInit  = [420:20:700];
% powersInit = [0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.1 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.2 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 ]; 

powersInit = [0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 0.3 ];    
powersInit = [powersInit powersInit powersInit];
powersInit = 5*powersInit/0.3;


selectedWLsInit  = [ 900:20:2000]; %[500:10:760 800 850 900:10:950 1200:10:1220];

selectedWLs = selectedWLsInit;
selectedWLsForImaging = [550 600 650 700 750 930 1210]; 

%actualPowersInit = [0.104500000000000;0.153350000000000;0.136550000000000;0.0847500000000000;0.0735500000000000;0.0820000000000000;0.0917500000000000;0.0808166666666667];

 actualPowersInit = ones (numel(selectedWLsInit),1);

clasterizationParameter = 10; % defines the allowed variation of power when clustering

if ~issorted(selectedWLs)||~issorted(selectedWLsForImaging)
    display  ('WARNING!!! Please sort the wavelenght array!!');
end;





%% cLUSTERIYATION

addpath('D:\Users\mir.seyedebrahimi\Documents\MATLAB\piHydra_Stage\PowerCorrection')
addpath('D:\Users\mir.seyedebrahimi\Documents\MATLAB\piHydra_Stage\piHydra_Stage')
      
% nPts = nSamples;
nWLs = numel (selectedWLs);
% SelectedWLs = sort(SelectedWLs);
% powersActual = PWrsAver;
% t_start_all = tic;
% counterTot = 0;
clasterizationParameter = 20;

% optimization (clasterisation) of WL 
    [anglSet, optimisation] = clusterWLs (selectedWLs,powersInit(1:nWLs),clasterizationParameter);
    selectedWLs = anglSet(1,:);
    powers = anglSet(4,:);
    disp (['Clusterization of WLs led to ' num2str(optimisation) ' times speeding']);
    %clear anglSet optimisation;
    figure
    plot (powers);

    %% Measure the power at selectedWLs's   <- then run this code 
    
    
    
          PWrs = 0;
      T = tic;
      
    	flagVis = 1;
	LPSP_FilterSelect (s_LPSP, 'VIS');
    VIS_NIR_Select (s_VISNIR , 'VIS');
    
      for iiR=1:2
          for iiWL=1:numel(selectedWLs)
            WL = selectedWLs(iiWL);
            mlc.tune(WL);
            if WL>700&&flagVis
                
              LPSP_FilterSelect (s_LPSP, 'NIR');
              VIS_NIR_Select (s_VISNIR , 'NIR');
 
                
            flagVis = 0;  
            pause (1.3);
            end
            if WL<701&&flagVis==0
                LPSP_FilterSelect (s_LPSP, 'VIS');
                VIS_NIR_Select (s_VISNIR , 'VIS');
                flagVis = 1;
                pause (1.3);
            end
                
            
            initPos = LookupParamSin(WL , powers(iiWL));
            move_to_pos (HWPRotor,initPos); % use this function to move to desired position
            display (['HWP set to: ' num2str(initPos)]);
            pause (0.1);  
            PmJ1 = Power_Get(WL, 10, PowerMeterHandle);
            PWrs = [PWrs PmJ1 ];
          end   
          toc(T);
      end
      PWrs(1)='';
      
    PWrs2=reshape(PWrs,numel(PWrs)/2,2);
      actualPowersInit=mean(PWrs2,2);
      PWrsAverErr=std(PWrs2')';
         figure;
      plot (selectedWLs',actualPowersInit,'o-');
      
      % I will suggest you to save  both PWrs2 and actualPowersInit
      
     % you will actually need actualPowersInit, but sometimes it is good to
     % open PWre2 and check. because actualPowersInit is a mean of 5
     % measurements. but sometimes measurements can go bad and there will
     % be 0 instead of value. so it will be like 0.75 0.7 0.7 0 0.75 - and
     % the average will be miscalculated. 
     % Do you understand? yes
     % nice thats why i always check 
     
     % questions? tha
      
  
% 
% lamp = mlc.lampOFF(); %lamp on
% qswtich = mlc.qswitchOFF();% turn laser on
%%  Sub for just one point spectral scan 
tic
%  addpath D:\Users\ara.ghazaryan\Documents\MATLAB\PowerCorrection
% clasterizationParameter = 20;

  rounds = 3; 


              sImage = 0;
                 
                [Ch1_raw,Ch2_raw,Signal_ch1,Signal_ch2] = OASPointAcq_vCH2(DAQ,sImage', 1, 1, selectedWLs, rounds, NofAverages, powers);
              
%                       [S,S_raw]= OASPointAcq_vCH1(DAQ,sImage', 1, 1, selectedWLs, rounds, NofAverages, powers);
    toc                
            % Include the desired Default answer
            % Use the TeX interpreter in the question
            %%
            global savePath;

saveName = 'GL1Over64_Ink_P5_F05F0';
FoldernameDef = 'TwoChannel';

cdat = clock;
    if cdat(2) < 10
        cdate = [num2str(cdat(1)) '.0' num2str(cdat(2))];
    else
        cdate = [num2str(cdat(1)) '.' num2str(cdat(2))];
    end
    if cdat(3) < 10
        cdate = [cdate '.0' num2str(cdat(3))];
    else
        cdate = [cdate '.' num2str(cdat(3))];
    end
Foldername = [cdate '_' FoldernameDef];
GeneralSavePath = 'D:\Users\mir.seyedebrahimi\Desktop\Mehdi';

prompt = {'Enter F  older Name:','Enter File Name:'};
dlg_title = 'Save Name/Destination';
num_lines = 1;
defaultans = {Foldername,saveName};
answer = inputdlg(prompt,dlg_title,[1 50],defaultans);
saveName = answer{2};
Foldername = answer{1};
%[GeneralSavePath Foldername ]
savePath = [GeneralSavePath Foldername '\'];
if ~exist([GeneralSavePath Foldername ])
    mkdir([GeneralSavePath Foldername ]);
end
clear Foldername FoldernameDef GeneralSavePath defaultans dlg_title num_lines prompt;

            %% save
 save([savePath saveName '_PointOAS' ],'Ch1_raw','Ch2_raw','Signal_ch1','Signal_ch2', 'selectedWLs', 'powers','rounds'); % save signal
%   save([savePath saveName 'PointOAS' ], 'S','S_raw', 'selectedWLs', 'powers','rounds'); % save signal
 save([savePath 'Power_ref2_90_P1p3' '_PointOAS' ], 'actualPowersInit', 'selectedWLs', 'powers','PWrs2'); % save power


%% THE ACQUISITION STARTS HERE!!
% request draft parameters

choice = 'Zoom in (Draft)';
zoomInd = 1;

while ~strcmp(choice,'dummy')

dx = diff (xLim)/Nx; dx = round (dx*100 )/100;
dy = diff (yLim)/Ny; dy = round (dy*100 )/100;
xMid =mean(xLim); yMid =mean(yLim);
xDif = diff(xLim); yDif = diff(yLim);
% acquire amd draw draft 
% **************************************************************************
% choise='highRes'
if strcmp(choice,'none') % Construct a questdlg with three options
choice = questdlg('Choose what needs to be done', ...
	'Cancel', ...
	'Zoom in (Draft)','Zoom in (fineRes)','OAS Point','Zoom in (Draft)');
end
% Handle response
switch choice
    case 'Zoom in (Draft)'
        [WL,testPower,choiseIsDone]=promptScanParamteres('draft');
        if ~choiseIsDone 
            return
        end
%         [S_] = OASDraftAcq(DAQ, piStage, s_LPSP, s_VISNIR, mlc, HWPRotor,...
%         xLim, yLim,dx,dy, WL, testPower, nSamples, signalBeg, ... 
%         signalEnd, [savePath saveName '_draft_']);
        xCor=xLim(1):dx:xLim(2);
        yCor=yLim(1):dy:yLim(2);
        Lx =round(diff(xLim),2);
        Ly =round(diff(yLim),2);
        Nx = round(diff (xLim)/dx);
        Ny = round(diff (yLim)/dy);         
        %sImage=prepareImage(S_,signalBeg, signalEnd);
        sImage=S_';
        % clearvars 'Prompt'  'Title'  'formats' 'DefAns' 'Options';
    case 'Zoom in (fineRes)'
        [WL,testPower,choiseIsDone]=promptScanParamteres('highRes');
        if ~choiseIsDone 
            choice = 'dummy';
            return
        end
        Lx =round(diff(xLim),2);
        Ly =round(diff(yLim),2);
        Nx = round(diff (xLim)/dx);
        Ny = round(diff (yLim)/dy);                
        [S_] = OAShiResAcq(DAQ, xLim, yLim,dx,dy, selectedWLsForImaging, [savePath saveName '_' num2str(zoomInd)]);
        xCor=xLim(1):dx:xLim(2);
        yCor=yLim(1):dy:yLim(2);
        display ('Please wait, matlab is preparing the image');
        sImage=prepareImage(S_,signalBeg, signalEnd);
        sImage=sImage';
% *************************************************************************
% *************** FULL  SPECTRA SCAN ON PREDEFINED POINTS  ****************
% *************************************************************************
    case 'OAS Point'
        if numel(xx)>0
            [rounds,iWL,choiseIsDone]=promptScanParamteres('PointOAS');
                if choiseIsDone
                    tmpCord = unique([xx ,yy],'rows');
                    xx=''; yy='';
                    xx=tmpCord(:,1); yy=tmpCord(:,2); clear tmpCord;
                    S = OASPointAcq(DAQ,sImage',xLimOld,yLimOld, xx, yy, selectedWLs, rounds, NofAverages);
                end   
                options.Interpreter = 'tex';
            % Include the desired Default answer
            % Use the TeX interpreter in the question
            qstring = 'Would you like to continue acquisition?';
            choicePointOAS = questdlg(qstring,'Further actions',...
            'Yes','No','No');
            if strcmp(choicePointOAS ,'Yes')
                choice ='none';
            else
                choice = 'dummy';
            end
        else
            display(['first you have to define the points of OAS' 13 'Please start over and do Draft or HighRes scan first!'])
            return;
            choice = 'dummy';
        end
    case 'Cancel'
        display(['Nothing Chosen. Canceling'])
        choice = 'dummy';
        return;
    end  %Select
    
    if  strcmp(choice,'Zoom in (Draft)')||strcmp(choice,'Zoom in (fineRes)')
        choice = questdlg('Do you need to further ', ...
        'Cancel', ...
        'Zoom in (Draft)','Zoom in (fineRes)','OAS Point','Zoom in (Draft)');
       Lx =round(diff(xLim),2);
       Ly =round(diff(yLim),2);
       Nx = round(diff (xLim)/dx);
       Ny = round(diff (yLim)/dy);
       
   if  strcmp(choice,'Zoom in (Draft)')
       nameOfWindow ='Chose a ROI for draft from ';
   else 
       nameOfWindow ='Chose a ROI for highRes from ';
   end
       nameOfWindow=[nameOfWindow num2str(Lx) 'x' num2str(Ly) 'mm (' num2str(Nx)  'x' num2str(Ny) ')'];
       F=figure('Name',nameOfWindow,'NumberTitle','off');
        imagesc(xCor,yCor,sImage);
        axis image ;
        colormap(hot);
        xLimOld = xLim;
        yLimOld = yLim;
        [xCor,yCor,BW,xx,yy] = roipoly();
        if numel(xx)==0
            disp ('No points or roi was specified!')
            return;
        end
        if ishandle(F)
            close (F);
            clear 'F';
        end
        xLim(1) = min (xx);
        xLim(2) = max (xx);
        yLim(1) = min (yy);
        yLim(2) = max (yy);
        if xLim(1)<0 
            xLim(1)=0;
        end
        if xLim(2)>26 
            xLim(2)=26;
        end
        if yLim(1)<0 
            yLim(1)=0;
        end
        if yLim(2)>26 
            yLim(2)=26;
        end

    end
    dx = round(diff (xLim)/Nx);
    dy = round(diff (yLim)/Ny);
    
    zoomInd = zoomInd+1;
   
end %while
%% 
% bring to init
%    LPSP_FilterSelect (s_LPSP,  'blk');
%   initPos = LookupParamSin(550,0.3);
%   mlc.tune(550);
%   move_to_pos (HWPRotor,initPos); % use this function to move to desired position
%   display (['HWP Initialised, Homed and set to: ' num2str(initPos)]);
% %if exist('arduinoSwitch','var')
%    LPSP_FilterSelect (s_LPSP,  'VIS');

%% Close all figures except Half Wave Plate
handles=findall(0,'type','figure');
if numel(handles)>1
    for ii = 1:numel(handles)
       if ~strcmp(handles(ii).Name,'APT GUI')
            close (handles(ii));
       end
    end
end    





