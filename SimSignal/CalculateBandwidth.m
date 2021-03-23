function [BW6dB, BW3dB] = CalculateBandwidth(s, f)
l6dB  = 1/2;
l3dB  = 1/sqrt(2);

peak_ = f(s == max(s));
peak  = peak_(1);

f1    = f(f < peak);
f2    = f(f >= peak);
s1    = s(1:length(f1));
s2    = s(length(f1)+1:end);

f1_l3 = f1(s1 <= l3dB*max(s));
f2_h3 = f2(s2 <= l3dB*max(s));
f1_l6 = f1(s1 <= l6dB*max(s));
f2_h6 = f2(s2 <= l6dB*max(s));

fmin3 = f1_l3(length(f1_l3));
fmax3 = f2_h3(1);
fmin6 = f1_l6(length(f1_l6));
fmax6 = f2_h6(1);

BW6dB = (fmax6 - fmin6)*1e-6;
BW3dB = (fmax3 - fmin3)*1e-6;

% BW6dB = 1e-6;
% BW3dB = 2e-6;
end