function s = filtData(s,Fs,fLim)
Ndata = length(s);
f = linspace(-Fs/2,Fs/2,Ndata);
s = fftshift(fft(ifftshift(s)));
filtOrder = 4;
filt = exp(-(f/fLim(2)).^filtOrder).*(1- exp(-(f/fLim(1)).^filtOrder));

if size(s,1)>1 
    filt = filt.';
end
s = s.*filt;
s = real(fftshift(ifft(ifftshift(s))));


