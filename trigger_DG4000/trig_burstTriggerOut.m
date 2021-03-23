function Return = trig_burstTriggerOut(trig,OFFOrPOSitiveOrNEGative,nChannel)
%% v1.0 yuanhui 20190209
% OFF|POSitive|NEGative
% This command is only available when internal or manual trigger source is selected.

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':BURSt:TRIGger:TRIGOut'];
fwrite(trig,[Command ' ' num2str(OFFOrPOSitiveOrNEGative)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Burst trigger out set to ' Return]);

