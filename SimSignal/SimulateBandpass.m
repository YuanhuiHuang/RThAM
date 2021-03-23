function [pFilt, pfFilt, fFilt, BW6dB, BW3dB, pFilt0, pfFilt0, fFilt0] = ...
         SimulateBandpass(p, t, f_TD_min, f_TD_max, order, type, BP_SW, f_SW_min, f_SW_max)

if nargin < 9
     f_SW_min = 20;
     f_SW_max = 180;
end
if nargin < 7
    BP_SW = 0;
end
if nargin < 6
    type = 1;
end
if nargin < 5
    order = 3;
end
if nargin < 4
    f_TD_min = 44;
    f_TD_max = 152;
end

if BP_SW
    if f_TD_min == 0
        pFilt0 = FilterFreq(p, t, [0 f_TD_max]*1e6, 'LP', 1, order, type);           % Apply causal TD lowpass filter on raw signal
    elseif f_TD_max == 0
        pFilt0 = FilterFreq(p, t, [f_TD_min 0]*1e6, 'HP', 1, order, type);           % Apply causal TD highpass filter on raw signal
    else
        pFilt0 = FilterFreq(p, t, [f_TD_min f_TD_max]*1e6, 'BP', 1, order, type);    % Apply causal TD bandpass filter on raw signal
    end
        
    [pfFilt0, fFilt0] = FFT_t2f(pFilt0, t);                                          % AS of TD bandpass filtered signal
    pfFilt0           = abs(pfFilt0);
    
    if f_SW_min == 0
        pFilt = FilterFreq(pFilt0, t, [0 f_SW_max]*1e6, 'LP', 0, order, type);       % Apply phase-0 software lowpass filter on signal
    elseif f_SW_max == 0
        pFilt = FilterFreq(pFilt0, t, [f_SW_min 0]*1e6, 'HP', 0, order, type);       % Apply phase-0 software highpass filter on signal
    else
        pFilt = FilterFreq(pFilt0, t, [f_SW_min f_SW_max]*1e6, 'BP', 0, order, type);% Apply phase-0 software bandpass filter on signal
    end

    [pfFilt, fFilt] = FFT_t2f(pFilt, t);                                             % AS after all BP filters
    pfFilt          = abs(pfFilt);
    
    [BW6dB, BW3dB] = CalculateBandwidth(pfFilt, fFilt);
else
    if f_TD_min == 0
        pFilt = FilterFreq(p, t, [0 f_TD_max]*1e6, 'LP', 1, order, type);            % Apply causal TD lowpass filter on signal
    elseif f_TD_max == 0
        pFilt = FilterFreq(p, t, [f_TD_min 0]*1e6, 'HP', 1, order, type);            % Apply causal TD highpass filter on signal
    else
        pFilt = FilterFreq(p, t, [f_TD_min f_TD_max]*1e6, 'BP', 1, order, type);     % Apply causal TD bandpass filter on signal
    end
    
    [pfFilt, fFilt] = FFT_t2f(pFilt, t);                                             % AS of TD bandpass filtered signal
    pfFilt          = abs(pfFilt);
    
    [BW6dB, BW3dB]  = CalculateBandwidth(pfFilt, fFilt);

    pFilt0  = pFilt;
    pfFilt0 = pfFilt;
    fFilt0  = fFilt;
end
end