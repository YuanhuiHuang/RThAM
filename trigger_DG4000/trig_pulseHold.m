function Return = trig_pulseHold(trig, WIDThorDUTY, nChannel)
%% v1.0 yuanhui 20190209
% Select the pulse width or duty cycle of the pulse. WIDTh|DUTY
% [:SOURce<n>]:PULSe:HOLD WIDTh|DUTY
% The pulse width and duty cycle are related and when any one of them is changed, the other will be modified automatically. 
if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':PULSe:HOLD ' (WIDThorDUTY)];
fwrite(trig,Command);

fwrite(trig,['SOURce' num2str(nChannel) ':PULSe:HOLD' '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' HOLD set to ' Return]);

