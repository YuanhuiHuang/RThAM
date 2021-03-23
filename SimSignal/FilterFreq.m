function SF = FilterFreq(S, t, f_filt, type, phase, order, filttype)
if nargin < 7
    filttype = 1;
end
if nargin < 6
    order = 3;
end
if nargin < 5
    phase = 1;
end
if nargin < 4
    type = 'BP';
end

if numel(t) > 1
    Fs = 1/(t(2)-t(1));
else
    Fs = 1/t;
end

type = upper(type);

singleCheck = isa(S, 'single');

if singleCheck
    S = double(S);
end

if order > 4
    error '>> Filter order too high! <<'
end

% Apply Filters
switch type
    case 'LP'
        if filttype == 1
            [b,a] = butter(order, 2*f_filt(2)/Fs);
        else
            [b,a] = cheby1(order, .01, 2*f_filt(2)/Fs); % n = 8
        end
    case 'HP'
        if filttype == 1
            [b,a] = butter(order, 2*f_filt(1)/Fs, 'high');
        else
            [b,a] = cheby1(order, .01, 2*f_filt(1)/Fs, 'high'); % n = 4
        end
    case 'BP'
        if filttype == 1
            [b,a] = butter(order, 2*[f_filt(1) f_filt(2)]/Fs);
        else
            [b,a] = cheby1(order, .01, 2*[f_filt(1) f_filt(2)]/Fs);
        end
    case 'BS'
        [b,a] = butter(order, 2*[f_filt(1) f_filt(2)]/Fs, 'stop');
    otherwise
        error '>> Unknown filter type! <<';
end

switch phase
    case 0
        SF = filtfilt(b, a, S);                                                      % Uncausal phase-0 filter
    otherwise
        SF = filter(b, a, S);                                                        % Causal linear-phase filter
end

if singleCheck
    SF = single(SF);
end
end