function signals(S, F_s, trigDelay, ChebyFlag, BandpFlag, x1, x2)
S = single(S);

t_foc = 1.86e-6;
v_s   = 1510;

Ntime = size(S,2);

if ChebyFlag
    [b, a] = cheby1(4, .01, 2*0.01, 'high');
    
    for j = 1:Ntime
        ss = squeeze(double(S(:, j)));
        S(:, j) = single(filtfilt(b, a, ss));
    end
end

if BandpFlag
    S = S';
    
    dt = 1/F_s;
    t_0 = 0:dt:(Ntime-1)*dt;
    t_0 = t_0 + trigDelay*dt - t_foc;
    
    for i = 1:size(S,1)
        S_filt = filterData(S(:,i), t_0, [25e6 125e6], 'BP');
        S(:,i) = S_filt;
    end
    
    S = S';
end
    
if nargin < 6
    Samp1 = 1;
    Samp2 = Ntime;
else
    Samp1 = ceil((x1*1e-6/v_s + t_foc)*F_s - trigDelay);
    Samp2 = ceil((x2*1e-6/v_s + t_foc)*F_s - trigDelay);
end

figure('units', 'normalized', 'position', [0.004 0.03 0.992 0.9]);

imagesc(([(trigDelay+Samp1) (trigDelay+Samp2)]/F_s-t_foc)*v_s*1e6, [], ...
        S(:,Samp1:Samp2));
    
colormap(gray);

xlabel('z - z_{Foc} (µm)', 'FontWeight', 'bold', 'FontSize', 16);
ylabel('Position (a.u.)', 'FontWeight', 'bold', 'FontSize', 16);
set(gca, 'units', 'normalized', 'FontSize', 13);
end