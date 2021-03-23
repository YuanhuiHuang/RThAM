function Return = trig_pulseDelay(trig, nDelaySecond, nChannel)
%% v1.0 yuanhui 20190209
% Set the  delay of the pulse and the default unit is "s".

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':PULSe:DELay ' num2str(nDelaySecond)];
fwrite(trig,Command);

fwrite(trig,['SOURce' num2str(nChannel) ':PULSe:DELay' '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Delay set to ' Return]);

