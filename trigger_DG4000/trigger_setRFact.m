function Return = trigger_setRFact(DG4, DG4Info)
%% v1.0 yuanhui 20190222

%% Chan2 - Scope
%
trig_function(DG4, DG4Info.Scope_WaveShapeStr, DG4Info.Scope_Channel);
trig_voltageHigh(DG4, DG4Info.Scope_High, DG4Info.Scope_Channel);
trig_voltageLow(DG4, DG4Info.Scope_Low, DG4Info.Scope_Channel);
% trig_squareDcycle(DG4, DG4Info.Scope_DutyCycle, DG4Info.Scope_Channel);
trig_pulseDcycle(DG4, DG4Info.Scope_DutyCycle, DG4Info.Scope_Channel);
trig_period(DG4,DG4Info.PeriodSec,DG4Info.Scope_Channel);
trig_phaseAdjust(DG4,0,DG4Info.Scope_Channel); % start from Resting/Dark

trig_burstEnable(DG4,false,DG4Info.Scope_Channel);

%% Chan1 - RF
trig_outputImpedance(DG4,DG4Info.nImpedanceOhm,DG4Info.RF_Channel);
trig_function(DG4, DG4Info.RF_WaveShapeStr, DG4Info.RF_Channel);
trig_frequency(DG4, DG4Info.RF_Freq, DG4Info.RF_Channel);
trig_pulseWidth(DG4, DG4Info.RF_PulseWidth, DG4Info.RF_Channel);

trig_pulseLeading(DG4, 0.0*DG4Info.RF_PulseWidth, DG4Info.RF_Channel); % leading/falling edge time  ? 0.625 × pulse width
trig_pulseTrailing(DG4, 0.0*DG4Info.RF_PulseWidth, DG4Info.RF_Channel); % leading/falling edge time  ? 0.625 × pulse width

trig_voltageHigh(DG4, DG4Info.RF_High, DG4Info.RF_Channel);
trig_voltageLow(DG4, DG4Info.RF_Low, DG4Info.RF_Channel);

trig_burstEnable(DG4,DG4Info.BurstEnable,DG4Info.RF_Channel);
trig_burstMode(DG4,'GATed',DG4Info.RF_Channel); % INFinity  GATed
trig_burstNcyclesPeriod(DG4,DG4Info.PeriodSec,DG4Info.RF_Channel);
% trig_burstPhase(DG4,0,DG4Info.RF_Channel);
trig_burstGatedPolarity(DG4,DG4Info.GatedPolarity,DG4Info.RF_Channel); % start from Resting/Dark NORMal INVerted
trig_burstEnable(DG4,DG4Info.BurstEnable,DG4Info.RF_Channel);
% trig_output(DG4, 'ON', DG4Info.RF_Channel);


%%
Return = 1;
