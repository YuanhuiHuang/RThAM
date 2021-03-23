function Return = trig_outputImpedance(trig,nImpedanceOhm,nChannel)
%% v1.0 yuanhui 20190209
% Ohm - 1 ? to 10000 ?
% Default setting: INFinity (HighZ)
% same to - 
% :OUTPut[<n>]:LOAD <ohms>|INFinity|MINimum|MAXimum

if nargin == 2
    nChannel = 1;
end

Command = ['OUTPut' num2str(nChannel) ':IMPedance'];
fwrite(trig,[Command ' ' num2str(nImpedanceOhm)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' Output Impedance (Ohm) set to ' Return]);

