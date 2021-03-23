function Return = trig_frequency(trig,nFrequency,nChannel)
%% v1.0 yuanhui 20190209
% Sine: 1 ?Hz to 160 MHz
% Square: 1 ?Hz to 50 MHz
% Ramp: 1 ?Hz to 4 MHz
% Pulse: 1 ?Hz to 40 MHz
% Arb: 1 ?Hz to 40 MHz 
% Harmonic: 1 ?Hz to 80 MHz 

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':FREQuency:FIXed ' num2str(nFrequency)];
fwrite(trig,Command);

fwrite(trig,':FREQuency?');
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' set to (Hz) ' Return]);

