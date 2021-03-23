function iatconfigureLogging(obj, filename)
% IATCONFIGURELOGGING Configures a VIDEOINPUT object for custom file logging.
%
%    IATCONFIGURELOGGING(OBJ, FILENAME) configures the VIDEOINPUT object OBJ
%    to log data to the file FILENAME.  IATCONFIGURELOGGING only configures
%    the properties necessary to log the data to disk.
%
%    The file format is very simple, the image size is written at the start
%    of the file.  After that, frames are written sequentially as UINT8
%    data.
%
%    To read the resulting file, use the IATFOPEN and IATFREAD commands.
%
%    See also VIDEOINPUT, IATFOPEN, IATFCLOSE.

% DT 4/2004
% Copyright 2004 The Mathworks, Inc.

obj.LoggingMode = 'memory';
obj.StartFcn = {@iatLoggingCallback, filename};
obj.StopFcn = @iatLoggingCallback;
obj.FramesAcquiredFcn = @iatLoggingCallback;
obj.FramesAcquiredFcnCount = 1;