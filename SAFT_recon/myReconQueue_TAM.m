function myReconQueue_TAM()
%% Load parameters: 
reconSetup;
folder_name = 'C:\Users\Chucheng\Documents\MATLAB\TAM\DATA4T';

    

%% File name:
fileParams.data  = [folder_name, '\'];
    fileParams.dataName  = '201702071932_TAM_WNOil2Line50_4dayFishEgg_live-dead_TA_V3330_TAM_81-182us_AVG1024_270';                                            
fileParams.recon = [fileParams.data 'Recons\'];                                                                                                                         
fileParams.main  = fileParams.data;
fileParams.dataFolder = '';

isDirExist(fileParams.recon);

%Look for the files to reconstruct inside the measurement folder:
files  = dir([fileParams.data '*TAM*.mat']);
nFiles = length(files);
fprintf('There are %i files to reconstruct!\n',nFiles);
pause(0.1);

% Choose which frequency band to reconstruct
AF_flag = 1;
HF_flag = 0;
LF_flag = 0;

for ii = 1:nFiles
    %=====Choose the right file:
    fprintf('%i....',ii);
    
    reconParams      = det50.reconParams;
    transducerParams = det50.transducerParams;
    
    
    if AF_flag
        fileParams.reconExt = '';% File Extension
        reconParams.f_BP = reconParams.f_BPA;
        % Now reconstruct:
%         myRecon3Dnew_mo(fileParams, reconParams, transducerParams);
        myRecon3Dnew(fileParams, reconParams, transducerParams);
    end
    
    %=====High frequencies:
    if HF_flag
        fileParams.reconExt = 'HF';% File Extension
        reconParams.f_BP = reconParams.f_BPH;
        % Now reconstruct:
        myRecon3Dnew(fileParams, reconParams, transducerParams);
    end
    
    %=====Low frequencies:
    if LF_flag
        fileParams.reconExt = 'LF';% File Extension
        reconParams.f_BP = reconParams.f_BPL;
        % Now reconstruct:
        myRecon3Dnew(fileParams, reconParams, transducerParams);
    end
    
%     close all;
end

end
