function piMoveAbs(piStage, position)
%piMoveAbs(piStage, position) -  Set PI stage target position
% 
% Servo mode must be switched on for the commanded 
% axis prior to using this command (closed-loop operation).
%
% The target position must be inside the soft limits.
% Use TMN? and TMX? to ask for the current valid soft limits.
% 
% During a motion, a new motion command resets the target to a new 
% value and the old one may never be reached. 
% 
% Example: piMoveAbs(piStage, 20);
% sends stage to absolute position 20
%
% Ver. 1.0 - M. Omar, 2014/08/11
% #toDo: unify with pi2xMoveAbs
%
% See also pi2xMoveAbs

if nargin == 2
    string = sprintf('MOV 1 %g', position);
    
    fprintf(piStage, string);
else
    error 'not enough input parameters! \n';
end


% Set Target Position