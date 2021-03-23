% General Reconstruction parameters:
reconParams.BPFilter   = 1;                                                  % BP filtering 0) off, 1) Exponential - Murad (FFT), 2) Butterworth - Mathias (FFT)
reconParams.MethodBP   = 4;                                                  % BP mode: 1) direct, 2) -deriv, 3) -deriv*t, 4) full
reconParams.FocusRec   = 1;                                                  % Focal region: 0) pointlike, 1) hyperbolic Olympus, 2) hyperbolic Khokhlova
reconParams.SF_Model   = 1;                                                  % Sensitivity field modeling: 0) off, 1) true sensitivity field
reconParams.v_s        = 1510;%1540                                                % Speed of sound [m/s] temp in °C and salinity in °/°° and pressure in bar
reconParams.cutBound   = 0; % def 1                                          % cut away data where the stage is not moving linearly: 1) on, 0) off
reconParams.relWidth   = [5  95]; %xy
reconParams.relHeight  = [10 60]; %z
% reconParams.relWidth   = [0 100]; %xy
% reconParams.relHeight  = [0 100]; %z
reconParams.DAQ        = 'old';   % 'new': from beginning of July 2014,'old': Gage --> !!! The shift indices changed !!!
reconParams.BLOCK_SIZE = 9;

% Transducer, and transducer specific reconstruction parameters:
%==========================================================================
% RSOM50 ==================================================================
%==========================================================================
det50.reconParams.genPos  = 0;%1;%2;
det50.reconParams.SpatFilt = 1;
det50.reconParams.GRID_DS = 20;
det50.reconParams.GRID_DZ = 5;
det50.reconParams.f_BPA = [24.83 65.99]*1e6;     % -6dB: [43.9 152.1]              % Bandpass of filter [Hz]
% det50.transducerParams.t_delay = 4.5705e-6;                                 % Focal time (F/v_s + t_delay) [s]
det50.transducerParams.t_delay = 8.1e-6;                                 % Focal time (F/v_s + t_delay) [s]
det50.transducerParams.F_TD  = 6.0198e-3;                                      % Focal length of TD [m]
det50.transducerParams.D_TD  = 6.35e-3;                                       % Diameter of TD active element [m]
det50.transducerParams.f_c   = 43.20e6;                                       % Central frequency [Hz]
det50.transducerParams.transducer = '50';                                    % Transducer identifier
% det50.transducerParams.t_foc      = 8.51e-6;
det50.transducerParams.t_foc      = 8.55e-6;
det50.reconParams.f_BPH      = [50 150]*1e6;
det50.reconParams.f_BPL      = [10 50]*1e6;
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