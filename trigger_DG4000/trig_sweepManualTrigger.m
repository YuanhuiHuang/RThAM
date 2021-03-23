function Return = trig_sweepManualTrigger(trig,nChannel)
%% v1.0 yuanhui 20190209
% INTernal|EXTernal|MANual
% default INTernal

if nargin == 1
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':SWEep:TRIGger:IMMediate'];
fwrite(trig,Command);

% fwrite(trig,[Command '?']);
% Return = fscanf(trig);
% disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Sweep trigger source set to ' Return]);
Return = 1;

