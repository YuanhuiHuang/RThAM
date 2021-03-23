function [s, t] = FFT_f2t(S, f)
df   = f(2) - f(1);
T    = 1/df;
len  = length(f);
NFFT = 2^nextpow2(len);

% S  = ifftshift(S);

% s  = ifft(S, NFFT)/NFFT*len;
% s  = ifft(S, NFFT)*NFFT;
s    = ifft(S, NFFT, 'symmetric')*NFFT;                                              % symmetric assumes neg & pos freq. complex conjugated
s    = 2*s(1:NFFT);                                                                  % Important: Use full (not NFFT/2) spectrum (pos & neg)

t    = T/2*linspace(0, 1, NFFT);
end