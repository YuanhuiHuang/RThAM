function [currentXPosition, currentYPosition] = genPausePi(positionTarget, currentPosition, piStageSpeed, ticTimer)
% genPausePi(positionTarget, currentPosition, piStageSpeed)
% Generates a pause based on distance between positionTarget and 
% currentPosition to give stage time to move to target position.
%
% Example: genPausePi(10, 0, 1) will create a 10s pause to move from 0mm to 
% 10mm with 1mm/s
% 
% genPausePi(positionTarget, currentPosition, piStageSpeed, ticTimer)
% pause for the time specified via ticTimer, where ticTimer must be aquired
% via: ticTimer = tic as the correspondic toc(ticTimer) is used in the code
% 
% This function only creates a pause based on the values handed to it. If 
% the values are not correct (i.e. acutal speed is different from
% piStageSpeed) then the created pause will not be long enough to ensure
% the target position hast been reached. 
% 
% Ver. 1.0 - M. Omar, 2014/08/11
% #toDo: use 'ONT?' command instead of calculating required time...
%
% See also 

dt = abs(positionTarget-currentPosition)/piStageSpeed;
dt = max(dt,0.01);

pFactor = 25; % 25; % The minimum pause will be 1/p-Factor

dt = ceil(dt*pFactor)/pFactor;

if dt < 10e-3
    currentXPosition = positionTarget(1);
    currentYPosition = positionTarget(2);
    return;
end

if nargin == 4  % Number of Input Arguments
    t2 = toc(ticTimer);
    
    if dt > t2
        pause(dt-t2);
    end
else
    pause(dt);
end

currentXPosition = positionTarget(1);
currentYPosition = positionTarget(2);

end
