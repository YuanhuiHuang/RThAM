function Return = trig_sweepReturnTime(trig,sweepTimeSecond,nChannel)
%% v1.0 yuanhui 20190209
% seconds, 1 ms to 300 s


if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':SWEep:RTIMe'];
fwrite(trig,[Command ' ' num2str(sweepTimeSecond)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sweep Return time (second) set to ' Return]);

