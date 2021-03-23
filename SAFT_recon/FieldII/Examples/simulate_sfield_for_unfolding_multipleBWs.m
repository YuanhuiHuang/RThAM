addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\Field_II_PC7')
addpath('D:\Users\mathias.schwarz\Documents\MATLAB\FieldII\usefullFunctions')
cd D:\Users\mathias.schwarz\Documents\MATLAB\FieldII

clear all

field_init(-1)
close all

clc

%%

%%%----------- Frequency band for which the sensfield is simulated

UCOFvector=[40]*1e6;%[0.25:0.25:6]*1e6
LCOFvector=[0]*1e6;%[0:0.25:5.75]*1e6


%%
for ili=1:length(UCOFvector)

    UCOF=UCOFvector(ili);
    LCOF=LCOFvector(ili);   

    c = 1500 ;   %% soundspeed
    % dt_const = dx/c ;
    % time_res = 6 ;
    % dt = dt_const/time_res;
    fs = 125e6 ;  %% sampling frequency
    dt = 1/fs; 
    %%
    set_field('use_att',0)
    set_field('fs',fs)
    set_field('c',c)

    %%
    nel = 1;
    wi = 55/1e6;   % width of element
    hei = 1.5/1e3;     % height of element

    kerf = (70-55)/1e6
    Rcurve = 7.5/1e3;   % radius of element curvature
    RCOR = 7.5/1e3;     %

    elemres=5e-6; % element discretisation resolution

    Nx = wi/elemres; 
    Ny = hei/elemres;
    fcs = [0 0 0];

    pstripe = xdc_focused_array(nel,wi,hei,kerf,Rcurve,Nx,Ny,fcs);
    figure(1), show_xdc(pstripe)
    %hold on, scatter3(x_pos,y_pos,z_pos)
    title('Geometry 128 element linear array - single element','FontSize',16)
    daspect([1 1 1]);
    saveas(gcf,sprintf('Geometry128ElementLinearArray2.png'),'png')

    t = 1/fs:1/fs:2030/fs ;
    len = length(t) ;

    %% electrical impulse response
    impshifted=zeros([1 2030]);
    impshifted(1030)=1
    imp=impshifted;
    figure,plot(imp)


    %% parameters region of interest  (change with respect to required resolution)
    nx = 30 ; 
    ny = 50 ;
    nz = 50 ;
    im_x = 5e-3;
    im_y = 2e-3;
    im_z = 5e-3;

    x = linspace(-im_x/2,im_x/2,nx);
    y = linspace(-im_y/2,im_y/2,ny);
    z = RCOR + linspace(-im_z/2, im_z/2, nz );

    dx = x(2) - x(1) ;
    dy = y(2)-y(1) ;
    dz = z(2) - z(1) ;

    %%
    iii=0;
    for ii = 1:nx
        ii
        for kk = 1:ny
            for jj = 1:nz
                iii=iii+1;
                point_position = [x(ii) y(kk) z(jj)];

                % Calculate the received response
                [impresp_1, t2]=calc_hp(pstripe,point_position);

                a = find(min(abs(t2 - t)) == abs(t2 - t));
                impresp_2 = [zeros(a-1,1); impresp_1; zeros(len - a - length(impresp_1) + 1,1)];
                impresp_3 = conv(impresp_2 ,imp,'same');   %% convolution with electrical impusle response  (here dirac)
                impresp_4 = myfilter(impresp_3, [LCOF UCOF],fs );  %% filtering to desired freqeucny band

                field3d_1(ii, kk, jj) = max(impresp_1);
                field3d_2(ii, kk, jj) = max(impresp_2);
                field3d_3(ii, kk, jj) = max(impresp_3);
                field3d_4(ii, kk, jj) = max(impresp_4);
             end
        end
    end

    %% plot results
    figure(1),
    subplot(1,2,1)
    imagesc(x,z,squeeze(field3d_1(:,25,:))'),axis image,ylabel('mm'),ylabel('mm'),title('single SF inplane')
    subplot(1,2,2)
    imagesc(y,z,squeeze(field3d_1(15,:,:))'),axis image,ylabel('mm'),ylabel('mm'),title('single SF saggital')
    
    figure(2),
    subplot(1,2,1)
    imagesc(x,z,squeeze(field3d_2(:,end,:))'),axis image,ylabel('mm'),ylabel('mm'),title('single SF inplane')
    subplot(1,2,2)
    imagesc(y,z,squeeze(field3d_2(end,:,:))'),axis image,ylabel('mm'),ylabel('mm'),title('single SF saggital')
    
    figure(3),
    subplot(1,2,1)
    imagesc(x,z,squeeze(field3d_3(:,end,:))'),axis image,ylabel('mm'),ylabel('mm'),title('single SF inplane')
    subplot(1,2,2)
    imagesc(y,z,squeeze(field3d_3(end,:,:))'),axis image,ylabel('mm'),ylabel('mm'),title('single SF saggital')
    
    figure(4),
    subplot(1,2,1)
    imagesc(x,z,squeeze(field3d_4(:,end,:))'),axis image,ylabel('mm'),ylabel('mm'),title('single SF inplane')
    subplot(1,2,2)
    imagesc(y,z,squeeze(field3d_4(end,:,:))'),axis image,ylabel('mm'),ylabel('mm'),title('single SF saggital')

 
    sfield.sfield=field3d_4;
    sfield.dx=dx
    sfield.dy=dz
    sfield.dz=dy

    save(['SensitivityField_singleElement_',num2str(round(LCOF/1e3)),'kHz_',num2str(round(UCOF/1e3)),'kHz_noNshape'],'sfield')

end