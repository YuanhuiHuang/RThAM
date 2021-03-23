function Copper_Max = Copper_Nolinearity(dataName,IS_TA)
%% 20180622 Nolinearity
% This is trial on wavelet-based denoising 
% Yuanhui Huang 
% 20180509
%%
% clear all; %close all;
cd C:\Users\yuanhui\MATLAB\TAM;
folder_name = 'C:\Users\yuanhui\MATLAB\TAM\Data\Data_Storage\';
% folder_name = 'C:\Users\yuanhui\MATLAB\TAM\Data\';
fileParams.dataName = dataName;
% fileParams.dataName = '201806022040_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_9.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315';
% fileParams.dataName = '201604252007_TAM_OLine25_Yeast_tube3_surface_5kV_US_V3330_TAM_81-88us_AVG500_210';
% fileParams.dataName = '201806022040_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_9.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315';
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
% Slice_T1 = (8.8e-6).*1; Slice_T2 = (9.2e-6).*1; 
if IS_TA == 1
    Slice_T1 = (7e-6).*1; 
    Slice_T2 = (9.2e-6).*1; 
elseif IS_TA == 0
    Slice_T1 = (7e-6).*2; 
    Slice_T2 = (9.2e-6).*2; 
end
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
Slice_T1_Start=7e-6;  Slice_T1_End=10.5e-6;  % WOiLine
Slice_T2_Start=14e-6; Slice_T2_End=21e-6;
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
if IS_TA == 1
%     figure,imagesc(SS(10:50,650:720));
    Copper_Max = max(max(abs(SS(10:50,650:720))));
% figure,imagesc(SS(27:46,660:730)); %% TA
elseif IS_TA == 0
%     figure,imagesc(SS(:,1300:1500)); %% US
    Copper_Max = max(max(abs(SS(:,1300:1500))));
end
