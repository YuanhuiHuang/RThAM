function Return = trig_sweepEnable(trig,isON,nChannel)
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

Command = ['SOURce' num2str(nChannel) ':SWEep:STATe'];
fwrite(trig,[Command ' ' STATE_isON]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sweep ON|OFF set to ' Return]);

