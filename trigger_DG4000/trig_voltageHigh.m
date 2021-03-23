function Return = trig_voltageHigh(trig, nVoltage, nChannel)
%% v1.0 yuanhui 20190209
% Set the high level of the basic waveform and the default unit is "V".

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':VOLTage:LEVel:IMMediate:HIGH ' num2str(nVoltage)];
fwrite(trig,Command);

fwrite(trig,'VOLTage:HIGH?');
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' HiLevel set to (Volt) ' Return]);

