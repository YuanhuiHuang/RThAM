d = N(:,2);
t = N(:,1);
[value, index] = max(d);
gaussMap = exp(-((1:length(d))- index).^2/20^2);
d2 = d'.*gaussMap;
figure,plot(t,d2);