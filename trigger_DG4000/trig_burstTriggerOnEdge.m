function Return = trig_burstTriggerOnEdge(trig,POSitiveOrNEGative,nChannel)
%% v1.0 yuanhui 20190209
% Set the generator to enable the burst output on the rising edge or falling edge of the external trigger signal. 
% [:SOURce<n>]:BURSt:TRIGger:SOURce INTernal|EXTernal|MANual

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':BURSt:TRIGger:SLOPe'];
fwrite(trig,[Command ' ' num2str(POSitiveOrNEGative)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Burst external trigger on edge set to ' Return]);

