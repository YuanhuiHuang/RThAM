function ret = piEnableTrigOut(piStage, EnableState, TrigOutID)
%%
% TRO (Set Trigger Output State)
% Description:
% Enables or disables the trigger output conditions which were set with CTO (p. 100) for the given trigger output line.
% Format:
% TRO {<TrigOutID> <TrigMode>}
% Arguments:
% <TrigOutID> is one digital output line of the controller, see below for details
% <TrigMode> can have the following values: 0 = trigger output disabled 1 = trigger output enabled
if nargin < 3
    TrigOutID = 2; % default using TrigOutID 1, pin 5. TrigOutID 1-4 is Digital output line 5-8 of mini Din
end
CommandStr = sprintf('TRO %s %s', num2str(TrigOutID), num2str(EnableState));
fprintf(piStage,CommandStr);   % Trigger output enable

ret = 1;