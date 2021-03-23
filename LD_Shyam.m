%% Smith
%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_SMITH_LEG6_5.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
Smith = A(:,2) + 1i.* A(:,3);
figure,plot(Freq(13:end),A(13:end,2))
% figure,smithplot(Freq,Smith./100)

%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_SMITH_LEG2_5.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
Smith = A(:,2) + 1i.* A(:,3);
hold on,plot(Freq(13:end),A(13:end,2))
% figure,smithplot(Freq,Smith./100)


%% S11
%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_S11_LEG6_5.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
figure,plot(Freq,A(:,2))

%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_S11_LEG5_2.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
hold on,plot(Freq,A(:,2))


%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_S11_LEG2_5.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
hold on,plot(Freq,A(:,2))
%%
legend('6.5', '5.2', '2.5')
grid on, grid minor



%% Resistance
%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_SMITH_LEG6_5.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
figure,plot(Freq,A(:,2))

%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_SMITH_LEG5_2.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
hold on,plot(Freq,A(:,2))

%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_SMITH_LEG2_5.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
hold on,plot(Freq,A(:,2))
%%
legend('6.5', '5.2', '2.5')
grid on, grid minor



%% Reactance
%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_SMITH_LEG6_5.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
figure,plot(Freq,A(:,3))

%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_SMITH_LEG5_2.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
hold on,plot(Freq,A(:,3))

%%
Folder = 'C:\Users\yuanhui\Documents\20200526_Shyam_LD\';
filename = 'LD_SMITH_LEG2_5.CSV';
A = readmatrix([Folder filename]);
%
Freq = A(:,1);
hold on,plot(Freq,A(:,3))
%%
legend('6.5', '5.2', '2.5')
grid on, grid minor