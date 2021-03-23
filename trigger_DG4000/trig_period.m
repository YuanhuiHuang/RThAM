function Return = trig_period(trig,nPeriodSecond,nChannel)
%% v1.0 yuanhui 20190209
% Set the period of the basic waveform and the default unit is "s".
% Different waveforms correspond to different period ranges.
% Sine: 6.2 ns to 1.0000 Ms
% Square: 20.0 ns to 1.0000 Ms
% Ramp: 250.0 ns to 1.0000 Ms
% Pulse: 25.0 ns to 1.0000 Ms
% Arb: 25.0 ns to 1.0000 Ms
% Harmonic: 12.5 ns to 1.0000 Ms
% 

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':PERiod:FIXed ' num2str(nPeriodSecond)];
fwrite(trig,Command);

fwrite(trig,['SOURce' num2str(nChannel) ':PERiod:FIXed?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' period set to (second) ' Return]);

