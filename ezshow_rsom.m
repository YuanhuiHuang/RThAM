%
% clear all; close all;
% DIR = 'C:\Users\Chucheng\Documents\MATLAB\TAM\DATA4T\';
% File = '201611171612_TAM_NOilLine50_deeper8dayFish_10kV_V3330_TAM_98-236us_AVG1024_273';
% FullPath = [DIR File];
% mkdir(FullPath);
% load([FullPath '.mat']);
is_rsom = 0;

Fs = 500e6;
dt = 1/Fs;
% tDelay = 25e-6;

tDelay=trigDelay*1/Fs;
tt_ = (tDelay+dt):dt:(tDelay+dt*size(S,2));
% dz = 0.05;
% Lz = (size(S,1)-1).*dz;
% ZZ_ = [0:dz:Lz];
X = int16((xLim(2)-xLim(1))/dx+1);
Y = int16((yLim(2)-yLim(1))/dy+1);

% Slice_T = 9.8e-6; Window = 11.5e-6;
% Slice_T = 19.6e-6; Window = 4e-6;
% % Slice_T = 20e-6; Window = 23e-6;
% Slice_T = 17.4e-6; Window = 0.4e-6;
% Slice_T = 8.1e-6; Window = 1e-6; % WOilLine
Slice_ROI1 = (2.5e-6).*2; Slice_ROI2 = (3.173e-6).*2; 
Window = Slice_ROI2 - Slice_ROI1; % WOilLine
% Slice_T = 10e-6; Window = 2e-6; % Oil2Line
% Slice_T = 20e-6; Window = 4e-6; % Oil2Line

% Slice_T1=11.8e-6; Slice_T1_Gap=9.8e-6;
% Slice_T2=19.6e-6; Slice_T2_Gap=23.6e-6;
% Slice_T2=19e-6; Slice_T2_Gap=23e-6;
% Slice_T1=9.1e-6; Slice_T1_Gap=8.1e-6; % WOilLine
Slice_T11=1.5e-6; Slice_T12=3.5e-6; % WOilLine
Slice_T21=3.5e-6; Slice_T22=6.5e-6;
% Slice_T1=12e-6; Slice_T1_Gap=9e-6; % Oil2Line
% Slice_T2=19e-6; Slice_T2_Gap=24e-6;
if is_rsom==1
    if Slice_ROI2 <=Slice_T12   % TA
        SS = double(S(:,((tt_>=Slice_T11)&(tt_<=Slice_T12)))).* InputRange ./ 2^15; % mV
        tt_ = tt_((tt_>=Slice_T11)&(tt_<=Slice_T12));
    elseif Slice_ROI2 >Slice_T21    %US
        SS = double(S(:,((tt_>=Slice_T21)&(tt_<=Slice_T22)))).* InputRange ./ 2^15; % mV
        tt_ = tt_((tt_>=Slice_T21)&(tt_<=Slice_T22));
        tDelay=trigDelay*1/Fs;
    end
    SS=double(reshape(SS,X,Y,size(SS,2)));
    SS = SS(1:2:end,1:2:end,:);
    X = size(SS,1);
    Y = size(SS,2);
    SS=reshape(SS,X*Y,size(SS,3));
    dx=dx*2;
elseif is_rsom==0
    if Slice_ROI2 <=Slice_T12
        SS = double(S(:,((tt_>=Slice_T11)&(tt_<=Slice_T12)))).* 1000; % mV
        tt_ = tt_((tt_>=Slice_T11)&(tt_<=Slice_T12));
    elseif Slice_ROI2 >=Slice_T21
        SS = double(S(:,((tt_>=Slice_T21)&(tt_<=Slice_T22)))).* 1000; % mV
        tt_ = tt_((tt_>=Slice_T21)&(tt_<=Slice_T22));
        tDelay=trigDelay*1/Fs;
    end
%     SS = double(S) .* 1000; % mV
end
% 
% clear tt_

tic
SS = filtS(SS,dt,dx,2);
% toc


SS=double(reshape(SS,X,Y,size(SS,2)));

% ss=max(abs(SS(:,:,1:end)),[],3);
% tt_Slice = tt_(((tt_>Slice_T)&(tt_<Slice_T+Window)));
% ss=peak2peak(SS(:,:,((tt_>Slice_T)&(tt_<Slice_T+Window))),3);
% ss=peak2peak(SS(:,:,:),3);
% ss=medfilt2(max(abs(SS(:,:,((tt_>Slice_T)&(tt_<Slice_T+Window)))),[],3));
ss=max(abs(SS(:,:,((tt_>Slice_ROI1)&(tt_<Slice_ROI1+Window)))),[],3);
% ss = ss - abs(std(ss(:)));
% ss(ss<0) = 0;
% figure,imagesc([0 xLim(2)-xLim(1)],[0 yLim(2)-yLim(1)],ss(1:end,1:end)');colormap jet; h_temp = colorbar;xlabel(h_temp,'/mV');axis image;
figure,imagesc([0 yLim(2)-yLim(1)],[0 xLim(2)-xLim(1)],ss(1:end,1:end));colormap jet; h_temp = colorbar;xlabel(h_temp,'/mV');axis image;
if Slice_ROI2 <= Slice_T12
    title('TA Image');
elseif Slice_ROI2 > Slice_T21
    title('US Image');
end



% show Bscan
if X==1
    Lim = yLim;
    ds = dy;
    figure,imagesc(tt_,Lim,abs(squeeze(SS(1,:,:))));  grid on; grid minor;
elseif Y==1
    Lim = xLim;
    ds = dx;
    figure,imagesc(tt_,Lim,abs(squeeze(SS(:,1,:))));  grid on; grid minor;
else
    Lim = [0,xLim(2)+yLim(2)];
    SS=reshape(SS,X*Y,size(SS,3));
    figure,imagesc(tt_,Lim,abs(squeeze(SS(:,:,:))));  grid on; grid minor;
end

if Slice_ROI2 <= Slice_T12
    title('TA B scan');
elseif Slice_ROI2 > Slice_T21
    title('US B scan');
end

 xlabel('/\mus'); ylabel('/mm'); grid on; grid minor;
 h_cbar=colorbar; colormap jet; xlabel(h_cbar,'/mVolt');
 
 % show the original max amplitude sequence
 SS=squeeze(SS);
 Temp_seq = tt_.*1e6; % Second to micro second
 [Max_sig Max_ind] = max((peak2peak(SS,2)));
%  Max_ind = Max_ind -10;
 Max_seq = SS(Max_ind,:);
 Max_sig = max(abs(Max_seq));
 
 % show the FFT of the max sequence
 [f fd_abs] = mySpectrum(tt_,Max_seq);
 f = f./1e6; % convert dimension from Hz to MHz
 figure,plot(f,fd_abs);
 axis([min(f(:)) max(f(:)) min(fd_abs) max(fd_abs)]);
 title('FFT of Maximum seuqnece');xlabel('Frequency (MHz)'); ylabel('FFT Amplitude (Volt)');
 grid on; grid minor;
 
 % show the SNR/SNB of the signal
 if max(Temp_seq>Slice_T21.*1e6)
     [ans, Max_ind] = max(Max_seq);
     Sig_t1 = (Max_ind*dt-0.2e-6+min(Temp_seq)*1e-6)*1e6;
     Sig_t2 = (Max_ind*dt+0.2e-6+min(Temp_seq)*1e-6)*1e6;
 elseif max(Temp_seq<Slice_T12.*1e6)
     [ans, Max_ind] = max(Max_seq);
     Sig_t1 = (Max_ind*dt-0.1e-6+tDelay)*1e6;
     Sig_t2 = (Max_ind*dt+0.1e-6+tDelay)*1e6;
 end
%  Max_noise = max(Max_seq((Temp_seq<Sig_t1)|(Temp_seq>Sig_t2)));
%  SNR_dB = 20*log10(Max_sig./Max_noise)
% (Max_seq((Temp_seq<Sig_t1)|(Temp_seq>Sig_t2)))
std_s = rms(Max_seq((Temp_seq>Sig_t1)&(Temp_seq<Sig_t2)));
std_n = std(Max_seq((Temp_seq<Sig_t1)|(Temp_seq>Sig_t2)),1);
 SNR_dB = 20*log10(std_s./std_n)
 SNR_Pratio = 10^(SNR_dB./10)
 
 figure,plot(Temp_seq,Max_seq);
 axis([min(Temp_seq(:)) max(Temp_seq(:)) -max(abs(Max_seq)) max(abs(Max_seq))]);
 title('Maximum seuqnece');xlabel('Time (us)'); ylabel('Signal Amplitude (mV)');
 grid on; grid minor;
 addpath('../vline');
 h = hline([std_n -std_n],{'r' 'r'}); 
%  h = vline([find(tt_== Sig_t1*1e-6) find(tt_== Sig_t2*1e-6)],{'g' 'g'});
  h = vline([Sig_t1 Sig_t2],{'g' 'g'});
%  hline = refline([0 std_n]);
%  hline.Color = 'r';
%  hline = refline([0 -std_n]);
%  hline.Color = 'r';
%  hline = refline([Sig_t1 0]);
%  hline.Color = 'b';
% myTiff;
