function Return = trig_sweepTriggerSource(trig,sweepTriggerStr,nChannel)
%% v1.0 yuanhui 20190209
% INTernal|EXTernal|MANual
% default INTernal

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':SWEep:TRIGger:SOURce'];
fwrite(trig,[Command ' ' sweepTriggerStr]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sweep trigger source set to ' Return]);

