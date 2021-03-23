function Return = trig_burstMode(trig,ModeStr,nChannel)
%% v1.0 yuanhui 20190209
% Set the burst type to N cycle, gated or infinite. 
% [:SOURce<n>]:BURSt:MODE TRIGgered|GATed|INFinity

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':BURSt:MODE'];
fwrite(trig,[Command ' ' ModeStr]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Burst mode set to ' Return]);
