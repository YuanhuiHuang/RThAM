%% [f,fd_abs] = mySpectrum(t,d)
%% figure,plot(f,2*abs(fd(1:(2^nextpow2(length(t)))/2+1)))
function [f,fd_abs] = mySpectrum2D(t,d,is_dB)

% L = size(d,1);
L=length(t);
fs = 1/(t(5)-t(4));
NFFT = 2^nextpow2(L);
f = fs/2*linspace(0,1,NFFT/2+1);
fd = fft(d,NFFT,2)./L;


if nargin==2
    is_dB=0;
end

if is_dB==0
    fd_abs=2.*abs(fd(:,1:NFFT/2+1)); % |S(f)| V
elseif is_dB==1
    fd_abs=2.*(abs(fd(:,1:NFFT/2+1))).^2; % |S(f)|^2 V^2
elseif is_dB==2
    fd_abs=10.*log10(2.*(abs(fd(:,1:NFFT/2+1))).^2); % dB
elseif is_dB==3
    fd_abs=10.*log10(2.*(abs(fd(:,1:NFFT/2+1))).^2./50./1e-3); % dBm
end
% figure,plot(f,fd_abs);
end
