function Return = trig_voltageAmplitude(trig, nVoltage, nChannel)
%% v1.0 yuanhui 20190209
% Set the amplitude of the basic waveform and the default unit is "Vpp".

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':VOLTage:LEVel:IMMediate:AMPLitude ' num2str(nVoltage)];
fwrite(trig,Command);

fwrite(trig,'VOLTage?');
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' AMPLitude set to (Volt) ' Return]);

