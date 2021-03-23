function Return = trig_couplingPhaseDeviation(trig,nPhaseDegree,nChannel)
%% v1.0 yuanhui 20190209
% 0° to 360°

if nargin == 2
    nChannel = 1;
end

Command = ['COUPling:PHASe:DEViation'];
fwrite(trig,[Command ' ' num2str(nPhaseDegree)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 Coupling PHASe deviation (Hz) set to ' Return]);

