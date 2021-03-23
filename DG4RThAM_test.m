%% DG4RThAM_test
[DG4, DG4Info] = DG4_init_test()

%%
trig_burstEnable(DG4,1,1);
Return = trig_burstMode(DG4,'TRIGgered')
trig_burstNcycles(DG4,4)
trig_burstNcyclesDelay(DG4,0.5e-6)
trig_burstTriggerOnEdge(DG4,1)
Return = trig_burstMode(DG4,'TRIGgered')

%%
trigger_close(DG4)