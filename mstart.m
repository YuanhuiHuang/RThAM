% if ~isempty(instrfind)
%     fclose(instrfind);
%     delete(instrfind);
% end
addpath('C:\Users\yuanhui\MATLAB\TAM\piMikro');
PI = pi3xStart('TAM_HYBRID');
pi3xOpen(PI);         % Open connection to stage controllers

pi3xServoOn(PI, 1);
pi3xRef(PI);
