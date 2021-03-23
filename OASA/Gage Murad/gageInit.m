function handle = gageInit()

systems = CsMl_Initialize;                                                           % Initialize the DAQ system
CsMl_ErrorHandler(systems);

[ret, handle] = CsMl_GetSystem;                                                      % Get DAQ system type identifier
CsMl_ErrorHandler(ret);

[ret, sysinfo] = CsMl_GetSystemInfo(handle);                                         % Get DAQ system info

s = sprintf('----- Board name: %s ----- \n', sysinfo.BoardName);
disp(s);

sysinfo


% Setup(handle);                                                                     % Set acquisition, channel and trigger parameters

% CsMl_ResetTimeStamp(handle);                                                       % Reset time stamp counter

% ret = CsMl_Commit(handle);                                                         % Pass parameters to DAQ system
% CsMl_ErrorHandler(ret, 1, handle);

end