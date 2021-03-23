%% Total averaging -- show code   
Fs = 500e6;
dt = 1/Fs;
trigDelay=trigDelay*1/Fs;
tt_ = (trigDelay+dt):dt:trigDelay+dt*size(S,2);



F_SEQ_Max = counter;
% F_SEQ_Max = 51;
SS_F=zeros(F_SEQ_Max,(2^nextpow2(length(tt_)/2))+1);
tic
for f_seq=1:F_SEQ_Max
    if ~rem(f_seq,500)
        toc
    end
    [f,SS_F(f_seq,:)] = mySpectrum(tt_,SS(f_seq,:),3);  % 2 for dB; 3 for dBm
end

fd_abs = mean(SS_F,1);

fcut=[0e3, 250e6];
figure1 = figure;axes1 = axes('Parent',figure1);
plot(f(f>=fcut(1) & f<=fcut(2))./1e6,fd_abs(f>=fcut(1) & f<=fcut(2)));xlabel('Frequency / MHz'); ylabel('Amplitude / dBm');
title('Total Averaging Spectrum 1k-250MHz');
% ylim(axes1,[-145 -115]);
xlim(axes1,fcut./1e6);
grid on;

fcut=[0e6, 100e6];
figure1 = figure;axes1 = axes('Parent',figure1);
plot(f(f>=fcut(1) & f<=fcut(2))./1e6,fd_abs(f>=fcut(1) & f<=fcut(2)));xlabel('Frequency / MHz'); ylabel('Amplitude / dBm');
title('Total Averaging Spectrum 0-100MHz');
% ylim(axes1,[-145 -125]);
xlim(axes1,fcut./1e6);
grid on;

%% Moving averaging
% Fs = 500e6;
% dt = 1/Fs;
% trigDelay=trigDelay*1/Fs;
% tt_ = (trigDelay+dt):dt:trigDelay+dt*size(S,2);
% 
% figure1 = figure;axes1 = axes('Parent',figure1);
% plot(f(f>=1000),fd_abs(1,f>=1000),f(f>=1000),fd_abs(2,f>=1000));xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
% legend('Current','Accumulation'); title('Spectrum');ylim(axes1,[-240 -80]);grid on;

% figure,plot(tt_,S(1,:),tt_,S(2,:));xlabel('Time / \muS'); ylabel('Amplitude / Volt');
% legend('Current','Accumulation'); title('Raw sequence');grid on;

% i=2;
% 
% fcut=[1e3, 20e6];
% figure1 = figure;
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% plot(f(f>=fcut(1) & f<=fcut(2)),fd_abs(i,(f>=fcut(1) & f<=fcut(2))));
% xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
% title('Accumulation Spectrum 0-20 MHz');
% ylim(axes1,[-240 -80]);
% box(axes1,'on');    grid(axes1,'on');
%        
% fcut=[20e6, 70e6];
% figure1 = figure;
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% plot(f(f>=fcut(1) & f<=fcut(2)),fd_abs(i,(f>=fcut(1) & f<=fcut(2))));
% xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
% title('Accumulation Spectrum 20-70 MHz');
% ylim(axes1,[-240 -80]);
% box(axes1,'on');grid(axes1,'on');
%        
% fcut=[70e6, 120e6];
% figure1 = figure;
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% plot(f(f>=fcut(1) & f<=fcut(2)),fd_abs(i,(f>=fcut(1) & f<=fcut(2))));
% xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
% title('Accumulation Spectrum 70-120 MHz');
% ylim(axes1,[-240 -80]);
% box(axes1,'on');grid(axes1,'on');

% fcut=[120e6, 170e6];
% figure1 = figure;
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% plot(f(f>=fcut(1) & f<=fcut(2)),fd_abs(i,(f>=fcut(1) & f<=fcut(2))));
% xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
% title('Accumulation Spectrum 120-170 MHz');
% ylim(axes1,[-240 -80]);
% box(axes1,'on');grid(axes1,'on');
% 
% fcut=[170e6, 220e6];
% figure1 = figure;
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% plot(f(f>=fcut(1) & f<=fcut(2)),fd_abs(i,(f>=fcut(1) & f<=fcut(2))));
% xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
% title('Accumulation Spectrum 170-220 MHz');
% ylim(axes1,[-240 -80]);
% box(axes1,'on');grid(axes1,'on');
% 
% fcut=[220e6, 250e6];
% figure1 = figure;
% axes1 = axes('Parent',figure1);
% hold(axes1,'on');
% plot(f(f>=fcut(1) & f<=fcut(2)),fd_abs(i,(f>=fcut(1) & f<=fcut(2))));
% xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
% title('Accumulation Spectrum 220-250 MHz');
% ylim(axes1,[-240 -80]);
% box(axes1,'on');grid(axes1,'on');

% 
% zz=[168:1150];
% tt=tt_(zz);
% 
% seq(1,:)=squeeze(S(103,33,zz));
% seq(2,:)=squeeze(S(123,33,zz));
% figure,plot(tt_(1,zz),seq(1,:),tt_(1,zz),seq(2,:));xlabel('Time/\muS');ylabel('Amplitude/mV');
% legend('Background','TAS pulse'); title('Raw');
% [f,fd_abs(1,:)] = mySpectrum(tt,seq(1,:),2);
% [f,fd_abs(2,:)] = mySpectrum(tt,seq(2,:),2);
% figure,plot(f(f<=100e6),fd_abs(1,f<=100e6),f(f<=100e6),fd_abs(2,f<=100e6));xlabel('Frequency / Hz'); ylabel('Amplitude / dBm');
% legend('Background','TAS pulse'); title('Spectrum');
%%
