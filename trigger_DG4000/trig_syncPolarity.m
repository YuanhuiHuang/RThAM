function Return = trig_syncPolarity(trig,POSitiveOrNEGative,nChannel)
%% v1.0 yuanhui 20190209
% :OUTPut[<n>]:SYNC:POLarity POSitive|NEGative
% Set the output polarity of the [Sync1] or [Sync2] connector.

if nargin == 2
    nChannel = 1;
end

Command = ['OUTPut' num2str(nChannel) ':SYNC:POLarity'];
fwrite(trig,[Command ' ' num2str(POSitiveOrNEGative)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sync polarity set to ' Return]);

