function Return = trig_sweepFreqCenter(trig,nFrequency,nChannel)
%% v1.0 yuanhui 20190209
% Set the center frequency of the sweep and the default unit is "(550) Hz".
% Sine: 1 µHz to 160 MHz
% Square: 1 µHz to 50 MHz
% Ramp: 1 µHz to 4 MHz
% Pulse: 1 µHz to 40 MHz
% Arb: 1 µHz to 40 MHz 
% Harmonic: 1 µHz to 80 MHz 
% % In the sweep mode, the start frequency, end frequency, center frequency and frequency span are interrelated and their relations fulfill the following equations.
%         center frequency = (?start frequency + end frequency?) /2
%         frequency span = end frequency - start frequency

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':FREQuency:CENTer ' num2str(nFrequency)];
fwrite(trig,Command);

fwrite(trig,['SOURce' num2str(nChannel) ':FREQuency:CENTer?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' sweep center set to (Hz) ' Return]);

