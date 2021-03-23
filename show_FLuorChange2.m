% function show_FLuorChange()
nDownSample = 20;
Dark1 = nanmean(reshape([Dark; nan(mod(-numel(Dark),nDownSample),1)],nDownSample,[]));
Dark1 = Dark1(1:2:end);
% Dark1 = interp1(1:length(Dark1), Dark1, 1:60);
RF1 = nanmean(reshape([RF; nan(mod(-numel(RF),nDownSample),1)],nDownSample,[]));  
% RF1 = interp1(1:length(RF1), RF1, 1:60);

Offset = 170;
Dark1 = Dark1-Offset;
RF1 = RF1-Offset;
% Timing = [1:length(Dark1)]'.*1;
Timing1 = nanmean(reshape([Timing; nan(mod(-numel(Timing),nDownSample),1)],nDownSample,[]));
% RF_ONOFF = repmat([zeros(1,29) ones(1,1)],1,5)';
RF_ONOFF = nan(size(Timing1));
for iRFon=1:5
    RF_ONOFF(20+iRFon:23:end)=1;
end
tDelayRF = 2;
RF_ONOFF = [nan(1,tDelayRF) RF_ONOFF];
RF_ONOFF(end-tDelayRF+1:end)=[];

RF_ONOFF2 = RF_ONOFF;
for iRFon=1:15
    RF_ONOFF2(20+iRFon:23:end)=1;
end
tDelayRF = 2;
RF_ONOFF2 = [nan(1,tDelayRF) RF_ONOFF2];
RF_ONOFF2(end-tDelayRF+1:end)=[];

FlMax = max(max(RF1),max(Dark1));
FlMin = min(min(RF1),min(Dark1));
figure,xlim([Timing1(1) Timing1(end)]); ylim([FlMin/FlMax,1]);
grid on, grid minor
xlabel('Time (second)'); ylabel('Fluorescence (a.u.)')

iiFrame=1;
for iiFrame=1:1:length(Dark1)
    hold on, plot(Timing1(1:iiFrame),RF_ONOFF2(1:iiFrame),'-*k')
    hold on, plot(Timing1(1:iiFrame),Dark1(1:iiFrame)./FlMax,'k')
    hold on, plot(Timing1(1:iiFrame),RF_ONOFF(1:iiFrame),'-or')
    hold on, plot(Timing1(1:iiFrame),RF1(1:iiFrame)./FlMax,'r','linewidth',2)
%     legend('RF 5kV/10kHz','Gcamp6s in Dark', 'Gcamp6s in RF','Location','northeast')
    legend('RF On/Off 60/100', 'GCaMP6s PRR 2k','RF On/Off 10/50','GCaMP6s PRR 10k', 'Location','southwest')
    F(iiFrame) = getframe(gcf) ;
    title('RF stimulation dCycle 10/50 or 60/100 (seconds)')
      drawnow
%     pause(0.1)
end

% create the video writer with 1 fps
  writerObj = VideoWriter('C:\Pictures\Microscope_Storage\20190308_10kV_6dpf_day3\Gcamp6s20x10sOn40sOff_RFon_10000Hz_2\timeCourse.avi');
  writerObj.FrameRate = 3;
  % open the video writer
  open(writerObj);
  % write the frames to the video
  for iiFrame=1:1:length(Dark1)
      % convert the image to a frame
        frame = F(iiFrame) ;    
    writeVideo(writerObj, frame);
  end
  % close the writer object
close(writerObj);