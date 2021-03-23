function iatLoggingCallback(obj, event, filename);
% IATLOGGINGCALLBACK Callback function for the custom logging demo.
%
%    IATLOGGINGCALLBACK is the callback function for the Image Acquisition
%    Toolbox's custom file format logging demo.  The function
%    IATCONFIGURELOGGING sets the VIDEOINPUT object OBJ's StartFcn,
%    StopFcn, and FramesAcquiredFcn callbacks to IATLOGGINGCALLBACK.
%
%    IATLOGGINGCALLBACK uses the EVENT structure passed in to determine
%    which callback should be executed.
%
%    See also IATCONFIGURELOGGING, VIDEOINPUT.

% DT 4/2004
% Copyright 2004 The MathWorks, Inc.

switch event.Type
    case 'Start'
        localStartCallback(obj, filename);
    case 'FramesAcquired'
        localFramesAcquiredCallback(obj)
    case 'Stop'
        localStopCallback(obj)
end

function localStartCallback(obj, filename)
% LOCALSTARTCALLBACK StartFcn callback for custom format logging.
%
%    LOCALSTARTCALLBACK is configured by CONFIGURELOGGING to be a VIDEOINPUT
%    object's StartFcn callback.  It handles creating the log file and then
%    writing the header information to that file.
%
%    See also IATCONFIGURELOGGING, VIDEOINPUT.

% Open the file.
fid = fopen(filename, 'wb');

% FOPEN returns -1 if it can not open the file.
if (fid == -1)
    error('imaq:filelogging:fileopen', ...
        ['Can not open file ' filename ' for writing.']);
end

% Store the file id in the object's user data field so that it will be
% available to the other callbacks.
obj.UserData = fid;

% Store the size of each frame.  This is necessary so that FREAD knows how
% many bytes to read.
roi = obj.ROIPosition;
rows = roi(4);
columns = roi(3);
bands = obj.NumberOfBands;

% Write the values out so that they are the first three values in the file.
fwrite(fid, rows, 'double');
fwrite(fid, columns, 'double');
fwrite(fid, bands, 'double');

function localFramesAcquiredCallback(obj)
% LOCALFRAMESACQUIREDCALLBACK FramesAcquiredFcn callback for custom format logging.
%
%    WRITEIATFRAME is configured by IATCONFIGURELOGGING to be a VIDEOINPUT
%    object's FramesAcquiredFcn callback.  It retrieves a frame with the
%    object's GETDATA method and then writes it to the file created by the
%    LOCALSTARTCALLBACK method.  Data is written in UINT8 format.
%
%    See also IATCONFIGURELOGGING, GETDATA, LOCALSTARTCALLBACK, VIDEOINPUT.

% Retrieve the file id for the current file.
fid = obj.UserData;
disp(num2str(islogging(obj)))
% Write the frame.
fwrite(fid, getdata(obj, 1), 'uint16');

function localStopCallback(obj)
% LOCALSTOPCALLBACK StopFcn callback for custom format logging.
%
%    LOCALSTOPCALLBACK is configured by IATCONFIGURELOGGING to be a VIDEOINPUT
%    object's StopFcn callback.  It closes the file created by the
%    LOCALSTARTCALLBACK function.
%
%    See also IATCONFIGURELOGGING, LOCALSTARTCALLBACK, VIDEOINPUT.

% Retreive the file id of the file being written to.
fid = obj.UserData;

% Close the file.
status = fclose(fid);

if (status == -1)
    error('imaq:filelogging:fileclose', 'Error while closing the log file.');
end