function Return = trig_burstGatedPolarity(trig,NORMalorINVerted,nChannel)
%% v1.0 yuanhui 20190209
% Set the generator to output a burst when the gated signal at the [Mod/FSK/Trig] connector at the rear panel is high level or low level. 
% This command is only available in gated Burst mode.
% [:SOURce<n>]:BURSt:GATE:POLarity NORMal|INVerted

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':BURSt:GATE:POLarity'];
fwrite(trig,[Command ' ' num2str(NORMalorINVerted)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Burst polarity set to ' Return]);

