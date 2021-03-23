% This function checks the status of given axis
% yuanhui 20190326
function Status = piOnTargetState(pi)
fprintf(pi,'ONT? 1');
StatusStr = fscanf(pi, '%c');
IndexOfAnswer    = strfind(StatusStr, '=');
Status = str2double(StatusStr(IndexOfAnswer+1:end));

