function Return = trig_pulseLeading(trig, nLeadingSecond, nChannel)
%% v1.0 yuanhui 20190209
% Set the leading (rising) edge time of the pulse and the default unit is "s".
% The range available is limited by the pulse width currently specified. 
% The relation fulfills the inequality: 
% leading/falling edge time  ? 0.625 × pulse width.
% DG4000 will automatically adjust the edge time to match the specified pulse width if the value currently set exceeds the limit value.

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':PULSe:TRANsition:LEADing ' (nLeadingSecond)];
fwrite(trig,Command);

fwrite(trig,['SOURce' num2str(nChannel) ':PULSe:TRANsition:LEADing' '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Leading (rising) time set to ' Return]);

