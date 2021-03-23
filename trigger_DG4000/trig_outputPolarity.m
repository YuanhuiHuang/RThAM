function Return = trig_outputPolarity(trig,NORMalorINVerted,nChannel)
%% v1.0 yuanhui 20190209
% :OUTPut[<n>]:POLarity NORMal|INVerted
% When the output polarity is set to INVerted, the waveform inverts ...
% relatively to the offset voltage.
% After the waveform is inverted, none of the offset voltages would ...
% change, the waveform displayed in the user interface is not inverted ...
% and the related sync signal is not inverted. 


if nargin == 2
    nChannel = 1;
end

Command = ['OUTPut' num2str(nChannel) ':POLarity'];
fwrite(trig,[Command ' ' num2str(NORMalorINVerted)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Output polarity set to ' Return]);

