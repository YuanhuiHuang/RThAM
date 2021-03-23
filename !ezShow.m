S_=double(reshape(S_,sqrt(size(S_,1))^2,size(S_,2)));
S_ = double(S);
Fs = 500e6;
dt = 1/Fs;
% trigDelay = 25e-6;
trigDelay=trigDelay*1/Fs;
dz = 0.05;
Lz = (size(S_,1)-1).*dz;

tt_ = (trigDelay+dt):dt:trigDelay+dt*size(S_,2);
ZZ_ = [0:dz:Lz];

% compensate for the backlash of PI stages

for i=1:1:size(S_,1)
    S_(i,:) = abs(hilbert(filtData(S_(i,:),Fs,[1e6 1e9])));
end
% temp1 = S(:,1:2:end,:);
temp2 = S(:,2:2:end,:);
temp = circshift(temp2,24,1);
S_(:,2:2:end,:) = temp;

% display
ss=max(S_,[],3);figure,imshow(ss,[])


SS_no = S(1:2:end,1:2:end,:);

ss_no = max(SS(:,:,1:770),[],3);
figure,imshow(ss_no,[])
% figure,imshow(squeeze(max(S_(430:600,850:973,:),[],1)),[])
% figure,imshow(squeeze(sum(S_(430:600,850:973,:),1)),[])
%% backlash
temp1=SS1(:,1:2:end);
temp2=SS1(:,2:2:end);
% figure,imshowpair(temp1,temp2,'colorchannel','red-cyan')
%
temp = circshift(temp2,30,1); % 30 pixels
% figure,imshowpair(temp1,temp,'colorchannel','red-cyan')
SS1_=SS1;
SS1_(:,2:2:end) = temp;
figure,imshow(SS1_)


temp1=SS2(:,1:2:end);
temp2=SS2(:,2:2:end);
figure,imshowpair(temp1,temp2,'colorchannel','red-cyan')

temp = circshift(temp2,24,1); % 24 pixels
figure,imshowpair(temp1,temp,'colorchannel','red-cyan')
SS2_=SS2;
SS2_(:,2:2:end) = temp;
figure,imshow(SS2_)
