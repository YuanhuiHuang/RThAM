function Pm_TimerFcnCallback(PmVid, TimerStruct)
%% v1.0 yuanhui 20190221
% % This timmerFcn can be used to stop camera, or control the the frame
% rate of acquisition
stop(PmVid);
PmSrc.StreamAcquisition = 'OFF'; % 'OFF', 'RAW' or 'TIFF'
% stoppreview(PmVid);

PmVid.UserData = toc(PmVid.UserData);

% tic;
% figure(1001),imagesc(getsnapshot(PmVid));
% toc
TimerStruct.Data.AbsTime;
% start(PmVid);
% trigger(PmVid);

