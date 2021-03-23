clear all;

fclose(instrfind);
delete(instrfind);

pi = pi2xStart();
pi2xOpen(pi);

DAQ = gageInit();