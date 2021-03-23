function Return = trig_phaseAdjust(trig,nPhaseDegree,nChannel)
%% v1.0 yuanhui 20190209
% in Degree Set the start phase of the basic waveform.

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':PHASe:ADJust ' num2str(nPhaseDegree)];
fwrite(trig,Command);

fwrite(trig,['SOURce' num2str(nChannel) ':PHASe:ADJust?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' phase set to (°) ' Return]);

