function [S, f] = SimulateFvsPulse(pulse_min, pulse_max, pulse_step, d, doPlot, solid, ...
                                   object, f_max, nSamples, Norm, v_abs, rho_abs, bandpass, ...
                                   BP_low, BP_up, attenuation, z_t, z_w)
if nargin < 18
    z_t = 0;
    z_w = 1660;
end
if nargin < 16
    attenuation = 0;
end
if nargin < 15
    BP_low = 44;
    BP_up  = 152;
end
if nargin < 13
    bandpass = 0;
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
                      
[p, t, fp, f] = SimulateSignal(d, solid, object, v_abs, rho_abs, 1, ...
                    pulse_min, attenuation, z_t, z_w, nSamples, d/2*1e-6);

if bandpass
    [p, fp, f] = SimulateBandpass(p, t, BP_low, BP_up);
end

L_f = length(f(f <= f_max));
             
S   = zeros((pulse_max-pulse_min)/pulse_step, L_f);
i   = 0;

for FWHM_pulse = pulse_min:pulse_step:pulse_max
    i = i + 1;
    
    [p, t, fp, f] = SimulateSignal(d, solid, object, v_abs, rho_abs, 1, ...
                    FWHM_pulse, attenuation, z_t, z_w, nSamples, d/2*1e-6);

    if bandpass
        [p, fp, f] = SimulateBandpass(p, t, BP_low, BP_up);
    end
                
    if Norm
        fp = fp/max(fp);                                                             % Normalization of the amplitude spectra
    end
             
    S(i,:) = fp(1:L_f);
end

if doPlot
    figure('units', 'normalized', 'position', [0.24, 0.22, 0.5, 0.65]);
    imagesc([0 f_max], [pulse_min pulse_max], S); colormap jet;
    
    xlabel(gca, 'f (MHz)', 'FontWeight', 'bold', 'units', 'normalized', 'FontSize', 20);
    ylabel(gca, 't_{pulse} (ns)', 'FontWeight', 'bold', 'units', 'normalized', ...
        'FontSize', 20);
    set(gca, 'units', 'normalized', 'FontSize', 15);
end

end