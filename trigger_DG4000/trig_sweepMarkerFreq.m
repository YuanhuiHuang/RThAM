function Return = trig_sweepMarkerFreq(trig,nMarkerFreq,nChannel)
%% v1.0 yuanhui 20190209
% default unit is "Hz".
% nMarkerFreq limits to Start - Stop frequency of sweep


if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':MARKer:FREQuency'];
fwrite(trig,[Command ' ' num2str(nMarkerFreq)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sweep Marker Frequency (Hz) set to ' Return]);

