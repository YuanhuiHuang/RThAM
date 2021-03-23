function [S, BW, fpeak, f] = SimulateFvsDepth(depth_min, depth_max, depth_step, d, doPlot, solid, ...
                                   object, f_max, nSamples, Norm, v_abs, rho_abs, ...
                                   convolution, FWHM_pulse, bandpass, BP_low, BP_up, ...
                                   order, type)
if nargin < 19
    type = 1;
end
if nargin < 18
    order = 3;
end
if nargin < 17
    BP_low = 44;
    BP_up  = 152;
end
if nargin < 15
    bandpass = 0;
end
if nargin < 14
    FWHM_pulse = 0.9;
end
if nargin < 13
    convolution = 1;
end
if nargin < 12
    v_abs   = 2200;
    rho_abs = 1140;
end
if nargin < 10
    Norm = 1;
end
if nargin < 9
    nSamples = 8;
end
if nargin < 8
    f_max = 300;
end
if nargin < 7
    object = 1;
end
if nargin < 6
    solid = 1;
end
if nargin < 5
    doPlot = 1;
end
if nargin < 4
    d = 10;
end
      
water = 1;

if water
    z_t = 0;
    z_w = depth_min;
else
    z_t = depth_min;
    z_w = 1650;
end

[p, t, fp, f] = SimulateSignal(d, solid, object, v_abs, rho_abs, convolution, ...
                    FWHM_pulse, 1, z_t, z_w, nSamples, d/2*1e-6);

if bandpass
    [p, fp, f, bw6] = SimulateBandpass(p, t, BP_low, BP_up, order, type);
end

L_f = length(f(f <= f_max));
             
S     = zeros((depth_max-depth_min)/depth_step, L_f);
BW    = zeros(1, (depth_max-depth_min)/depth_step);
fpeak = zeros(1, (depth_max-depth_min)/depth_step);
i     = 0;

for depth = depth_min:depth_step:depth_max
    i = i + 1;
    
    [p, t, fp, f] = SimulateSignal(d, solid, object, v_abs, rho_abs, convolution, ...
                    FWHM_pulse, 1, 0, depth, nSamples, d/2*1e-6);

    if bandpass
        [p, fp, f, bw6] = SimulateBandpass(p, t, BP_low, BP_up, order, type);
    end
              
    fp = fp(1:L_f);
    
    if Norm
        fp = fp/max(fp);
    end
             
    S(i,:)     = fp;
    BW(1,i)    = bw6;
    maxf       = f(fp == max(fp));
    fpeak(1,i) = maxf(1);
end

if doPlot
    figure('units', 'normalized', 'position', [0.24, 0.22, 0.5, 0.65]);
    imagesc([0 f_max], [depth_min depth_max], S); colormap jet;
    
    xlabel(gca, 'f (MHz)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 20);
    ylabel(gca, 't_{pulse} (ns)', 'FontWeight', 'bold', 'units', 'normalized', ...
        'FontSize', 20);
    set(gca, 'units', 'normalized', 'FontSize', 15);
end

end