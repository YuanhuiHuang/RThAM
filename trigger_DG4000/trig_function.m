function Return = trig_function(trig,WaveShapeStr,nChannel)
%% version 1.0 yuanhui 20190209 - specialized for DG4162 (ni-visa) programming
% typeStr can be - 
% % SINusoid|SQUare|RAMP|PULSe|NOISe|USER|HARMonic|CUSTom|DC|ABSSINE|ABSSINEHALF|AMPALT|ATTALT|GAUSSPULSE|NEGRAMP|
% % 
% % NPULSE|PPULSE|SINETRA|SINEVER|STAIRDN|STAIRUD|STAIRUP|TRAPEZIA|BANDLIMITED|BUTTERWORTH|CHEBYSHEV1|CHEBYSHEV2|
% % 
% % COMBIN|CPULSE|CWPULSE|DAMPEDOSC|DUALTONE|GAMMA|GATEVIBR|LFMPULSE|MCNOSIE|NIMHDISCHARGE|PAHCUR|QUAKE|RADAR|
% % 
% % RIPPLE|ROUNDHALF|ROUNDPM|STEPRESP|SWINGOSC|TV|VOICE|THREEAM|THREEFM|THREEPM|THREEPWM|THREEPFM|CARDIAC|EOG|
% % 
% % EEG|EMG|PULSILOGRAM|RESSPEED|LFPULSE|TENS1|TENS2|TENS3|IGNITION|ISO167502SP|ISO167502VR|ISO76372TP1|ISO76372TP2A|
% % 
% % ISO76372TP2B|ISO76372TP3A|ISO76372TP3B|ISO76372TP4|ISO76372TP5A|ISO76372TP5B|SCR|SURGE|AIRY|BESSELJ|BESSELY|CAUCHY|
% % 
% % CUBIC|DIRICHLET|ERF|ERFC|ERFCINV|ERFINV|EXPFALL|EXPRISE|GAUSS|HAVERSINE|LAGUERRE|LAPLACE|LEGEND|LOG|LOGNORMAL|
% % 
% % LORENTZ|MAXWELL|RAYLEIGH|VERSIERA|WEIBULL|X2DATA|COSH|COSINT|COT|COTHCON|COTHPRO|CSCCON|CSCPRO|CSCHCON|
% % 
% % CSCHPRO|RECIPCON|RECIPPRO|SECCON|SECPRO|SECH|SINC|SINH|SININT|SQRT|TAN|TANH|ACOS|ACOSH|ACOTCON|ACOTPRO|
% % 
% % ACOTHCON|ACOTHPRO|ACSCCON|ACSCPRO|ACSCHCON|ACSCHPRO|ASECCON|ASECPRO|ASECH|ASIN|ASINH|ATAN|ATANH|BARLETT|
% % 
% % BARTHANN|BLACKMAN|BLACKMANH|BOHMANWIN|BOXCAR|CHEBWIN|FLATTOPWIN|HAMMING|HANNING|KAISER|NUTTALLWIN|
% % 
% % PARZENWIN|TAYLORWIN|TRIANG|TUKEYWIN

if nargin == 2
    nChannel = 1;
end

Command = ['SOURce' num2str(nChannel) ':FUNCTION:SHAPe ' WaveShapeStr];
fwrite(trig,Command);
fwrite(trig,['SOURce' num2str(nChannel) ':FUNCtion?']);
Return = fscanf(trig);
disp(['DG4162 ' 'Channel ' num2str(nChannel) ' set to ' Return]);


