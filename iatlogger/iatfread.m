function frame = iatfread(fid);
% IATFREAD Wrapper around FREAD for custom files.
%
%    FRAME = IATFREAD(FID) returns the next image frame in the file
%    specified by FID.  FID should be the value returned by IATFOPEN.  If
%    there are no more frames in the file, IATFREAD returns empty.
%
%    See also IATFOPEN.

% DT 4/2004
% Copyright 2004 The Mathworks, Inc.

% Determine the number of elements to read.
numelements = fid.rows * fid.columns * fid.bands;

% Read in the data as a UINT8 values.
data = fread(fid.id, numelements, 'uint8=>uint8');

if (feof(fid.id))
    % If the read hit the end of file marker, return empty.
    frame = [];
else
    % If the data returned was valid data, reshape it since fread returns
    % all of the data as a column vector.
    frame = reshape(data, fid.rows, fid.columns, fid.bands);
end