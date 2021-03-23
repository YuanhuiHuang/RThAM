function Return = Pm_close(PmVid)
%% Step 5.2
stoppreview(PmVid);
%% Step 5.3
closepreview(PmVid);

%% Step 8 - Stop acquisition MANNUALLY. Don't need if specified frames*triggers
stop(PmVid)
%% Step 11 - close devices.
% delete(PMvid1)
delete(imaqfind)
close(gcf)
clear PmVid

% %% Step 12 - remove driver for Prime sCMOS
% imaqregister('C:\Program Files\Photometrics\PMQI-MatlabAdaptor\Utilities\MatlabAdaptor\PMImaq_2017b.dll', 'unregister')

Return = 1;
