function Return = trig_burstPhase(trig,nPhaseDegree,nChannel)
%% v1.0 yuanhui 20190209
% Set the start phase of the burst and the default unit is "°".
% 0° to 360°
% For sine, square and ramp, 0° is the point where the waveform passes through 0 V (or DC offset value) positively.
% For arbitrary waveform, 0° is the first point of the waveform.
% For pulse and noise, start phase is not available. 

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':BURSt:PHASe'];
fwrite(trig,[Command ' ' num2str(nPhaseDegree)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Burst start phase set to ' Return]);

