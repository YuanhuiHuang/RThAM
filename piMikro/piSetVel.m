function piSetVel(piStage, velocity)
%piSetVel(piStage, velocity)  Set the speed (mm/s) of the PI stage specified by piStage
% 
% Example: piSetVel(piStage, 20);
% sets the speed to 20mm/s
%
% Ver. 1.0 - M. Omar, 2014/08/11
%
% See also piSetAcc, piGetVel, piGetAcc, piGetDec


str = sprintf('VEL 1 %g', velocity);

fprintf(piStage, str);
end