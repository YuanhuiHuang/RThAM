% S=S_;
% S=reshape(S,sqrt(size(S,1)),sqrt(size(S,1)),size(S,3));
% ss=max(S,[],3);

% figure,imagesc(ss(1:2:end,1:2:end)), colormap jet


%% show_focus
S_=S;

% S_ = S_(:,1:4600);
% figure,imagesc(S_),colormap jet

Fs = 500e6;
dt = 1/Fs;
trigDelay = 9000;
trigDelay=trigDelay*1/Fs;
dz = 0.02;
Lz = (size(S_,1)-1).*dz;

tt_ = (trigDelay+dt):dt:trigDelay+dt*size(S_,2);
ZZ_ = [0:dz:Lz];

for i=1:1:size(S_,1)
    S_(i,:) = abs(hilbert(filtData(S_(i,:),Fs,[1e6 1e9])));
end
% S_ = S_(50:461,200:4300);
% tt_ = tt_(200:4300);
% ZZ_ = ZZ_(50:461);

%    Max_Time = max(S_,[],1);
%    figure,plot(tt_,Max_Time);
%    xlabel('\muS');ylabel('Volt');
%    Max_Z = max(S_,[],2);
%    figure,plot(ZZ_,Max_Z);
%    xlabel('mm');ylabel('Volt');
    
%    Max_Time = max(S_,[],1);
   Max_Time = sum(S_,1);
   figure,plot(tt_,Max_Time);
   xlabel('\muS');ylabel('Volt');
   title('Voltage vs Arrival Time');
   
%    Max_Z = max(S_,[],2);
   Max_Z = sum(S_,2);
   figure,plot(ZZ_,Max_Z);
   xlabel('mm');ylabel('Volt');
   title('Voltage vs Z lift');
%    
%    figure,plot(tt_,squeeze(S_(118,:)));
%    xlabel('\muS');ylabel('Volt');
%    title('Raw sequence');
%    hold on, plot(tt_,squeeze(S_(90,:)));
%    hold on, plot(tt_,squeeze(S_(60,:)));
%    hold on, plot(tt_,squeeze(S_(30,:)));
%    hold on, plot(tt_,squeeze(S_(1,:)));
   
figure,imagesc(tt_,ZZ_,(S_-median(S_(:)))); colormap('jet');
title('Search focus'); xlabel('\muS');ylabel('Z /mm');
   
% dataSignal (i,:) = filtData(dataSignal(i,:),Fs,[5e1 1e7]);
