function Return = trig_couplingPhaseEnable(trig,isON)
%% v1.0 yuanhui 20190209
% Enable or disable the frequency, phase and amplitude couplings of the channel.

if isON==1
    STATE_isON = 'ON';
elseif isON==0
    STATE_isON = 'OFF';
end

Command = ['COUPling:PHASe:STATe'];
fwrite(trig,[Command ' ' STATE_isON]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 Channel Phase coupling ON|OFF set to ' Return]);

