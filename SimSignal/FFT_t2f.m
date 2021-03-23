function [S, f] = FFT_t2f(s, t)
n = 16;                                                                              % Length of time vector (determines f resolution)

dt_min = max(min(diff(t)), 1e-14);
dt_max = max(diff(t));

if dt_max > dt_min + eps
    nPts = round(max(t)/dt_min);
    t1   = linspace(0, max(t), nPts)';
    s1   = interp1(t, s, t1, 'linear');
    s    = s1;
    t    = t1;
end

dt   = t(2) - t(1);                                                                  % Assumes an equidistant sampling
Fs   = 1/dt;
% Fs = 5e9;
len  = length(t);

NFFT = n*2^nextpow2(len);

% s  = ifftshift(s);

S    = fft(s,NFFT);
S    = 2*S(1:NFFT/2+1);
f    = Fs/2*linspace(0, 1, NFFT/2+1);
end