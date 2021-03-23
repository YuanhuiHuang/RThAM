function [p, t, pf, f, g, p0, t0] = SimulateSignal(d, solid, object, v_abs, ...
                                    rho_abs, convolution, pulse_FWHM, ...
                                    attenuation, z_t, z_w, nSamples, R)

if nargin < 12                                
    R = 1e-9;
end
if nargin < 11
    nSamples = 4; % 2
end
if nargin < 9
    z_t = 0;
    z_w = 1650;
end
if nargin < 8
    attenuation = 1;
end
if nargin < 7
    pulse_FWHM = 0.9;
end
if nargin < 6
    convolution = 1;
end
if nargin < 4
    v_abs   = 2200;
    rho_abs = 1140;
end
if nargin < 3
    object = 1;
end
if nargin < 2
    solid = 0;
end
    
% Definitions
r       = d/2*1e-6;                                                                  % Diameter of the absorber [m]
v_sur   = 1510;                                                                      % Speed of sound of surrounding material (water) [m/s]
rho_sur = 1000;                                                                      % Density of surrounding material (water) [kg/m^3]
v_trans = 0;                                                                         % Transversal speed of sound [m/s]

Samples = nSamples*1024;                                                             % Number of time samples
Fs      = 4e9;                                                                       % Sampling frequency [Hz]
dt      = 1/Fs;                                                                      % Time resolution [s]
t0      = -Samples/2*dt:dt:Samples/2*dt;                                             % Time vector [s]
df      = 1/(t0(end)-t0(1));                                                         % Frequency resolution [Hz]
f0      = 0:df:Fs;                                                                   % Frequency vector [Hz]

pulse_sig = pulse_FWHM/(2*sqrt(2*log(2)))*1e-9;                                      % Laser pulse width (standard deviation) [s]

% ------- Calculate Signal
if solid == 0
    p0 = heaviside(r - abs(R-v_sur*t0)).*((R-v_sur*t0)/(2*R));                       % Signal of a fluid sphere
    
    if convolution                                                                   % Convolve signal with Gaussian pulse
        g = normpdf(t0, 0.0, pulse_sig);
        p = conv(p0, g, 'same');
    else
        g = p0;
        p = p0;
    end
    
    [pf, f] = FFT_t2f(p, t0);                                                        % Fourier transform -> Amplitude spectrum
    
    t  = t0;
    pf = abs(pf);
else
    q     = 2*pi*f0*r/v_abs;
    q     = q*2;                                                                     % ###### Factor 2 required -> Why???
    rho_0 = rho_abs/rho_sur;
    v_0   = v_abs/v_sur;
    v_t   = 2*v_trans/v_abs;
    
%   C_Exp = exp(-1i*v_abs/r*(q.*t0 - q*(R-r)/v_sur));
%   C_Exp = exp(-1i*q);
    C_Exp = 1;
    
    switch object
    case 1                                                                           % Signal of a solid sphere
        mtry = 0;
        
        if mtry
            Nom   = (sin(q) - q.*cos(q))./q.^2;
            Denom = (1 - rho_0 + rho_0*v_t^2./q.^2).*sin(q)./q ...
                  - (1 + rho_0*v_t^2./q.^2).*cos(q) ...
                  + 1i*rho_0*v_0*((1 - v_t^2./q.^2).*sin(q) + v_t^2./q.*cos(q));
        else
            Nom   = (sin(q) - q.*cos(q))./q.^2;
            Denom = (1 - rho_0).*sin(q)./q - cos(q) + 1i*rho_0*v_0*sin(q);
        end
        
        C_0   = 1i*r^2/(R*v_abs*rho_abs);
    case 2                                                                           % Signal of a solid cylinder
        Nom   = besselj(1,q)./q.*besselh(0,v_0*R/r*q);
        Denom = besselj(1,q).*besselh(0,v_0*q) ...
              - rho_0*v_0*besselh(1,v_0*q).*(besselj(0,q) - v_t^2/2*besselj(1,q)./q);
          
        C_0   = 1i/rho_abs;
    end
      
%     pf0 = C_0 .* C_Exp .* Nom./Denom;                                                % Calculate amplitude spectrum
  
    pf0 = 1i * C_Exp .* Nom./Denom;  
    
    % ------ Simulate attenuation of ultrasound waves in tissue
    if attenuation
        A0_t = 1.06;                                                                 % Tissue dependent attenuation coefficient [dB/MHz/cm]
        A0_w = 0.00217;                                                              % Attenuation coefficient of water [dB/MHz/cm]
        A_t  = log(10^(A0_t/20))*1e-4;                                               % [dB] -> [Np]
        A_w  = log(10^(A0_w/20))*1e-10;
        m_t  = 1.0;
        m_w  = 2.0;
        pf0  = pf0 .* exp(-A_t*f0.^m_t*z_t*1e-6) .* exp(-A_w*f0.^m_w*z_w*1e-6);      % Frequency dependent attenuation
    end
 
    pf0 = pf0(2:end);                                                                % 1st entry NaN (why??)
    f0  = f0(2:end);
    
    [p0, t] = FFT_f2t(pf0, f0);                                                      % Transform to time domain
    p0      = ifftshift(p0);
    
    % ------ Convolve signal with Gaussian laser pulse
    if convolution
        g  = normpdf(t, mean(t), pulse_sig);
        p  = conv(p0, g, 'same');
    else
        g  = p0;
        p  = p0;
    end
    
    [pf, f] = FFT_t2f(p, t);                                                         % Fourier transform  -> Amplitude spectrum
    pf      = abs(pf);
    
    p     = p(end:-1:1);                                                             % ###### Signal is mirrored -> Why???
    p0    = p0(end:-1:1);
    t0    = t - mean(t);                                                             % Center Gaussian at 0
    
    switch object                                                                    % Center signal at 0
    case 1 
        t = (t - mean(t)) - r/v_sur;                                                 % ###### Offset for sphere -> Why???
    case 2
        t = (t - mean(t));
    end
end

end
