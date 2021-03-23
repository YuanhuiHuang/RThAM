function position = piGetPosition(piStage)
%position = piGetPosition(piStage) - get current position of axis specified 
% with piStage
% 
% Ver. 1.0 - M. Omar, 2014/08/11
% #ToDo: unify pi2xGetPosition & piGetPosition using varargin
%
% See also pi2xGetPosition

fprintf(piStage, 'POS? 1');

position = fscanf(piStage, '%c');
place    = strfind(position, '=');
position = str2double(position(place+1:end));
end