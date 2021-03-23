% close all;
Grid = 0.05; %mm
dt = 50e-6./10000;
Finess = Grid/1.48*1e-6/dt;
% dt = Grid/1.48*1e-6/Finess;
Diameter = 3;
Shift_T = Diameter./Grid;
t_end = 50e-6; % us
t = 0:dt:t_end-dt;

Nt = length(t);
% define a time varying sinusoidal rf source
RLC.C = 1700e-12 + 5e-12; % Farad, latter is spark gap capacity
% RLC.L = 1.51e-6;    % Herry   3MHz
RLC.L = (pi*4e-7)*0.5*(7^2)*(2*pi*(50e-3/2)^2)/80e-3 + 25e-9; % latter is SG inductance
RLC.R = 1.5;    % 8 Mega-ohm, affects damping factor% critical damping R=60
% RLC.L = u*K*N^2*A/l; 
    % u=4*pi*e-7 (H/m)
    % K: Nagaoka coefficient, was taken as 0.5 for simplicity
    % N is the NO. of turns
    % A is the area of the Coil
    % l is the length of the Coil
RLC.omega = 1/sqrt(RLC.L*RLC.C);
RLC.freq = RLC.omega/2/pi;
RLC.alpha = RLC.R/2/RLC.L;
RLC.zeta = RLC.alpha/RLC.omega; % zeta >1 overdamped
RLC.S1 = -RLC.alpha+sqrt(RLC.alpha^2+RLC.omega^2);
RLC.S2 = -RLC.alpha-sqrt(RLC.alpha^2+RLC.omega^2);
RLC.A1 = -30e3;  % Volt, voltage at the onset of the transient
RLC.A2 = 0;     % Volt, voltage the circuit eventually settles to
% RLC.I_t =   RLC.A1*exp(RLC.S1*t) + ...
%             RLC.A2*exp(RLC.S2*t); % for general solution
% RLC.I_t = RLC.A1*exp(-RLC.alpha*t).*cos(sqrt(RLC.omega^2-RLC.alpha^2)*t);  % for underdamped

        % define 2nd harmonic TA source
        %%% FUTURE WORK
        % end

% define reflection source
source_mag = 1;     % [Pa]
% Relaxation = source_mag*exp(-((t-0.2e-6).^2)./(2*(10e-9)^2));%figure,plot(t,Relaxation)
Relaxation = source_mag*exp(-RLC.alpha*t).*cos(sqrt(RLC.omega^2-RLC.alpha^2)*t); % Transducer relaxation
% Relaxation = source_mag*exp(-RLC.alpha*t).*cos(sqrt((RLC.omega./4)^2-(RLC.alpha./4)^2)*t); % Transducer relaxation
TAS0        = (1./(Diameter./Grid))*gradient(1.54*(Relaxation).^2); % Salt solution sigma * |E|^2
TAS = TAS0;
handT = figure();plot(t,TAS);[f,fd]=mySpectrum(t,TAS);handF=figure();plot(f(f<10e6),fd(f<10e6));
figure,
for Shift=1:Shift_T
%     TAS = TAS + circshift(TAS0, [1 Shift*Finess]);
    TAS = TAS + [zeros(1,round(Shift*Finess)), TAS0(1:end-round(Shift*Finess))];
end
% TAS = gradient(TAS);
TAS = filtS(TAS,dt,Grid,1);
figure(handT); hold on, plot(t,TAS);[f,fd]=mySpectrum(t,TAS);figure(handF);hold on,plot(f(f<10e6),fd(f<10e6));

