function Return = trig_phaseInitiate(trig,nChannel)
%% v1.0 yuanhui 20190209
% in Degree Set the start phase of the basic waveform.

Command = ['SOURce' num2str(nChannel) ':PHASe:INITiate'];
fwrite(trig,Command);

fwrite(trig,['SOURce' num2str(nChannel) ':PHASe:ADJust?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' phase set to (°) ' Return]);

