function Return = trig_couplingAmplDeviation(trig,nVPPDev,nChannel)
%% v1.0 yuanhui 20190209
% 0-20 Vpp

if nargin == 2
    nChannel = 1;
end

Command = ['COUPling:AMPL:DEViation'];
fwrite(trig,[Command ' ' num2str(nVPPDev)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 Coupling amplitude deviation (Vpp) set to ' Return]);

