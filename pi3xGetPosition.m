function [x, y, z] = pi3xGetPosition(piStage)
%pi2xGetPosition(piStage) - get current position of x- and y-axi
% 
% Ver. 1.0 - M. Omar, 2014/08/11
% #ToDo: unify pi2xGetPosition & piGetPosition using varargin
%
% See also piGetPosition

x = piGetPosition(piStage.X);
y = piGetPosition(piStage.Y);
z = piGetPosition(piStage.Z);

end