% This function checks the status of given axis
% yuanhui 20190326
% CTO <TrigOutID> <CTOPam> <Value>
% <CTOPam> parameter IDs available for C-867:
% 1 = TriggerStep 
% 2 = Axis 
% 3 = TriggerMode 
% 7 = Polarity 
% 8 = StartThreshold 
% 9 = StopThreshold 
% 10 = TriggerPosition
% TriggerMode Options
% 0 = "Position Distance";
% 2 = "OnTarget";
% 5 = "MotionError";
% 6 = "InMotion";
% 7 = "Position+Offset";

function ret = piConfigTrigOut(piStage, TrigOutID)
% fprintf(PI.X,'TRO 1 0');
if nargin < 2
    TrigOutID = 1;
end
fprintf(piStage,'CTO %s 2 1', num2str(TrigOutID));
fprintf(piStage,'CTO %s 3 6', num2str(TrigOutID)); % Trigger when in Motion 6; OnTarget 2
fprintf(piStage,'CTO %s 7 1', num2str(TrigOutID));
fprintf(piStage,'CTO %s 1 0', num2str(TrigOutID)); % mm
fprintf(piStage,'CTO %s 8 214748.3647', num2str(TrigOutID));
fprintf(piStage,'CTO %s 9 214748.3647', num2str(TrigOutID));
fprintf(piStage,'CTO %s 10 0', num2str(TrigOutID));
% piEnableTrigOut(piStage, 1, 1);
% piEnableTrigOut(piStage, 0, 2);
% piEnableTrigOut(piStage, 0, 3);
% piEnableTrigOut(piStage, 0, 4);

ret = 1;