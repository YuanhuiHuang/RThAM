function Return = trig_burstTriggerSource(trig,SourceStr,nChannel)
%% v1.0 yuanhui 20190209
% Set the trigger source of the Burst to internal, external or manual.
% [:SOURce<n>]:BURSt:TRIGger:SOURce INTernal|EXTernal|MANual

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':BURSt:TRIGger:SOURce'];
fwrite(trig,[Command ' ' num2str(SourceStr)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Burst trigger source set to ' Return]);

