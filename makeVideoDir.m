function VideoSavePath = makeVideoDir(FolderPath, ShortOrLongStr, SaveMeasName)
%% StreamSavingPath = makeVideoFolder(PMvid_src1_Info.StreamSavingPath, 'Short', 'GFP10xFish10dpm_'); % 'Short' video 
%% v1.0 yuanhui 20190220
HOMEPATH = pwd;
datum = datestr(now,'yyyymmddHHMMSS');

if nargin == 0
    FolderPath = 'C:\Pictures\';
end

savePath = [FolderPath,datum];
% if ~isdir(savePath)
%     mkdir(savePath);
% %     cd(savePath);
% %     cd(HOMEPATH);    
% end
VideoSavePath = FolderPath;

if nargin == 3
        
% switch lower(ShortOrLongStr)
%     case 'short' % short but fast fps videos
%         StrPattern = 'vShort';
%     case 'long' % short but fast fps videos
%         StrPattern = 'vLong';
%     otherwise
%         disp('Unexpected acquisition mode!')
% end

% Listngs = dir(savePath);
% nExistingVideos = 0;
% for idx=1:length(Listngs)
%     nExistingVideos = nExistingVideos + (~isempty(strfind(Listngs(idx).name,StrPattern)));
% end
% if (nExistingVideos == 0) || (length((dir([savePath '_' StrPattern '_' SaveMeasName '_' num2str(nExistingVideos) '\' ]))) > 2)
%     nExistingVideos = nExistingVideos + 1; 
%     VideoSavePath = [savePath '_' StrPattern '_' SaveMeasName '_' num2str(nExistingVideos) '\' ];
% else
%     VideoSavePath = [savePath '_' StrPattern '_' SaveMeasName '_' num2str(nExistingVideos) '\' ];
% end
VideoSavePath = [savePath '_' SaveMeasName '\' ];

if ~isdir(VideoSavePath)
    mkdir(VideoSavePath);
end
% cd(VideoSavePath);
% cd(HOMEPATH);
end
