function Return = trig_burstNcyclesPeriod(trig,nPeriodSecond,nChannel)
%% v1.0 yuanhui 20190209
% Set the Burst period (namely the time from the start of a N cycle burst to the start of the next burst) and the default unit is "s".
% ? 1 ?s + waveform period × number of bursts
% This command is only applicable to N cycle burst mode in internal trigger. 
% If the burst period is too short, the generator will increase this period automatically to allow the output of the specified number of cycles.

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':BURSt:INTernal:PERiod'];
fwrite(trig,[Command ' ' num2str(nPeriodSecond)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Burst period set to ' Return]);

