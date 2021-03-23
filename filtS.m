function Sfilt = filtS(S,dt,ds,FilterFlag)
% if FilterFlag==1
    Ns = size(S,1);
    Nt = size(S,2);

    f    = linspace(-1/2/dt,1/2/dt,Nt);
%     fHPF = 20e6;
%     fLPF = 100e6;
    fHPF = 5e6;
    fLPF = 75e6;
    filt = exp(-(f/fLPF).^16).*(1- exp(-(f/fHPF).^4));
    filt = repmat(filt, [Ns 1]);

    Sfilt = fftshift(fft(ifftshift(S,2),[],2),2);
    Sfilt = Sfilt.*filt;
    Sfilt = real(fftshift(ifft(ifftshift(Sfilt,2),[],2),2));
    
if FilterFlag==2
%     S = Sfilt;
    Ns = size(Sfilt,1);
    Nt = size(Sfilt,2);

    f    = linspace(-1/2/ds,1/2/ds,Ns);
    fHPF = max(f)./10;
    fLPF = max(f);
    filt = exp(-(f/fLPF).^16).*(1- exp(-(f/fHPF).^4));
%     filt = (1- exp(-(f/fHPF).^4));
    filt = repmat(filt', [1 Nt]);

    Sfilt = fftshift(fft(ifftshift(Sfilt,1),[],1),1);
    Sfilt = Sfilt.*filt;
    Sfilt = real(fftshift(ifft(ifftshift(Sfilt,1),[],1),1));
%     Sfilt = Sfilt';
%     figure,imagesc(Sfilt),colormap jet;colorbar; grid on
end
