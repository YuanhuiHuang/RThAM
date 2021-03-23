function Return =  trig_output(trig, isOUTPUTstr, nChannel)
%% v1.0 yuanhui 20190209
% Enable or disable the output of the [Output1] or [Output2] connector at the front panel.

if nargin == 2
    nChannel = 1;
end

Command = ['OUTPut' num2str(nChannel) ':STATe ' num2str(isOUTPUTstr)];
fwrite(trig,Command);

fwrite(trig,['OUTPut' num2str(nChannel) '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' OUTPut set to ' Return]);

