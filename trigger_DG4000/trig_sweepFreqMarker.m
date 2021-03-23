function Return = trig_sweepFreqMarker(trig,isEnabled,nChannel)
%% v1.0 yuanhui 20190209
% ON|OFF

if nargin == 2
    nChannel = 1;
end

if isEnabled == 1
    EnableStr = 'ON';
elseif isEnabled == 0
    EnableStr = 'OFF';
end

Command = ['SOURce' num2str(nChannel) ':MARKer:STATe'];
fwrite(trig,[Command ' ' EnableStr]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sweep Marker frequency (to levels of Sync) set to ' Return]);

