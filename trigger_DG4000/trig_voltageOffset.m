function Return = trig_voltageOffset(trig, nVoltage, nChannel)
%% v1.0 yuanhui 20190209
% Set the Offset of the basic waveform and the default unit is "Vpp".

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':VOLTage:LEVel:IMMediate:OFFSet ' num2str(nVoltage)];
fwrite(trig,Command);

fwrite(trig,'VOLTage:OFFSet?');
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' OFFSet set to (Volt) ' Return]);

