
% s=squeeze(SS_no(304,443,:));
s=squeeze(S_(:,1));
s=double(s);

dt = 0.05;
% s = S_(42,:);
t=trigDelay*dt+dt:dt:(trigDelay+size(s,1))*dt;
t=t';

[ans Index] = max(abs(s));
t0 = Index;
index = 1:1:size(s,1);

gaussWin = exp(-(index- t0).^2/15^2);

ss = s'.*gaussWin;
ss=s;
ssF = fftshift(fft(ifftshift(ss)));

f = linspace(-1/2/dt,1/2/dt,length(ssF));

figure,plot(f,abs(ssF));
