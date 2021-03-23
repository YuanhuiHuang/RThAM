function Pm_startCallback(obj)
% % LOCALSTARTCALLBACK StartFcn callback for custom format logging.
% %
% %    LOCALSTARTCALLBACK is configured by CONFIGURELOGGING to be a VIDEOINPUT
% %    object's StartFcn callback.  It handles creating the log file and then
% %    writing the header information to that file.
% %
% %    See also IATCONFIGURELOGGING, VIDEOINPUT.
% 
% % Open the file.
% fid = fopen(filename, 'wb');
% 
% % FOPEN returns -1 if it can not open the file.
% if (fid == -1)
%     error('imaq:filelogging:fileopen', ...
%         ['Can not open file ' filename ' for writing.']);
% end
% 
% % Store the file id in the object's user data field so that it will be
% % available to the other callbacks.
% obj.UserData = fid;
% 
% % Store the size of each frame.  This is necessary so that FREAD knows how
% % many bytes to read.
% roi = obj.ROIPosition;
% rows = roi(4);
% columns = roi(3);
% bands = obj.NumberOfBands;
% 
% % Write the values out so that they are the first three values in the file.
% fwrite(fid, rows, 'double');
% fwrite(fid, columns, 'double');
% fwrite(fid, bands, 'double');
% %

%%
% % Store the file id in the object's user data field so that it will be
% % available to the other callbacks.
obj.UserData = tic;