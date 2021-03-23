function fid = iatfopen(filename);
% IATFOPEN Wrapper around FOPEN for custom files.
%
%    IATFOPEN is designed to be a wrapper around FOPEN for reading files
%    created by using the CONFIGURELOGGING function to create a log file
%    for VIDEOINPUT objects.
%
%    FID = IATFOPEN(FILENAME) where FILENAME is the name of the file to
%    read returns a struct that should be passed to IATFREAD to retreive
%    the next frame in the file.
%
%    To close the file, use the IATFCLOSE function.
%
%    See also FOPEN, CONFIGURELOGGING, IATFREAD, IATFCLOSE.

% DT 4/2004
% Copyright 2004 The Mathworks, Inc.

fid.id = fopen(filename, 'rb');

% FOPEN returns -1 if it can not open the file.
if (fid.id == -1)
    error('imaq:filelogging:fileopen', ...
        ['Can not open file ' filename ' for reading.']);
end

% Determine the size of the image.
fid.rows = fread(fid.id, 1, 'double');
fid.columns = fread(fid.id, 1, 'double');
fid.bands = fread(fid.id, 1, 'double');