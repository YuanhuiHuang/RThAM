function Return = trig_sweepStopHold(trig,nStopHOldSecond,nChannel)
%% v1.0 yuanhui 20190209
% seconds
% Start hold is the period of time that the output signal outputs with the 
% "Start" frequency after the sweep starts. After the start hold time 
% expires, the generator will output with varying frequency in the current sweep type.

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':SWEep:HTIMe:STOP'];
fwrite(trig,[Command ' ' num2str(nStopHOldSecond)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sweep Start Hold (seconds) set to ' Return]);

