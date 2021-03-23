function Return = trig_pulseWidth(trig, nWIDTh, nChannel)
%% v1.0 yuanhui 20190209
% This parameter is related to the duty cycle and when any of them is changed, the other will be modified automatically.
% The pulse width is limited by the minimum pulse width (4 ns) and pulse period.
%     pulse width ? minimum pulse width
%     pulse width ? pulse period - 2 × minimum pulse width

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':PULSe:WIDTh ' num2str(nWIDTh)];
fwrite(trig,Command);

fwrite(trig,'PULSe:WIDTh?');
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' set to (second) ' Return]);

