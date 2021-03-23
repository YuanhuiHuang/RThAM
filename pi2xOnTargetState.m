% This function checks the status of given axis
% yuanhui 20190326
function State = pi2xOnTargetState(piStage)
fprintf(piStage.X,'ONT? 1');
StatusStr = fscanf(piStage.X, '%c');
IndexOfAnswer    = strfind(StatusStr, '=');
State1 = str2double(StatusStr(IndexOfAnswer+1:end));
% 
fprintf(piStage.Y,'ONT? 1');
StatusStr = fscanf(piStage.Y, '%c');
IndexOfAnswer    = strfind(StatusStr, '=');
State2 = str2double(StatusStr(IndexOfAnswer+1:end));

State = State1 && State2;
% State = State1;


