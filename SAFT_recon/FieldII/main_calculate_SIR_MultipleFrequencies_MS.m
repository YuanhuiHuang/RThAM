clear all
clc
cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII

Fs = 1250e6;
c = 1480;
maxPixels = 30;

for a = [50 20 100 250 500 1000]*1e-6 % radius of emitting  sphere
   CalculateSensitivityFieldLarge(a,Fs,c,maxPixels);
end
