function Return = trig_couplingChannelBase(trig,nChannel)
%% v1.0 yuanhui 20190209
% Set the base channel of coupling to CH1 or CH2.

Command = ['COUPling:CHannel:BASE'];
fwrite(trig,[Command ' CH' num2str(nChannel)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 Channel coupling base set to ' Return]);

