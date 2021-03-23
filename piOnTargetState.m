% This function checks the status of given axis
% yuanhui 20190326
function State = piOnTargetState(piStage)
fprintf(piStage,'ONT? 1');
StatusStr = fscanf(piStage, '%c');
IndexOfAnswer    = strfind(StatusStr, '=');
State1 = str2double(StatusStr(IndexOfAnswer+1:end));
% 
% fprintf(piStage.Y,'ONT? 1');
% StatusStr = fscanf(piStage.Y, '%c');
% IndexOfAnswer    = strfind(StatusStr, '=');
% State2 = str2double(StatusStr(IndexOfAnswer+1:end));

% State = State1 && State2;
State = State1;

