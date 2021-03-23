function Return = trig_sysClockSource(trig,INTorEXT)
%% v1.0 yuanhui 20200819
% Set the reference clock source to INTernal or EXTernal.

% Query the reference clock source.

% :SYSTem:ROSCillator:SOURce INTernal|EXTernal

% :SYSTem:ROSCillator:SOURce?


Command = ['SYSTem:ROSCillator:SOURce'];
fwrite(trig,[Command ' ' INTorEXT]);

fwrite(trig,[Command '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'reference clock source set to ' Return]);

