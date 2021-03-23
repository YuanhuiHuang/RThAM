function Return = trig_voltageUnit(trig, UnitStr, nChannel)
%% v1.0 yuanhui 20190209
% Set the amplitude unit to VPP, VRMS or DBM.

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':VOLTage:UNIT ' UnitStr];
fwrite(trig,Command);

fwrite(trig,'VOLTage:UNIT?');
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' UNIT set to ' Return]);

