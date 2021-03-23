close all;
% 
c = 1.5; % Speed of sound in mim/us
dst = 150;   % Estimation of distance between element and object
tw = 2*dst/1.5*1e-6;  % set the field of view in us acoording to 2*dst 
                   % between element and object
fw = 7e6;   % set the frequency window from 0 to 7 MHz
tr = 0e-6; % relaxation time of transducer in us

% load oil

dn = bandpass(t,d,6.2e6,5.5e6);
dn(t<=tr) = 0;
dn(t>=tw) = 0;
%subplot(1,2,2),
figure;plot(t(t<=tw),dn(t<=tw));

figure;plot(t(t>=16e-6 & t<=60e-6),dn(t>=16e-6 & t<=60e-6));

fs = 1/(t(2)-t(1));
[f,fd] = mySpectrum(t,dn);
L = size(d,1);NFFT = 2^nextpow2(L);
a = figure(1); 
%subplot(1,2,1),
figure;plot(f(f<=fw),2*abs(fd(f<=fw)));
set(a,'name','Reference');

