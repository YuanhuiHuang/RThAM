function Return =  trig_output2Chan(trig, isOUTPUTstr, DG4Info)
%% v1.0 yuanhui 20190308
% Enable or disable the output of the [Output1] or [Output2] connector at the front panel.
% For trigger RF activation, Chan2 (period control) should turn on firstly,
% then Chan1 (burst). - 20190308

Command = ['OUTPut' num2str(DG4Info.Scope_Channel) ':STATe ' num2str(isOUTPUTstr)];
fwrite(trig,Command);

Command = ['OUTPut' num2str(DG4Info.RF_Channel) ':STATe ' num2str(isOUTPUTstr)];
fwrite(trig,Command);

fwrite(trig,['OUTPut' num2str(DG4Info.Scope_Channel) '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(DG4Info.Scope_Channel) ' OUTPut set to ' Return]);

fwrite(trig,['OUTPut' num2str(DG4Info.RF_Channel) '?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(DG4Info.RF_Channel) ' OUTPut set to ' Return]);


