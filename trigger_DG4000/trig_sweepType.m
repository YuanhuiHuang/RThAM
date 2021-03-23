function Return = trig_sweepType(trig,sweepTypeStr,nChannel)
%% v1.0 yuanhui 20190209
% SWEep:SPACing LINear|LOGarithmic|STEp
% default LINear

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':SWEep:SPACing'];
fwrite(trig,[Command ' ' sweepTypeStr]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sweep type set to ' Return]);

