%% [f,fd_abs] = mySpectrum(t,d)
%% figure,plot(f,2*abs(fd(1:(2^nextpow2(length(t)))/2+1)))
function [f,fd_abs, fd_angle] = mySpectrum(t,d,is_dB)

% L = size(d,1);
L=length(t);
dt = t(5)-t(4);
fs = 1/dt;
NFFT = 2^nextpow2(L);
df=fs/NFFT;
f = fs/2*linspace(0,1,NFFT/2+1);
fd = fft(d,NFFT)./fs;
% correct for Parseval's theorem
    fd(1)=fd(1)/2;
    fd(end)=fd(end)/2;
    
if nargin==2
    is_dB=0;
end

if is_dB==0
    fd_abs=2.*abs(fd(1:NFFT/2+1)); % amplitude |S(f)| V
    %Checking Parseval's Theorem
    energy_x=sum(d.*conj(d)*dt);
%     energy_YA=sum(fd_abs.*conj(fd_abs)*df);
    energy_YA = (fd_abs(1)^2 + (1/2)*sum(fd_abs(2:end-1).^2) + fd_abs(end)^2)*df;
    eDiff=energy_x-energy_YA;
elseif is_dB==1
    fd_abs=1/2.*(abs(fd(1:NFFT/2+1)).*2).^2; % power density |S(f)|^2 V^2
elseif is_dB==2
    fd_abs=10.*log10(1/2.*(abs(fd(1:NFFT/2+1)).*2).^2); % dB
elseif is_dB==3
    fd_abs=10.*log10(1/2.*(abs(fd(1:NFFT/2+1)).*2).^2./50./1e-3); % dBm
end
fd_angle = angle(fd(1:NFFT/2+1));
% figure,plot(f,fd_abs);


end
