function [DG4, DG4Info] = DG4_init_test()
%% initialize DG4162 for snRTAM
% v1.0 yuanhui 20190208
addpath('C:\Users\yuanhui\MATLAB\TAM\trigger_DG4000')
%% 
DG4Info.Buffer = 1024; % bytes
DG4Info.Timeout = 5; % second
try
    DG4=trig_start(DG4Info.Buffer,DG4Info.Timeout );
    trig_open(DG4);
catch
%% Channel 1
DG4Info.RF_Channel = 1;
DG4Info.RF_Freq = 100e6; % Hz
DG4Info.RF_WaveShapeStr = 'SINusoid'; % SINusoid|SQUare|RAMP|PULSe|NOISe|USER| etc
DG4Info.RF_PulseWidth = 100e-9; % second. FPG triggers on 100 ns 5V TTL; DG4 accepts 0.3125% of period
DG4Info.RF_DutyCycle = 0.315; % % in percentage
DG4Info.RF_Delay = 0; % second
if DG4Info.RF_PulseWidth<1./DG4Info.RF_Freq
    DG4Info.RF_PulseWidth = 1./DG4Info.RF_Freq .* 0.315 ./ 100;
end
DG4Info.RF_High = 1e-3; % Volt. FPG triggers on 100 ns 5V TTL
DG4Info.RF_Low = 0; % Volt
DG4Info.RF_Amplitude = 1e-3; % Vpp.
DG4Info.RF_Offset = 0; % Volt.

%
trig_function(DG4, DG4Info.RF_WaveShapeStr, DG4Info.RF_Channel);
trig_frequency(DG4, DG4Info.RF_Freq, DG4Info.RF_Channel);
trig_pulseWidth(DG4, DG4Info.RF_PulseWidth, DG4Info.RF_Channel);
% trig_pulseDcycle(DG4, DG4Info.RF_DutyCycle, DG4Info.RF_Channel);
trig_pulseDelay(DG4, DG4Info.RF_Delay, DG4Info.RF_Channel);
trig_pulseHold(DG4, 'DUTY', DG4Info.RF_Channel);
trig_pulseLeading(DG4, 0.0*DG4Info.RF_PulseWidth, DG4Info.RF_Channel); % leading/falling edge time  ? 0.625 × pulse width
trig_pulseTrailing(DG4, 0.0*DG4Info.RF_PulseWidth, DG4Info.RF_Channel); % leading/falling edge time  ? 0.625 × pulse width
trig_voltageUnit(DG4, 'VPP', DG4Info.RF_Channel);
trig_outputImpedance(DG4,50,DG4Info.RF_Channel);
trig_voltageHigh(DG4, DG4Info.RF_High, DG4Info.RF_Channel);
trig_voltageLow(DG4, DG4Info.RF_Low, DG4Info.RF_Channel);
trig_voltageAmplitude(DG4, DG4Info.RF_Amplitude, DG4Info.RF_Channel);
trig_voltageOffset(DG4, DG4Info.RF_Offset, DG4Info.RF_Channel);

trig_outputPolarity(DG4,'NORMal',DG4Info.RF_Channel);

%% Channel 2
DG4Info.Scope_Channel = 2;
DG4Info.Scope_Freq = 10; % Hz
DG4Info.Scope_WaveShapeStr = 'SQUare'; % SINusoid|SQUare|RAMP|PULSe|NOISe|USER| etc
DG4Info.Scope_PulseWidth = 100e-9; % second. FPG triggers on 100 ns 5V TTL; DG4 accepts 0.3125% of period
DG4Info.Scope_DutyCycle = 0.315; % % in percentage
DG4Info.Scope_Delay = 0; % second
if DG4Info.Scope_PulseWidth<1./DG4Info.Scope_Freq
    DG4Info.Scope_PulseWidth = 1./DG4Info.Scope_Freq .* 0.315 ./ 100;
end
DG4Info.Scope_High = 7; % Volt. FPG triggers on 100 ns 5V TTL
DG4Info.Scope_Low = 0; % Volt
DG4Info.Scope_Amplitude = 7; % Vpp.
DG4Info.Scope_Offset = DG4Info.Scope_Amplitude/2; % Volt.
%
trig_function(DG4, DG4Info.Scope_WaveShapeStr, DG4Info.Scope_Channel);
trig_frequency(DG4, DG4Info.Scope_Freq, DG4Info.Scope_Channel);
trig_pulseWidth(DG4, DG4Info.Scope_PulseWidth, DG4Info.Scope_Channel);
% trig_pulseDcycle(DG4, DG4Info.Scope_DutyCycle, DG4Info.Scope_Channel);
trig_pulseDelay(DG4, DG4Info.Scope_Delay, DG4Info.Scope_Channel);
trig_pulseHold(DG4, 'DUTY', DG4Info.Scope_Channel); % WIDTh|DUTY
trig_pulseLeading(DG4, 0.0*DG4Info.Scope_PulseWidth, DG4Info.Scope_Channel); % leading/falling edge time  ? 0.625 × pulse width
trig_pulseTrailing(DG4, 0.0*DG4Info.Scope_PulseWidth, DG4Info.Scope_Channel); % leading/falling edge time  ? 0.625 × pulse width
trig_voltageUnit(DG4, 'VPP', DG4Info.Scope_Channel);

trig_outputImpedance(DG4,10000,DG4Info.Scope_Channel);

trig_voltageHigh(DG4, DG4Info.Scope_High, DG4Info.Scope_Channel);
trig_voltageLow(DG4, DG4Info.Scope_Low, DG4Info.Scope_Channel);
trig_voltageAmplitude(DG4, DG4Info.Scope_Amplitude, DG4Info.Scope_Channel);
trig_voltageOffset(DG4, DG4Info.Scope_Offset, DG4Info.Scope_Channel);



%%
disp('DG4162 intialized.')
end