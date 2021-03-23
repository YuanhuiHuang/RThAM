function Return = trig_syncEnable(trig,isON,nChannel)
%% v1.0 yuanhui 20190209
% Enable or disable the sweep function.
% [:SOURce<n>]:SWEep:STATe OFF|ON

if nargin == 2
    nChannel = 1;
end

if isON==1
    STATE_isON = 'ON';
elseif isON==0
    STATE_isON = 'OFF';
end

Command = ['OUTPut' num2str(nChannel) ':SYNC:STATe'];
fwrite(trig,[Command ' ' STATE_isON]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sync ON|OFF set to ' Return]);

