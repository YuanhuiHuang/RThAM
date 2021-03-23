function handle = gageInit()
addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK');
addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\Adv');
addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\CsMl');
addpath('C:\Program Files (x86)\Gage\CompuScope\CompuScope MATLAB SDK\Main');
systems = CsMl_Initialize;                                                           % Initialize the DAQ drivers
CsMl_ErrorHandler(systems);

[ret, handle] = CsMl_GetSystem;                                                      % Get DAQ system type identifier [integer]
CsMl_ErrorHandler(ret);

[ret, sysinfo] = CsMl_GetSystemInfo(handle);                                         % Get DAQ system info

s = sprintf('----- Board name: %s ----- \n', sysinfo.BoardName);
disp(s);

[ret] = CsMl_ForceCalibration(handle);
disp(['Force Calibration Error occurred ' num2str(ret)]);
    

% Setup(handle);                                                                     % Set acquisition, channel and trigger parameters

% CsMl_ResetTimeStamp(handle);                                                       % Reset time stamp counter

% ret = CsMl_Commit(handle);                                                         % Pass parameters to DAQ system
% CsMl_ErrorHandler(ret, 1, handle);

end