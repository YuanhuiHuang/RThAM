function Return = trig_voltageLow(trig, nVoltage, nChannel)
%% v1.0 yuanhui 20190209
% Set the high level of the basic waveform and the default unit is "V".

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':VOLTage:LEVel:IMMediate:LOW ' num2str(nVoltage)];
fwrite(trig,Command);

fwrite(trig,'VOLTage:LOW?');
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Lolevel set to (Volt) ' Return]);

