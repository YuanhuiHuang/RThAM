function Return = trig_couplingAmplEnable(trig,isON)
%% v1.0 yuanhui 20190209
% Enable or disable the frequency, phase and amplitude couplings of the channel.

if isON==1
    STATE_isON = 'ON';
elseif isON==0
    STATE_isON = 'OFF';
end

Command = ['COUPling:AMPL:STATe'];
fwrite(trig,[Command ' ' STATE_isON]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 Channel Amplitude coupling ON|OFF set to ' Return]);

