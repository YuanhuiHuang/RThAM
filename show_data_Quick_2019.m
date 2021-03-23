function [tt_ROI ROI] = show_data_Quick_2019(tt_, R, Slice_T1, Slice_T2, MIP_XYZ, yLim, xLim, SoS, IS_TA, dt, dx, dy, dz, reconParams)
%% show_data
% figure('units','normalized','position',[0.47 0 1/2 1]);
addpath('C:\Users\yuanhui\MATLAB\TAM\vline');

if IS_TA
    ROI = R(:,:,((tt_>=Slice_T1)&(tt_<=Slice_T2)));
    tt_ROI = tt_(((tt_>=Slice_T1)&(tt_<=Slice_T2)));
    Delta_tt_ = max(tt_ROI)-min(tt_ROI);
elseif ~IS_TA
    tt_ = tt_ * 2;
    ROI = R(:,:,((tt_>=Slice_T1)&(tt_<=Slice_T2)));
    tt_ROI = tt_(((tt_>=Slice_T1)&(tt_<=Slice_T2)));
    tt_ROI = tt_ROI / 2;
    tt_ = tt_ / 2;
    Delta_tt_ = max(tt_ROI)-min(tt_ROI);
end
ROI = medfilt1(ROI,3);
% % if XY is not switched
% ROI = permute(ROI,[2 1 3]);     [X Y Z] = size(ROI);
% % SS = abs(hilbert(filtS(SS,dt,min(dx, dy),2)));

% Hilbert transform
[X Y Z] = size(ROI);
% for i=1:X
%     for j=1:Y
%         ROI(i,j,:) = abs(hilbert(squeeze(ROI(i,j,:))));
%     end
% end

figure('units','pixel','position',[60 0 960 1124]),
if MIP_XYZ~=0
    ss=medfilt2(squeeze(max(abs(ROI),[],MIP_XYZ)),'symmetric');
    ss=ss-min(min(ss));
end

if MIP_XYZ==3 % Z projection
        subplot(3, 2, 1),imagesc([0 yLim(2)-yLim(1)],[0 xLim(2)-xLim(1)], ss(1:end,1:end));colormap jet; h_temp = colorbar;xlabel(h_temp,'/mV');axis image;
        xlabel('X axis (mm)'), ylabel('Y axis (mm)');
        if IS_TA    title('TA Image - XY');     elseif ~IS_TA    title('US Image - XY');end
elseif MIP_XYZ==2 % Y projection
        subplot(3, 2, 2),
        if IS_TA    
            imagesc([0 xLim(2)-xLim(1)],SoS.*1e6.*Slice_T1+[0 SoS.*1e6.*Delta_tt_], ss(1:end,1:end)');
            title('TA Image - YZ');     
        elseif ~IS_TA    
            imagesc([0 xLim(2)-xLim(1)],(SoS.*1e6.*Slice_T1+[0 2.*SoS.*1e6.*Delta_tt_])./2, ss(1:end,1:end)');
            title('US Image - YZ');
        end
        colormap jet; h_temp = colorbar;xlabel(h_temp,'/mV');axis image;
        xlabel('Y axis (mm)'), ylabel('Z-temporal axis (mm)');
elseif MIP_XYZ==1 % X projection
        subplot(3, 2, 3),
        if IS_TA    
            imagesc([0 yLim(2)-yLim(1)],SoS.*1e6.*Slice_T1+[0 SoS.*1e6.*Delta_tt_], ss(1:end,1:end)');
            title('TA Image - XZ');     
        elseif ~IS_TA    
            imagesc([0 yLim(2)-yLim(1)],(SoS.*1e6.*Slice_T1+[0 2.*SoS.*1e6.*Delta_tt_])./2, ss(1:end,1:end)');
            title('US Image - XZ');
        end
        colormap jet; h_temp = colorbar;xlabel(h_temp,'/mV');axis image;
        xlabel('X axis (mm)'), ylabel('Z-temporal axis (mm)');
else % All
        ROI_hilbert = reshape(abs(hilbert(reshape(ROI,[X*Y,Z]))),[X, Y, Z])./sqrt(2);
%         ROI_hilbert = abs(ROI);
        ss=medfilt2(squeeze(max(ROI_hilbert,[],3)),'symmetric');
        ss=ss-min(min(ss));
%         ss(ss>0.5.*max(ss(:)))=0;
%         subplot(3, 2, 1), imagesc([0 yLim(2)-yLim(1)],[0 xLim(2)-xLim(1)],ss(1:end,1:end));colormap jet; h_temp = colorbar;xlabel(h_temp,'/mV');axis image;
        subplot(3, 2, 1), imagesc([xLim(1) xLim(2)],[yLim(1) yLim(2)],ss(1:end,1:end)');colormap jet; h_temp = colorbar;xlabel(h_temp,'/mV');axis image;
        xlabel('X axis (mm)'), ylabel('Y axis (mm)');
        if IS_TA    title('TA Image - XY');     elseif ~IS_TA    title('US Image - XY');end
        
%         ss=medfilt2(squeeze(max(abs(ROI(:,:,220:end)),[],3)),'symmetric');
%         ss=ss-min(min(ss));
%         figure, imagesc([0 yLim(2)-yLim(1)],[0 xLim(2)-xLim(1)],ss(1:end,1:end));colormap jet; h_temp = colorbar;xlabel(h_temp,'/mV');axis image;
%         xlabel('X axis (mm)'), ylabel('Y axis (mm)');
%         if IS_TA    title('TA Image - XY');     elseif ~IS_TA    title('US Image - XY');end
% %         
        ss=medfilt2(squeeze(max(ROI_hilbert,[],1)),'symmetric');
        ss=ss-min(min(ss));
        subplot(3, 2, 2),
        if IS_TA    
            imagesc([yLim(1) yLim(2)],SoS.*1e6.*Slice_T1+[0 SoS.*1e6.*Delta_tt_], ss(1:end,1:end)');
            title('TA Image - YZ');     
        elseif ~IS_TA    
            imagesc([yLim(1) yLim(2)],(SoS.*1e6.*Slice_T1+[0 2.*SoS.*1e6.*Delta_tt_])./2, ss(1:end,1:end)');
            title('US Image - YZ');
        end
        colormap jet; h_temp = colorbar;xlabel(h_temp,'/mV');axis image;
        xlabel('Y axis (mm)'), ylabel('Z-temporal axis (mm)');
        
        ss=medfilt2(squeeze(max(ROI_hilbert,[],2)),'symmetric');
        ss=ss-min(min(ss));
        subplot(3, 2, 3),
        if IS_TA    
            imagesc([xLim(1) xLim(2)],SoS.*1e6.*Slice_T1+[0 SoS.*1e6.*Delta_tt_], ss(1:end,1:end)');
            title('TA Image - XZ');     
        elseif ~IS_TA    
            imagesc([xLim(1) xLim(2)],(SoS.*1e6.*Slice_T1+[0 2.*SoS.*1e6.*Delta_tt_])./2, ss(1:end,1:end)');
            title('US Image - XZ');
        end
        colormap jet; h_temp = colorbar;xlabel(h_temp,'/mV');axis image;
        xlabel('X axis (mm)'), ylabel('Z-temporal axis (mm)');
end
% if (~IS_TA)    Window=Window*2;  end% title('US B scan');



% show Bscan


if IS_TA
    if X==1
        Lim = yLim;
        ds = dy;
        subplot(3, 2, 4),imagesc(tt_ROI*1e6,Lim,abs(squeeze(ROI(1,:,:))));  grid on; grid minor;
        ROI=reshape(ROI,size(ROI,2)*size(ROI,1),size(ROI,3));
    elseif Y==1
        Lim = xLim;
        ds = dx;
        subplot(3, 2, 4),imagesc(tt_ROI*1e6,Lim,abs(squeeze(ROI(:,1,:))));  grid on; grid minor;
        ROI=reshape(ROI,size(ROI,2)*size(ROI,1),size(ROI,3));
    else
        Lim = [0,diff(xLim).*(diff(yLim)./dy)];
        ROI=reshape(ROI,size(ROI,2)*size(ROI,1),size(ROI,3));
        subplot(3, 2, 4),imagesc(tt_ROI*1e6,Lim,abs(squeeze(ROI(:,:,:))));  grid on; grid minor;
%         ROI=reshape(ROI,X,Y,Z);
    end
    title('TA B-scan');
    
elseif ~IS_TA
    if X==1
        Lim = yLim;
        ds = dy;
        subplot(3, 2, 4),imagesc(tt_ROI*1e6,Lim,abs(squeeze(ROI(1,:,:))));  grid on; grid minor;
        ROI=reshape(ROI,size(ROI,2)*size(ROI,1),size(ROI,3));
    elseif Y==1
        Lim = xLim;
        ds = dx;
        subplot(3, 2, 4),imagesc(tt_ROI*1e6,Lim,abs(squeeze(ROI(:,1,:))));  grid on; grid minor;
        ROI=reshape(ROI,size(ROI,2)*size(ROI,1),size(ROI,3));
    else
        Lim = [0,diff(xLim).*(diff(yLim)./dy)];
        ROI=reshape(ROI,size(ROI,2)*size(ROI,1),size(ROI,3));
        subplot(3, 2, 4),imagesc(tt_ROI*2e6,Lim,abs(squeeze(ROI(:,:,:))));  grid on; grid minor;
%         ROI=reshape(ROI,X,Y,Z);
    end
    title('US B-scan');
end

xlabel('Time (\mus)'); ylabel('Traveling Range (mm)'); grid on; grid minor;
h_cbar=colorbar; colormap jet; xlabel(h_cbar,'(mVolt)');
 
 % show the original max amplitude sequence
[ans, Max_ind] = max((peak2peak(ROI,2)),[],1);
%  Max_ind = Max_ind -10;
Max_seq = ROI(Max_ind,:);
[ans, Max_ind] = max(abs(Max_seq));

 % show the SNR/SNB of the signal
[ans, Max_ind] = max(Max_seq);

if IS_TA
    Sig_t1 = (Max_ind*dt-0.618*0.025e-6*2+tt_ROI(1));
    Sig_t2 = (Max_ind*dt+1.382*0.025e-6*2+tt_ROI(1));
elseif ~IS_TA
    Sig_t1 = (Max_ind*dt-0.618*0.05e-6*2+tt_ROI(1));
    Sig_t2 = (Max_ind*dt+1.382*0.05e-6*2+tt_ROI(1));
end
    
if Sig_t1 < tt_ROI(1) Sig_t1=tt_ROI(1); end
if Sig_t2 > tt_ROI(end) Sig_t2=tt_ROI(end); end

std_s = rms(Max_seq((tt_ROI>Sig_t1)&(tt_ROI<Sig_t2)));
std_n = std(Max_seq((tt_ROI<Sig_t1)|(tt_ROI>Sig_t2)),1);
SNR_dB = 20*log10(std_s./std_n);
SNR_Pratio = 10^(SNR_dB./10);
if IS_TA
    fprintf('TA signal SNR in dB: \t %.3g . \t Power ratio: \t %.3g\n', SNR_dB, SNR_Pratio);
elseif ~IS_TA
    fprintf('US signal SNR in dB: \t %.3g . \t Power ratio: \t %.3g\n', SNR_dB, SNR_Pratio);
end

if IS_TA
    subplot(3, 2, 5),plot(tt_ROI*1e6,Max_seq);
    axis([min(tt_ROI(:))*1e6 max(tt_ROI(:))*1e6 -max(abs(Max_seq(:))) max(abs(Max_seq(:)))]);
elseif ~IS_TA
    subplot(3, 2, 5),plot(2*tt_ROI*1e6,Max_seq);
    axis([min(2*tt_ROI(:))*1e6 max(2*tt_ROI(:))*1e6 -max(abs(Max_seq(:))) max(abs(Max_seq(:)))]);
    Sig_t1 = 2*Sig_t1;
    Sig_t2 = 2*Sig_t2;
end
title(sprintf(['Maximum seuqnece' ' - ' 'SNR ' num2str(SNR_dB)  ' dB,' ' SNR (Power) ' num2str(SNR_Pratio)]));xlabel('Time (us)'); ylabel('Signal Amplitude (mV)');
grid on; grid minor;
hline([mean(Max_seq((tt_ROI<Sig_t1)|(tt_ROI>Sig_t2)))+std_n mean(Max_seq((tt_ROI<Sig_t1)|(tt_ROI>Sig_t2)))-std_n],{'r' 'r'}); 
vline([Sig_t1 Sig_t2]*1e6,{'g' 'g'});

% show the FFT of the max sequence
fLim = 250;
[f, fd_abs] = mySpectrum(tt_ROI,Max_seq);
%  f = (f./max(f(:)).*Fs)./1e6; % convert dimension from Hz to MHz
f = (f)./1e6; % convert dimension from Hz to MHz
subplot(3, 2, 6),plot(f(f<=fLim),fd_abs((f<=fLim)));
axis([min(f(:)) fLim min(fd_abs) max(fd_abs)]);
title('FFT of Maximum seuqnece'); xlabel('Frequency (MHz)'); ylabel('FFT Amplitude (Volt)'); grid on; grid minor;

annotation('textbox',[2/5 0 1 1],'String',['Frequency Components ' num2str(reconParams.f_BP(1)./1e6) '-' num2str(reconParams.f_BP(2)./1e6) ' MHz'],'FitBoxToText','on');
drawnow;
% ROI=medfilt3(single(reshape(ROI,X,Y,size(ROI,2))));
ROI = double(reshape(ROI,X,Y,Z));
