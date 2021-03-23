function Return = trig_sweepTriggerOut(trig,sweepTriggerOutStr,nChannel)
%% v1.0 yuanhui 20190209
% OFF|POSitive|NEGative
% default OFF

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':SWEep:TRIGger:TRIGOut'];
fwrite(trig,[Command ' ' sweepTriggerOutStr]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sweep trigger output slopes set to ' Return]);

