function Return = trig_burstNcyclesDelay(trig,TDelaySecond,nChannel)
%% v1.0 yuanhui 20190209
% Set the time from when the generator receives the trigger signal to starts to output the N cycle (or infinite) burst and the default unit is "s".
% 0 s to 85 s
% This command is only available in N cycle and infinite burst modes. 

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':BURSt:TDELay'];
fwrite(trig,[Command ' ' num2str(TDelaySecond)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Burst delay set to ' Return]);

