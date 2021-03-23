%% acquiring 1 sequence
% Setup(daq, segCount, trigDelay, inputRange, nSegments, 'Single', detType);

saveName = 'Focal_Length_TAM';

daq = gageInit();
Fs = 1e9;
dt = 1/Fs;
t_0 = 33e-6;    % us
t_end = 39e-6;  % us
trigDelay = t_0 * Fs;
endpoint = t_end * Fs;
t = [t_0+dt:dt:t_end];
nSegments = (endpoint - trigDelay) / 32;
Setup(daq, 1, trigDelay, 1000, nSegments, 'Single', 'TAM100'); % set the values
ret = CsMl_Commit(daq); % make setting for daq
CsMl_ErrorHandler(ret, 1, daq);
% freeGage(daq)

N = 100;    % z stage range from 19 mm to 23.95 mm, step 0.05 mm
z_stage = [19:0.05:23.95];
sAvg = zeros(N,size(t,2));

figure,
for n=91:N
    prompt='9 to figure, 1 to continue, 0 to stop: ';
    key = input(prompt);
    if key~=0
        [sAvg(n,:), t_acq, t_tot] = gageAcq(daq, 0, 1024);
    end
    if key==9
        plot(t,sAvg(n,:));
        n
    end
    if key==0
        n
        break;
    end
end
S = sAvg;
[ss I] = max(S,[],2);
t_I = t(I)';
[ss_max I_] = max(ss,[],2);
focal_d = (I_-1)*0.05 + 19;   % focal spot at z stage 20.7 mm
focal_t = (I(35) + trigDelay) * dt;     % focal time point at 36.698 us
figure,plot(flipud(t_I),flipud(ss))