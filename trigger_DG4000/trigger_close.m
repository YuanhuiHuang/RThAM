% stephan kellnberger
% 2010/12/06
% trig close
% version 1.0
function trigger_close(trig)
fclose(trig);
delete(trig);
disp('DG4162 closed and removed from TMTOOL')