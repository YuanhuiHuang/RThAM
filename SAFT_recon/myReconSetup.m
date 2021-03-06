% % myReconSetup

% General Reconstruction parameters:
reconParams.BPFilter   = 1;                                                  % BP filtering 0) off, 1) Exponential - Murad (FFT), 2) Butterworth - Mathias (FFT)
reconParams.MethodBP   = 4;                                                  % BP mode: 1) direct, 2) -deriv, 3) -deriv*t, 4) full
reconParams.FocusRec   = 1;                                                  % Focal region: 0) pointlike, 1) hyperbolic Olympus, 2) hyperbolic Khokhlova
reconParams.SF_Model   = 1;                                                  % Sensitivity field modeling: 0) off, 1) true sensitivity field
reconParams.v_s        = 1480;%1540                                                % Speed of sound [m/s] temp in ?C and salinity in ?/?? and pressure in bar
reconParams.cutBound   = 0; % def 1                                          % cut away data where the stage is not moving linearly: 1) on, 0) off
% reconParams.relWidth   = [5  95]; %xy
% reconParams.relHeight  = [10 60]; %z
reconParams.relWidth   = [1 100]; %xy
reconParams.relHeight  = [1 100]; %z
reconParams.DAQ        = 'new';   % 'new': from beginning of July 2014,'old': Gage --> !!! The shift indices changed !!!
reconParams.BLOCK_SIZE = 9;

% Transducer, and transducer specific reconstruction parameters:
%==========================================================================
% RSOM50 ==================================================================
%==========================================================================
det50.reconParams.genPos  = 0;%1;%2;
det50.reconParams.XYswitch  = 1;%1: Y is fast axis;
det50.reconParams.SpatFilt = 1;
% det50.reconParams.GRID_DS = min(dx,dy)*1000;
% det50.reconParams.GRID_DS = 20;
% det50.reconParams.GRID_DZ = 2;
det50.reconParams.GRID_DS = min([dx dy dz]).*1000;
det50.reconParams.GRID_DZ = 1/Fs*1e6*1500;
% det50.reconParams.f_BPA = [24.83 65.99]*1e6;     % -6dB: [43.9 152.1]              % Bandpass of filter [Hz]
% det50.reconParams.f_BPH      = [50 90]*1e6;
% det50.reconParams.f_BPL      = [10 50]*1e6;
det50.reconParams.f_BPH      = [45.41 250]*1e6;
det50.reconParams.f_BPL      = [1 45.41]*1e6;
det50.reconParams.f_BPA      = [1 250]*1e6;     % -6dB: [43.9 152.1]              % Bandpass of filter [Hz]
% det50.reconParams.f_BPA      = [1 500]*1e6;     % -6dB: [43.9 152.1]              % Bandpass of filter [Hz]
% det50.transducerParams.t_delay = 4.5705e-6;                                 % Focal time (F/v_s + t_delay) [s]
det50.transducerParams.t_delay = 8.1e-6;                                 % Focal time (F/v_s + t_delay) [s]
det50.transducerParams.F_TD  = 6.0198e-3;                                      % Focal length of TD [m] 
% V3330 0.237 inch
% V390 0.506 inch
det50.transducerParams.D_TD  = 6.35e-3;                                       % Diameter of TD active element [m] 
% V3330 0.25 inch
% V390 0.25 inch
det50.transducerParams.f_c   = 45.41e6;                                       % Central frequency [Hz] 
% det50.transducerParams.f_c   = 180e6;                                       % Central frequency [Hz] 
% V3330 45.41cF, 43.20 pF [24.83 65.99]MHz 90.66%@-6dB, [10 90] @ -20dB
% V390  43.16cF, 41.00 pF [26.37 59.94]MHz 77.77%@-6dB, [10 90] @ -20dB
det50.transducerParams.transducer = '50';                                    % Transducer identifier
det50.transducerParams.t_foc      = 8.46e-6; % 8.505 / 8.520 is achieved by image details/contrast comparison of [8.46 8.64]
% 8.31e-6 for 20160803 fish; 
% 8.46e-6 for egg general; 
% 8.520e-6 for copper 50 MHz; 8.31e-6 for egg 8h/20h; 
% det50.transducerParams.t_foc      = 8.6379e-6;  
% V3330 9.141us/2 delay line + 0.237*25.4/1.5 us = 8.6379 us
% V390 19.521/2 us delay line + 0.506*25.4/1.48 us = 18.4446 us
% now general ones:
det50.reconParams.BPFilter   = reconParams.BPFilter;
det50.reconParams.MethodBP   = reconParams.MethodBP;
det50.reconParams.FocusRec   = reconParams.FocusRec;
det50.reconParams.SF_Model   = reconParams.SF_Model;
det50.reconParams.v_s        = reconParams.v_s;
det50.reconParams.cutBound   = reconParams.cutBound;
det50.reconParams.relWidth   = reconParams.relWidth;
det50.reconParams.relHeight  = reconParams.relHeight;
det50.reconParams.DAQ        = reconParams.DAQ;
det50.reconParams.BLOCK_SIZE = reconParams.BLOCK_SIZE;