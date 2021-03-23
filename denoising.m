function [sig_out,sigma]=denoising(sig_in,th_fac, lev)
%
% Run the following:
% lev= 5;
% th_fac = 1.5;
% sig_out = denoising(sig_in,th_fac, lev);
% if doesn’t improve try changing lev, and th_fac
%
wname = 'sym6';
if nargin < 2
    lev = 5;
    th_fac = 1.5;
elseif nargin < 3
    lev = 5;
end
[c,l] = wavedec(sig_in,lev,wname);
sigma = wnoisest(c,l,1);
alpha = 2;
thr = th_fac*wbmpen(c,l,sigma,alpha);
keepapp = 1;
sig_out = wdencmp('gbl',c,l,wname,lev,thr,'s',keepapp);
