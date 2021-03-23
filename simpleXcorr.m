addpath('C:\Users\yuanhui\MATLAB\TAM\trigger_DG1000Z')
F1   = 6e6; 
F2    = 10e6;
T   = 200e-3;
Sample_rate = 50e6; dt = 1/Sample_rate; % seconds
isShow = false;
[s1,t1,X1] = createLinChirp(dt,F1,F2,T,isShow);

clear Sxcorrf
parfor ii=1:1:size(SS,1)
    Sxcorrf(ii,:) = xcorr(X1,SS(ii,:));
end
% figure,imagesc(Sxcorrf)
figure,imagesc((abs(Sxcorrf)))


F1   = 12e6; 
F2    = 20e6;
T   = 200e-3;
Sample_rate = 50e6; dt = 1/Sample_rate; % seconds
isShow = false;
[s2,t2,X2] = createLinChirp(dt,F1,F2,T,isShow);

clear Sxcorr
parfor ii=1:1:size(SS,1)
    Sxcorr(ii,:) = xcorr(X2,SS(ii,:));
end
figure,imagesc((abs(Sxcorr)))

% figure,plot(Sxcorr(20,:))
% figure,plot(SS(20,:))
