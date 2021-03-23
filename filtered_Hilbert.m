function [T_hilbert, T_filt] = filtered_Hilbert(T, Fs, OA_Dark)
%% v1.0 yuanhui 20190214
% remove dark background, filter, and Hilbert transform
if nargin == 2
    OA_Dark = 0;
end
T_hilbert = zeros(size(T));
T_filt = T_hilbert;
if sum(OA_Dark) ~= 0 % if have OA_Dark measured to remove background noise
    T_hilbert_Dark = filtS(squeeze(OA_Dark), 1./Fs, 0.1e6, 7e6);
    if size(T_hilbert_Dark,1) == size(T_hilbert,2)
        T_hilbert_Dark = ((abs(hilbert(T_hilbert_Dark)))); 
    else 
        T_hilbert_Dark = mean((abs(hilbert(T_hilbert_Dark))),1); 
    end
%     tic
    parfor iinWL=1:1:size(T,1)
%     for iinWL=1:1:size(T,1)
        T_filt(iinWL,:,:) = filtS(squeeze(T(iinWL,:,:)), 1./Fs, 0.1e6, 7e6);
        T_hilbert(iinWL,:,:) = abs(hilbert(squeeze(T_filt(iinWL,:,:))));
        T_hilbert(iinWL,:,:) = (bsxfun(@minus,(squeeze(T_hilbert(iinWL,:,:))),(T_hilbert_Dark))); % Reduced the noise floor
        T_hilbert(iinWL,:,:) = medfilt1(T_hilbert(iinWL,:,:),3,[],3); % this is to remove outlier numbers induced when dark removal
    end
%     toc
    T_hilbert(T_hilbert<0) = 0;
elseif sum(OA_Dark) == 0
    parfor iinWL=1:1:size(T,1)
%     for iinWL=1:1:size(T,1)
        T_filt(iinWL,:,:) = filtS(squeeze(T(iinWL,:,:)), 1./Fs, 0.1e6, 7e6);
        T_hilbert(iinWL,:,:) = abs(hilbert(squeeze(T_filt(iinWL,:,:))));
    end
end
