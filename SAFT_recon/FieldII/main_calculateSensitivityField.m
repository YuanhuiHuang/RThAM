%% 2D sensitivity field
% clear all
% clc
% addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
% cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII
% 
% Fs = 1250e6;
% c = 1480;
% maxPixels = 300;
% 
% field_init(0);
% 
% for f0 = [40]*1e6     % frequency of excitation signal
%    CalculateSensitivityFieldElevation(f0,Fs,c,maxPixels);
%    CalculateSensitivityFieldLateral(f0,Fs,c,maxPixels);
% end
% 
% field_end;


%% 3D sensitivity field
% clear all
% clc
% addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
% cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII
% 
% Fs = 1250e6;
% c = 1480;
% maxPixels = 200;
% 
% field_init(0);
% 
% for f0 = [5 25]*1e6     % frequency of excitation signal
%    cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII
%    CalculateSensitivityField(f0,Fs,c,maxPixels);
% end
% 
% field_end;


%% 3D sensitivity field spherical transducer
clear all
clc
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII

Fs = 10e9;
c = 1500;
maxPixels = 350;

field_init(0);

for radius = [5 1 25]*1e-6     % frequency of excitation signal
   cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII
   CalculateSensitivityFieldSpherical(radius,Fs,c,maxPixels);
end

field_end;