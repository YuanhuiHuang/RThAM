% TAM initializing
fclose all;
delete(instrfindall);
mstart;
[DG4, DG4Info] = DG4_init();
DAQ = gageInit();

% pi2xMoveAbs(pi,25,25);

%%
run('C:\Program Files\Zurich Instruments\LabOne\API\MATLAB2012\ziAddPath');
example_poll('dev556')
% [data_no_trig, data_trig, data_fft] = example_scope('dev556')
[data_no_trig, data_trig, data_fft] = hf2_example_scope('dev556')

% doc http://127.0.0.1:8006/file?action=doc&data=LabOneProgrammingManual.pdf