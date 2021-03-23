function writeIATFrame(obj, event);
% WRITEIATFRAME FramesAcquiredFcn callback for custom format logging.
%
%    WRITEIATFRAME is configured by CONFIGURELOGGING to be a VIDEOINPUT
%    object's FramesAcquiredFcn callback.  It retrieves a frame with the
%    object's GETDATA method and then writes it to the file created by the
%    STARTAILOGGING method.  Data is written in UINT8 format.
%
%    See also CONFIGURELOGGING, GETDATA, STARTAILOGGING, VIDEOINPUT.

% DT 4/2004
% Copyright 2004 The Mathworks, Inc.

% Retrieve the file id for the current file.
fid = obj.UserData;

% Write the frame.
fwrite(fid, getdata(obj, 1), 'uint8');