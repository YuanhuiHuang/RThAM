function Return = trig_pulseDcycle(trig, nDcyclePercent, nChannel)
%% v1.0 yuanhui 20190209
% set the pulse duty cycle and the unit is %.

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':PULSe:DCYCle ' num2str(nDcyclePercent)];
fwrite(trig,Command);

fwrite(trig,['SOURce' num2str(nChannel) ':PULSe:DCYCle' '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Duty cycle set to ' Return]);

