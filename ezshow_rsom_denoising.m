%%
% This is trial on wavelet-based denoising 
% Yuanhui Huang 
% 20170217
%%
clear all; %close all;
cd C:\Users\Yuanhui\Matlab\TAM_hybrid
folder_name = 'C:\Users\Yuanhui\Matlab\TAM_hybrid\Data';
% fileParams.dataName = '201604211614_TAM_OLine25_Copper_5kV_US_100MHFM18_TAM_15-37.4us_AVG500_5';
% fileParams.dataName = '201604252007_TAM_OLine25_Yeast_tube3_surface_5kV_US_V3330_TAM_81-88us_AVG500_210';
fileParams.dataName = '201806021914_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_9kV_RS_70-210us_AVG1024_3307.5';
% 201611282029_TAM_WNOilLine50_9ambornFishEgg_10kV_V3330_TAM_81-182us_AVG1024_320
% 201611282041_TAM_WNOilLine50_9ambornFishEgg_10kV_V3330_TAM_81-182us_AVG1024_300
% 201611282120_TAM_WNOilLine50_9ambornFishEgg_10kV_V3330_TAM_81-182us_AVG1024_280
% 201702042059_TAM_WNOil2Line50_32hourFishEgg_live-dead_10kV_V3330_TAM_81-182us_AVG1024_280
% 201702041945_TAM_WNOil2Line50_32hourFishEgg_dead-live_10kV_V3330_TAM_81-182us_AVG1024_260
% 201702071932_TAM_WNOil2Line50_4dayFishEgg_live-dead_TA_V3330_TAM_81-182us_AVG1024_270
% 201604211614_TAM_OLine25_Copper_5kV_US_100MHFM18_TAM_15-37.4us_AVG500_5
% 201604252007_TAM_OLine25_Yeast_tube3_surface_5kV_US_V3330_TAM_81-88us_AVG500_210
% 201608031645_TAM_WOilLine50_Fish_7kV_V3330_day1_TAM_81-182us_AVG1024_205
% 201608102201_TAM_WOilLine50_Fish_10kV_V3330_no_touching_day1_TAM_81-182us_AVG1024_210
% 201702112029_TAM_WNOil2Line50_8dayFish_10kV_V3330_TAM_81-182us_AVG1024_260
fileParams.data = [folder_name '\'];
isDirExist([fileParams.data fileParams.dataName], 1); % 1: mkdir(FullPath);
load([fileParams.data fileParams.dataName '.mat']);
is_Tiff=0;

is_rsom = 0;

Fs = 500e6;
dt = 1/Fs;
SoS = 1.498; % speed of sound 1.5mm/us
% SoS = 0.970; % speed of sound 1.5mm/us
% tDelay = 25e-6;

tDelay=trigDelay*1/Fs;
tt_ = (tDelay+dt):dt:(tDelay+dt*size(S,2));
% dz = 0.05;
% Lz = (size(S,1)-1).*dz;
% ZZ_ = [0:dz:Lz];
X = int16((xLim(2)-xLim(1))/dx+1);
Y = int16((yLim(2)-yLim(1))/dy+1);

%% Extracting region of interest
% Slice_T1 = 9.8e-6; Window = 11.5e-6;
% Slice_T1 = 19.6e-6; Window = 4e-6;
% % Slice_T1 = 20e-6; Window = 23e-6;
Slice_T1 = (1.625e-6).*2; Slice_T2 = (3.25e-6).*2; 
Window = Slice_T2 - Slice_T1;

% Slice_T1 = 16.2e-6; Window = 2e-6;
% Slice_T1 = 1.5e-6; Window = 0.5e-6;
% Slice_T1 = 3.0e-6; Window = 1e-6;
% Slice_T1 = 10e-6; Window = 2e-6; % Oil2Line
% Slice_T1 = 20e-6; Window = 4e-6; % Oil2Line
MIP_XYZ = 0; % Slice 0. for all, 1. XZ, 2. YZ, 3. XY
% Slice_T1_End=11.8e-6; Slice_T1_Start=9.8e-6;
% Slice_T2_Start=19.6e-6; Slice_T2_End=23.6e-6;
% Slice_T2_Start=19e-6; Slice_T2_End=23e-6;
Slice_T1_Start=1.5e-6;  Slice_T1_End=3.25e-6;  % WOiLine
Slice_T2_Start=3.25e-6; Slice_T2_End=6.5e-6;
% Slice_T1_End=12e-6; Slice_T1_Start=10e-6; % Oil2Line
% Slice_T2_Start=20e-6; Slice_T2_End=24e-6;
% Slice_T1_End=2e-6; Slice_T1_Start=1.5e-6; % 100MHz
% Slice_T2_Start=3e-6; Slice_T2_End=4e-6;

if is_rsom==1
    if Slice_T2 <= Slice_T1_End
        IS_TA = 1;
        SS = double(S(:,((tt_>=Slice_T1_Start)&(tt_<=Slice_T1_End)))).* InputRange ./ 2^15; % mV
        tt_ = tt_((tt_>=Slice_T1_Start)&(tt_<=Slice_T1_End));
    elseif Slice_T1 >= Slice_T2_Start
        IS_TA = 0;
        SS = double(S(:,((tt_>=Slice_T2_Start)&(tt_<=Slice_T2_End)))).* InputRange ./ 2^15; % mV
        tt_ = tt_((tt_>=Slice_T2_Start)&(tt_<=Slice_T2_End));
        tDelay=trigDelay*1/Fs;
    end
    SS=double(reshape(SS,X,Y,size(SS,2)));
    SS = SS(1:2:end,1:2:end,:);
    [X Y] = size(SS);
    SS=reshape(SS,X*Y,size(SS,3));
    dx=dx*2;
elseif is_rsom==0
    if Slice_T2 <= Slice_T1_End
        IS_TA = 1;
        SS = double(S(:,((tt_>=Slice_T1_Start)&(tt_<=Slice_T1_End)))).* 1000; % mV
        tt_ = tt_((tt_>=Slice_T1_Start)&(tt_<=Slice_T1_End));
    elseif Slice_T1 >= Slice_T2_Start
        IS_TA = 0;
        SS = double(S(:,((tt_>=Slice_T2_Start)&(tt_<=Slice_T2_End)))).* 1000; % mV
        tt_ = tt_((tt_>=Slice_T2_Start)&(tt_<=Slice_T2_End));
        tDelay = tDelay*2;
    end
%     SS = double(S) .* 1000; % mV
end
% 
Delta_tt_ = max(tt_)-min(tt_);

tic

% %%  Denoising
%     for i=1:size(SS,1)
% %         SS(i,:) = denoising(SS(i,:),0.618, round(log2(length(tt_)).*0.382));
% %         SS(i,:) = denoising(SS(i,:),max(SS(:)).*0.05, floor(log2(length(tt_)).*1));
%         SS(i,:) = denoising(SS(i,:),max(SS(:))./50, 12);
% %         [SS(i,:), E, status] = tvdip(SS(i,:),tvdiplmax(SS(i,:))*5e-3,0,1e-3,100);
%     end
% 
% % Bandpass
    SS = filtS(SS,dt,min(dx, dy),2);
%     SS=double(reshape(SS,X,Y,size(SS,2)));
% toc

%% SAFT recon
if ~IS_TA    % title('US B scan');   
    Window=Window/2;  
    Delta_tt_ = Delta_tt_/2;
    tDelay = tDelay/2;
    ind = [1:1:size(SS,2)]';
    SS = (sparse(ceil(ind/2),ind,1)*SS')'; % downsampling the US sequence to be alike TA sequence
end
% Add path
addpath('C:\Users\Yuanhui\Matlab\TAM_hybrid\SAFT_recon');
addpath('C:\Users\Yuanhui\Matlab\TAM_hybrid\SAFT_recon\FieldII\Field_II_PC7');
addpath('C:\Users\Yuanhui\Matlab\TAM_hybrid\SAFT_recon\FieldII\usefullFunctions');
addpath('C:\Users\Yuanhui\Matlab\TAM_hybrid\SAFT_recon\FieldII');
% Load parameters: 
myReconSetup;
% myReconSetup100MHz;
% File name:
% folder_name = 'C:\Users\Chucheng\Documents\MATLAB\TAM\DATA4T';
% fileParams.data  = [folder_name, '\'];
% fileParams.dataName  = '201702071932_TAM_WNOil2Line50_4dayFishEgg_live-dead_TA_V3330_TAM_81-182us_AVG1024_270';                                            
fileParams.recon = [fileParams.data fileParams.dataName '\'];                                                                                                                         
fileParams.main  = [fileParams.data fileParams.dataName '\'];
fileParams.dataFolder = '';

isDirExist(fileParams.recon);

% Look for the files to reconstruct inside the measurement folder:
files  = dir([fileParams.data fileParams.dataName '.mat']);
nFiles = length(files);
fprintf('There are %i files to reconstruct!\n',nFiles);
pause(0.1);


% Choose which frequency band to reconstruct
RAW_flag = 1;
AF_flag = 0;
LF_flag = 0;
HF_flag = 0;

for ii = 1:nFiles
    %=====Choose the right file:
    fprintf('%i....',ii);
    
    reconParams      = det50.reconParams;
    transducerParams = det50.transducerParams;
       
    %=====All frequencies: without SAFT
    if RAW_flag 
        fileParams.reconExt = 'RAW';% File Extension
        reconParams.f_BP = [0 Fs];
        R=medfilt3(double(reshape(SS,X,Y,size(SS,2))));
        [X, Y, Z] = size(R);
        nGrid = max([X Y (X-1)*dx*1e3/reconParams.GRID_DS+1 (Y-1)*dy*1e3/reconParams.GRID_DS+1]);
        R = imresize(R,[(X-1)*dx*1e3/reconParams.GRID_DS+1 (Y-1)*dy*1e3/reconParams.GRID_DS+1],'bicubic');
        [X, Y, Z] = size(R);
%         R = imresize(abs(hilbert(imresize(R,[X*Y Z]))),[X Y Z]);
        dt = Delta_tt_ ./ Z; tt_ = tDelay + [0:Z-1].*dt;
        show_data;
        if is_Tiff==1     myTiff(ROI,fileParams,IS_TA);   end % % Save Tiff
    end
    
    %=====All frequencies:
    if AF_flag
        fileParams.reconExt = 'AF';% File Extension
        reconParams.f_BP = reconParams.f_BPA;
        % Now reconstruct:
%         Recon3Dnew_mo(fileParams, reconParams, transducerParams);
        R = double(myRecon3Dnew(SS, fileParams, reconParams, transducerParams));
        R = -medfilt3(double(R));   % SAFT reverse the phase
        tt_ = Slice_T1+[1:size(R,3)].*Window./size(R,3);
        [X, Y, Z] = size(R);
%         nGrid = max([X Y (X-1)*min([dx dy dz])*1e3/reconParams.GRID_DS+1 (Y-1)*min([dx dy dz])*1e3/reconParams.GRID_DS+1]);
%         R = imresize(R,[(X-1)*dx*1e3/reconParams.GRID_DS+1 (Y-1)*dy*1e3/reconParams.GRID_DS+1],'bicubic');
%         [X Y Z] = size(R);
        dt = Delta_tt_ ./ Z; tt_ = tDelay + [0:Z-1].*dt;
        show_data;
        if is_Tiff==1     myTiff(ROI,fileParams,IS_TA);   end % % Save Tiff
    end
    
    %=====Low frequencies:
    if LF_flag
        fileParams.reconExt = 'LF';% File Extension
        reconParams.f_BP = reconParams.f_BPL;
        % Now reconstruct:
        R = double(myRecon3Dnew(SS, fileParams, reconParams, transducerParams));
        R = -medfilt3(double(R));   % SAFT reverse the phase  
        [X, Y, Z] = size(R);
%         nGrid = max([X Y (X-1)*min([dx dy dz])*1e3/reconParams.GRID_DS+1 (Y-1)*min([dx dy dz])*1e3/reconParams.GRID_DS+1]);
%         R = imresize(R,[(X-1)*dx*1e3/reconParams.GRID_DS+1 (Y-1)*dy*1e3/reconParams.GRID_DS+1],'bicubic');
%         [X Y Z] = size(R);
        dt = Delta_tt_ ./ Z; tt_ = tDelay + [0:Z-1].*dt;
        show_data;
        if is_Tiff==1     myTiff(ROI,fileParams,IS_TA);   end % % Save Tiff
    end
    
    %=====High frequencies:
    if HF_flag
        fileParams.reconExt = 'HF';% File Extension
        reconParams.f_BP = reconParams.f_BPH;
        % Now reconstruct:
        R = double(myRecon3Dnew(SS, fileParams, reconParams, transducerParams));
        R = medfilt3(double(R));   % SAFT reverse the phase   
        [X, Y, Z] = size(R);
%         nGrid = max([X Y (X-1)*min([dx dy dz])*1e3/reconParams.GRID_DS+1 (Y-1)*min([dx dy dz])*1e3/reconParams.GRID_DS+1]);
%         R = imresize(R,[(X-1)*dx*1e3/reconParams.GRID_DS+1 (Y-1)*dy*1e3/reconParams.GRID_DS+1],'bicubic');
%         [X Y Z] = size(R);
        dt = Delta_tt_ ./ Z; tt_ = tDelay + [0:Z-1].*dt;
        show_data;
        if is_Tiff==1     myTiff(ROI,fileParams,IS_TA);   end % % Save Tiff
    end
   
%     close all;
end
% ROI=medfilt3(double(reshape(ROI,X,Y,size(ROI,2))));

