function Return = trig_DisplaySaverImmediate(trig)
%% v1.0 yuanhui 20190209
% Send the command below and the instrument enters the screen saver mode immediately. 
% [:SOURce<n>]:BURSt:MODE TRIGgered|GATed|INFinity
% 
% if nargin == 2
%     nChannel = 1;
% end
% 
% if isON==1
%     STATE_isON = 'ON';
% elseif isON==0
%     STATE_isON = 'OFF';
% end

Command = ['DISPlay:SAVer:IMMediate'];
fwrite(trig,[Command]);
% 
% fwrite(trig,[Command '?']);
% Return = fscanf(trig);
Return = 1;
% disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Burst ON|OFF set to ' Return]);

