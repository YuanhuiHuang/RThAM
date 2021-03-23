DAQIni = 0;

setPath;                                                                             % Set path to DAQ system files

if isempty(instrfind)
    pi = pi2xStart();
    pi2xOpen(pi);                                                                    % Open connection to stage controllers
end
    
if DAQIni == 1
    DAQ = gageInit();                                                                % Initialize the DAQ system
end

clear DAQIni;