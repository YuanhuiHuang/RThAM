function iatfclose(fid)
% IATFCLOSE Wrapper around FCLOSE for custom files.
%
%    IATFCLOSE(FID) closes the file specified by FID.  FID should be a
%    value returned by IATFOPEN.
%
%    See also IATFOPEN.

% DT 4/2004
% Copyright 2004 The Mathworks, Inc.

% Close the file.
status = fclose(fid.id);

if (status == -1)
    error('imaq:filelogging:fileclose', 'Error while closing the log file.');
end