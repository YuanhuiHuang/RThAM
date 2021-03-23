function Return = trig_sweepTriggerOnEdge(trig,sweepTriggerSlopeStr,nChannel)
%% v1.0 yuanhui 20190209
% POSitive|NEGative
% default POSitive

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':SWEep:TRIGger:SLOPe'];
fwrite(trig,[Command ' ' sweepTriggerSlopeStr]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sweep trigger edge slope set to ' Return]);

