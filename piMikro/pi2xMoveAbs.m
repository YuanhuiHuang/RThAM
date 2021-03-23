function pi2xMoveAbs(piStage, x, y)
%pi2xMoveAbs(piStage, x, y)- move stage "piStage" to position x and y
%
% The target position must be inside the position limits.
% 
% During a motion, a new motion command resets the target to a new 
% value and the old one may never be reached. 
% 
% Example: piSetVel(piStage, 25, 25);
% sends stage to absolute position x = 25mm and y = 25mm
%
% Ver. 1.0 - M. Omar, 2014/08/11
% #toDo: 
% - unify with piMoveAbs
% - Use TMN? and TMX? to ask for the current valid position limits and trow
% error if values are outside of soft limits
%
% See also pi2xMoveAbs

% Don't move unless the position is within the limits of the motor.
if x <= 42 && x >= 0
    piMoveAbs(piStage.X, x);
end

if y <= 50 && y >= 0
    piMoveAbs(piStage.Y, y);
end

end
