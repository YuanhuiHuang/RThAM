addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\usefullFunctions')

%%initialize fiel software
field_init

%% define transducer geometry and display it

cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\usefullFunctions

% Set initial parameters
height=1.5/1000; % Height of element [m]
width=55/1000000; % Width of element [m]
kerf=(70-55)/1000000; % Distance between transducer elements [m]
N_elements=10; % Number of elements
Rfocus=7.55/1000; % Elevation focus [m]
Rconvex=1000; % Convex radius [m]
N_subdivisionX=5; % Number of sub-divisions in x-direction of elements.
N_subdivisionY=50; % no sub y Number of sub-divisions in y-direction of elements.
focus=[0 0 0]; % Fixed focus for array (x,y,z). Vector with three elements.
Transducer1 = xdc_convex_focused_array (N_elements, width, height,...
     kerf,Rconvex, Rfocus, N_subdivisionX, N_subdivisionY, focus)

figure(1), [x_pos,y_pos,z_pos] = show_xdc_MS(Transducer1,kerf,width,height)
daspect([1 1 1])
%daspect([1 0.2 0.04])
view([-37.5 30])
box off
%set(gca,'ZTick',-0.035:0.034:0.001)
set(gca,'ZTick',0:0.034:0.035)
set(gca,'ZTickLabel',{'0','-0.035'})
title('Geometry 128 element linear array','FontSize',14)
saveas(gcf,sprintf('Geometry128ElementLinearArray.png'),'png')
%hold on, scatter3(x_pos,y_pos,z_pos)
%figure(2), view_2d_xdc(Transducer1)
%figure(3), view_3d_xdc(Transducer1)

% Transducer2 = xdc_convex_array(N_elements, width, height,...
%      kerf,Rconvex, N_subdivisionX, N_subdivisionY, focus)
%show_xdc(Transducer2)
