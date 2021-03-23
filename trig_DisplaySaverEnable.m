function Return = trig_DisplaySaverEnable(trig,isON)
%% v1.0 yuanhui 20190209
% Set the burst type to N cycle, gated or infinite. 
% [:SOURce<n>]:BURSt:MODE TRIGgered|GATed|INFinity

% if nargin == 2
%     nChannel = 1;
% end

if isON==1
    STATE_isON = 'ON';
elseif isON==0
    STATE_isON = 'OFF';
end

Command = ['DISPlay:SAVer:STATe'];
fwrite(trig,[Command ' ' STATE_isON]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Display Saver ON|OFF set to ' Return]);

