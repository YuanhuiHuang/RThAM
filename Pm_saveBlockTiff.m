%% write to TIFF
% % if (PmVid.FramesAvailable)
% %     [PmRaw, PmTimeStamp, PmMetaData] = getdata(PmVid,PmVid.FramesAvailable); 
% % end % get data to workspace only after the acquisition is finished.
% % % figure(911), imagesc(mean(PmRaw,4)); axis image; colorbar 
% % % drawnow;     % update figure window
% % save([TiffSavingPath datestr(now,'yyyymmdd') '_' SaveMeasName '_Meta.mat'],'PmTimeStamp', 'PmMetaData');

% % Step 10 - write to TIFF
addpath('C:\Users\yuanhui\MATLAB\TAM\saveastiff_4.4');
Tiffoptions.message   = true;
options.color = false;
Tiffoptions.append    = true;
Tiffoptions.overwrite = true;
Tiffoptions.big       = true;
hWaitbar = waitbar(0,'Please wait...');
nFramesStack = 500 ; % 500 frames (4 GB) per block


clear PmMetaData;
nFramesAvailable = PmVid.FramesAvailable;
PmTimeStamp = zeros(nFramesAvailable, 1);
PmMetaData(nFramesAvailable,1) = struct('AbsTime', [0,0,0,0,0,0.0], ...
                'FrameNumber', 0, 'RelativeFrame', 0, 'TriggerIndex', 0);
for idx=1:nFramesStack:nFramesAvailable
    if idx+nFramesStack > nFramesAvailable
        nFramesStack = nFramesAvailable - idx +1;
    end
    TiffFileName = [TiffSavingPath 'S_PM_stack',num2str(idx) 'to' num2str(idx+nFramesStack-1) '.tif'];
    [PmRaw, PmTimeStamp(idx:idx+nFramesStack-1), PmMetaData(idx:idx+nFramesStack-1)] = getdata(PmVid,nFramesStack);
    waitbar(idx/nFramesAvailable,hWaitbar, ['Saving to disk ' num2str(idx) ' of ' num2str(nFramesAvailable) ' frames']);
    saveastiff(squeeze(PmRaw), TiffFileName, Tiffoptions);
end
close(hWaitbar)


save([TiffSavingPath datestr(now,'yyyymmdd') '_'...
    SaveMeasName '_' num2str(PmSrcInfo.Exposure) PmSrcInfo.ExpRes '_'...
    num2str(round(1./mean(diff(PmTimeStamp)))) 'fps' '_Meta.mat'],...
    'PmTimeStamp', 'PmMetaData');