function Return = trig_burstNcycles(trig,nCycles,nChannel)
%% v1.0 yuanhui 20190209
% 1 to 1 000 000 (external or manual trigger) 
% 1 to 500 000 (internal trigger)

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':BURSt:NCYCles'];
fwrite(trig,[Command ' ' num2str(nCycles)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Burst Ncycles set to ' Return]);

