function saveName = isFileExisting(saveName,savePath)
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
