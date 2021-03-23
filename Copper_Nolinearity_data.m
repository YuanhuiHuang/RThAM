Max_TA_Copper(1) = Copper_Nolinearity('201806022040_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_9.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',1);
Max_TA_Copper(2) = Copper_Nolinearity('201806022036_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_9kV_10kHz_external_YPofile_70-210us_AVG1024_3315',1);
Max_TA_Copper(3) = Copper_Nolinearity('201806022035_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_8.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',1);
Max_TA_Copper(4) = Copper_Nolinearity('201806022034_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_8kV_10kHz_external_YPofile_70-210us_AVG1024_3315',1);
Max_TA_Copper(5) = Copper_Nolinearity('201806022032_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_7.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',1);
Max_TA_Copper(6) = Copper_Nolinearity('201806022031_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_7kV_10kHz_external_YPofile_70-210us_AVG1024_3315',1);
Max_TA_Copper(7) = Copper_Nolinearity('201806022030_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_6.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',1);
Max_TA_Copper(8) = Copper_Nolinearity('201806022020_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_6kV_10kHz_external_YPofile_70-210us_AVG1024_3315',1);
Max_TA_Copper(9) = Copper_Nolinearity('201806022017_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_5.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',1);
Max_TA_Copper(10) = Copper_Nolinearity('201806022014_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',1);
%% Display TA
% HV = (5:5/9:10).*1e3;
HV = [5.3 5.45 5.56 5.76 6.15 7.0 7.3 8.5 9.4 10];
% figure,plot(HV,flip((Max_TA_Copper./1e3))),
% figure,plot((HV.^2./50),(flip((Max_TA_Copper./1e3).^2./50)))
% figure,semilogy(HV.^2./50,(flip((Max_TA_Copper./1e3).^2./50)))
% figure, plot(HV,(flip(Copper_Max)))
figure('OuterPosition',[241 487 576 513]);
% plot(HV,flip((Max_US_Copper./1e3)))
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV,flip((Max_TA_Copper./1e3)),'MarkerSize',10,'Marker','x','LineWidth',2,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);
% Create ylabel
ylabel('Thermoacoustic effect (Volt)');
% Create xlabel
xlabel({'RF excitation (kV)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
title('Voltage relation');

figure('OuterPosition',[241 487 576 513]);
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV.^2./50,(flip((Max_TA_Copper./1e3).^2./50)),'MarkerSize',10,'Marker','x','LineWidth',2,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);
% Create ylabel
ylabel('Thermoacoustic effect peak power (Watt)');
% Create xlabel
xlabel({'RF excitation peak power (MW)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
title('Peak power relation');

figure('OuterPosition',[215 423 576 513]);
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create semilogy
semilogy(HV.^2./50,(flip((Max_TA_Copper./1e3).^2./50)),'MarkerSize',10,'Marker','x','LineWidth',2,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);
% Create ylabel
ylabel({'Thermoacoustic signal peak power / log(Watt)'});
% Create xlabel
xlabel({'RF excitation peak power (MW)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on','YMinorTick','on','YScale','log');
title('Peak power relation');

%% US
Max_US_Copper(1) = Copper_Nolinearity('201806022040_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_9.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',0);
Max_US_Copper(2) = Copper_Nolinearity('201806022036_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_9kV_10kHz_external_YPofile_70-210us_AVG1024_3315',0);
Max_US_Copper(3) = Copper_Nolinearity('201806022035_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_8.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',0);
Max_US_Copper(4) = Copper_Nolinearity('201806022034_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_8kV_10kHz_external_YPofile_70-210us_AVG1024_3315',0);
Max_US_Copper(5) = Copper_Nolinearity('201806022032_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_7.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',0);
Max_US_Copper(6) = Copper_Nolinearity('201806022031_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_7kV_10kHz_external_YPofile_70-210us_AVG1024_3315',0);
Max_US_Copper(7) = Copper_Nolinearity('201806022030_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_6.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',0);
Max_US_Copper(8) = Copper_Nolinearity('201806022020_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_6kV_10kHz_external_YPofile_70-210us_AVG1024_3315',0);
Max_US_Copper(9) = Copper_Nolinearity('201806022017_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_5.5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',0);
Max_US_Copper(10) = Copper_Nolinearity('201806022014_TAM50_OpenCPS_ZebrafishDay7onCopper100um_ShallowInAgar_CopperNonlinar_5kV_10kHz_external_YPofile_70-210us_AVG1024_3315',0);
%% Display US
% HV = (5:5/9:10).*1e3;
HV = [5.3 5.45 5.56 5.76 6.15 7.0 7.3 8.5 9.4 10];
figure('OuterPosition',[241 487 576 513]);
% plot(HV,flip((Max_US_Copper./1e3)))
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV,flip((Max_US_Copper./1e3)),'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0.498039215803146 0]);
% Create ylabel
ylabel('Piezoelectric signal (Volt)');
% Create xlabel
xlabel({'RF excitation (kV)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
title('Voltage relation');

figure('OuterPosition',[241 487 576 513]);
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV.^2./50,(flip((Max_US_Copper./1e3).^2./50)),'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0.498039215803146 0]);
% Create ylabel
ylabel('Piezoelectric signal peak power (Watt)');
% Create xlabel
xlabel({'RF excitation peak power (MW)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
title('Peak power relation');

figure('OuterPosition',[215 423 576 513]);
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create semilogy
semilogy(HV.^2./50,(flip((Max_US_Copper./1e3).^2./50)),'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0.498039215803146 0]);
% Create ylabel
ylabel({'Piezoelectric signal peak power / log(Watt)'});
% Create xlabel
xlabel({'RF excitation peak power (MW)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on','YMinorTick','on','YScale','log');
title('Peak power relation');

%% EField Nonlinearity
Max_EField(10) = EField_Nolinearity('201806221759_TAM50_OpenCPS_CopperNonlinar_DipoleEfield_5kV_10kHz_external_YPofile_0-5us_AVG1024_3315',1);
Max_EField(9) = EField_Nolinearity('201806221800_TAM50_OpenCPS_CopperNonlinar_DipoleEfield_5.5kV_10kHz_external_YPofile_0-5us_AVG1024_3315',1);
Max_EField(8) = EField_Nolinearity('201806221801_TAM50_OpenCPS_CopperNonlinar_DipoleEfield_6kV_10kHz_external_YPofile_0-5us_AVG1024_3315',1);
Max_EField(7) = EField_Nolinearity('201806221809_TAM50_OpenCPS_CopperNonlinar_DipoleEfield_6.5kV_10kHz_external_YPofile_0-5us_AVG1024_3315',1);
Max_EField(6) = EField_Nolinearity('201806221810_TAM50_OpenCPS_CopperNonlinar_DipoleEfield_7kV_10kHz_external_YPofile_0-5us_AVG1024_3315',1);
Max_EField(5) = EField_Nolinearity('201806221812_TAM50_OpenCPS_CopperNonlinar_DipoleEfield_7.5kV_10kHz_external_YPofile_0-5us_AVG1024_3315',1);
Max_EField(4) = EField_Nolinearity('201806221817_TAM50_OpenCPS_CopperNonlinar_DipoleEfield_8kV_10kHz_external_YPofile_0-5us_AVG1024_3315',1);
Max_EField(3) = EField_Nolinearity('201806221819_TAM50_OpenCPS_CopperNonlinar_DipoleEfield_8.5kV_10kHz_external_YPofile_0-5us_AVG1024_3315',1);
Max_EField(2) = EField_Nolinearity('201806221822_TAM50_OpenCPS_CopperNonlinar_DipoleEfield_9kV_10kHz_external_YPofile_0-5us_AVG1024_3315',1);
Max_EField(1) = EField_Nolinearity('201806221823_TAM50_OpenCPS_CopperNonlinar_DipoleEfield_9.5kV_10kHz_external_YPofile_0-5us_AVG1024_3315',1);
%% Display EField
% HV = (5:5/9:10).*1e3;
HV = [5.3 5.45 5.56 5.76 6.15 7.0 7.3 8.5 9.4 10];
figure('OuterPosition',[241 487 576 513]);
% plot(HV,flip((Max_US_Copper./1e3)))
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV,flip((Max_EField./1e3)),'MarkerSize',10,'Marker','*','LineWidth',2,'Color',[0 0.45 0.74]);
% Create ylabel
ylabel('E-Field by Dipole (Volt)');
% Create xlabel
xlabel({'RF excitation (kV)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
title('Voltage relation');

figure('OuterPosition',[241 487 576 513]);
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV.^2./50,(flip((Max_EField./1e3).^2./50)),'MarkerSize',10,'Marker','*','LineWidth',2,'Color',[0 0.45 0.74]);
% Create ylabel
ylabel('Peak power in E-Field by Dipole (Watt)');
% Create xlabel
xlabel({'RF excitation peak power (MW)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
title('Peak power relation');

figure('OuterPosition',[215 423 576 513]);
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create semilogy
semilogy(HV.^2./50,(flip((Max_EField./1e3).^2./50)),'MarkerSize',10,'Marker','*','LineWidth',2,'Color',[0 0.45 0.74]);
% Create ylabel
ylabel({'Peak power in E-Field by Dipole / log(Watt)'});
% Create xlabel
xlabel({'RF excitation peak power (MW)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on','YMinorTick','on','YScale','log');
title('Peak power relation');

%% Unified Display - Max
Max_US_Copper_VAU = Max_US_Copper./1e3; Max_US_Copper_VAU = Max_US_Copper_VAU ./ max(Max_US_Copper_VAU);
Max_US_Copper_PAU =(Max_US_Copper./1e3).^2./50; Max_US_Copper_PAU = Max_US_Copper_PAU ./ max(Max_US_Copper_PAU);

Max_TA_Copper_VAU = Max_TA_Copper./1e3; Max_TA_Copper_VAU = Max_TA_Copper_VAU ./ max(Max_TA_Copper_VAU);
Max_TA_Copper_PAU =(Max_TA_Copper./1e3).^2./50; Max_TA_Copper_PAU = Max_TA_Copper_PAU ./ max(Max_TA_Copper_PAU);

Max_EField_VAU = Max_EField./1e3; Max_EField_VAU = Max_EField_VAU ./ max(Max_EField_VAU);
Max_EField_PAU =(Max_EField./1e3).^2./50; Max_EField_PAU = Max_EField_PAU ./ max(Max_EField_PAU);

HV1 = (5:5/9:10);
HV = [5.3 5.45 5.56 5.76 6.15 7.0 7.3 8.5 9.4 10];
figure('OuterPosition',[241 487 576 513]);
% plot(HV,flip((Max_US_Copper./1e3)))
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV1,HV,'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0 0]);
% Create ylabel
ylabel('Nominated RF excitation (kV)');
% Create xlabel
xlabel({'Linear RF excitation (kV)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
title('Nominated exponential RF excitation');


figure('OuterPosition',[241 487 576 513]);
% plot(HV,flip((Max_US_Copper./1e3)))
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV,flip((Max_US_Copper_VAU)),'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0.498039215803146 0]);
hold on, plot(HV,flip((Max_TA_Copper_VAU)),'MarkerSize',10,'Marker','x','LineWidth',2,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);
hold on, plot(HV,flip((Max_EField_VAU)),'MarkerSize',10,'Marker','*','LineWidth',2,'Color',[0 0.45 0.74]);
% Create ylabel
ylabel('Signal amplitude (a.u. Volt)');
% Create xlabel
xlabel({'RF excitation (kV)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
legend('Piezoelectrics','Thermoacoustics','Dipole E-Field');
title('Voltage relation');

figure('OuterPosition',[241 487 576 513]);
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV.^2./50,(flip(Max_US_Copper_PAU)),'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0.498039215803146 0]);
hold on, plot(HV.^2./50,(flip(Max_TA_Copper_PAU)),'MarkerSize',10,'Marker','x','LineWidth',2,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);
hold on, plot(HV.^2./50,flip((Max_EField_PAU)),'MarkerSize',10,'Marker','*','LineWidth',2,'Color',[0 0.45 0.74]);
% Create ylabel
ylabel('Signal peak power (a.u. Watt)');
% Create xlabel
xlabel({'RF excitation peak power (MW)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
legend('Piezoelectrics','Thermoacoustics','Dipole E-Field');
title('Peak power relation');

figure('OuterPosition',[215 423 576 513]);
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create semilogy
semilogy(HV.^2./50,(flip(Max_US_Copper_PAU)),'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0.498039215803146 0]);
hold on, semilogy(HV.^2./50,(flip(Max_TA_Copper_PAU)),'MarkerSize',10,'Marker','x','LineWidth',2,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);
hold on, semilogy(HV.^2./50,flip((Max_EField_PAU)),'MarkerSize',10,'Marker','*','LineWidth',2,'Color',[0 0.45 0.74]);
% Create ylabel
ylabel({'Signal peak power / a.u. log(Watt)'});
% Create xlabel
xlabel({'RF excitation peak power (MW)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on','YMinorTick','on','YScale','log');
legend('Piezoelectrics','Thermoacoustics','Dipole E-Field');
title('Peak power relation');

%% Unified Display - min
Max_US_Copper_VAU = Max_US_Copper./1e3; Max_US_Copper_VAU = Max_US_Copper_VAU ./ min(Max_US_Copper_VAU);
Max_US_Copper_PAU =(Max_US_Copper./1e3).^2./50; Max_US_Copper_PAU = Max_US_Copper_PAU ./ min(Max_US_Copper_PAU);

Max_TA_Copper_VAU = Max_TA_Copper./1e3; Max_TA_Copper_VAU = Max_TA_Copper_VAU ./ min(Max_TA_Copper_VAU);
Max_TA_Copper_PAU =(Max_TA_Copper./1e3).^2./50; Max_TA_Copper_PAU = Max_TA_Copper_PAU ./ min(Max_TA_Copper_PAU);

Max_EField_VAU = Max_EField./1e3; Max_EField_VAU = Max_EField_VAU ./ min(Max_EField_VAU);
Max_EField_PAU =(Max_EField./1e3).^2./50; Max_EField_PAU = Max_EField_PAU ./ min(Max_EField_PAU);

HV1 = (5:5/9:10);
HV = [5.3 5.45 5.56 5.76 6.15 7.0 7.3 8.5 9.4 10];
figure('OuterPosition',[241 487 576 513]);
% plot(HV,flip((Max_US_Copper./1e3)))
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV1,HV,'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0 0]);
% Create ylabel
ylabel('Nominated RF excitation (kV)');
% Create xlabel
xlabel({'Linear RF excitation (kV)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
title('Nominated exponential RF excitation');


figure('OuterPosition',[241 487 576 513]);
% plot(HV,flip((Max_US_Copper./1e3)))
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV,flip((Max_US_Copper_VAU)),'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0.498039215803146 0]);
hold on, plot(HV,flip((Max_TA_Copper_VAU)),'MarkerSize',10,'Marker','x','LineWidth',2,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);
hold on, plot(HV,flip((Max_EField_VAU)),'MarkerSize',10,'Marker','*','LineWidth',2,'Color',[0 0.45 0.74]);
% Create ylabel
ylabel('Signal amplitude (a.u. Volt)');
% Create xlabel
xlabel({'RF excitation (kV)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
legend('Piezoelectrics','Thermoacoustics','Dipole E-Field');
title('Voltage relation');

figure('OuterPosition',[241 487 576 513]);
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create plot
plot(HV.^2./50,(flip(Max_US_Copper_PAU)),'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0.498039215803146 0]);
hold on, plot(HV.^2./50,(flip(Max_TA_Copper_PAU)),'MarkerSize',10,'Marker','x','LineWidth',2,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);
hold on, plot(HV.^2./50,flip((Max_EField_PAU)),'MarkerSize',10,'Marker','*','LineWidth',2,'Color',[0 0.45 0.74]);
% Create ylabel
ylabel('Signal peak power (a.u. Watt)');
% Create xlabel
xlabel({'RF excitation peak power (MW)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on');
legend('Piezoelectrics','Thermoacoustics','Dipole E-Field');
title('Peak power relation');

figure('OuterPosition',[215 423 576 513]);
% Create axes
axes1 = axes;
hold(axes1,'on');
% Create semilogy
semilogy(HV.^2./50,(flip(Max_US_Copper_PAU)),'MarkerSize',10,'Marker','o','LineWidth',2,'Color',[0 0.498039215803146 0]);
hold on, semilogy(HV.^2./50,(flip(Max_TA_Copper_PAU)),'MarkerSize',10,'Marker','x','LineWidth',2,'Color',[0.850980401039124 0.325490206480026 0.0980392172932625]);
hold on, semilogy(HV.^2./50,flip((Max_EField_PAU)),'MarkerSize',10,'Marker','*','LineWidth',2,'Color',[0 0.45 0.74]);
% Create ylabel
ylabel({'Signal peak power / a.u. log(Watt)'});
% Create xlabel
xlabel({'RF excitation peak power (MW)'});
box(axes1,'on');
% Set the remaining axes properties
set(axes1,'XGrid','on','YGrid','on','YMinorTick','on','YScale','log');
legend('Piezoelectrics','Thermoacoustics','Dipole E-Field');
title('Peak power relation');