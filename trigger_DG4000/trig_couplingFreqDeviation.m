function Return = trig_couplingFreqDeviation(trig,nFreqHz,nChannel)
%% v1.0 yuanhui 20190209
% 0 ?Hz to 160 MHz

if nargin == 2
    nChannel = 1;
end

Command = ['COUPling:FREQuency:DEViation'];
fwrite(trig,[Command ' ' num2str(nFreqHz)]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 Coupling FREQuency deviation (Hz) set to ' Return]);

