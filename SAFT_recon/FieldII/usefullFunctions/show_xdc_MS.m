%  Show the transducer surface in a surface plot
%
%  Calling: show_xdc(Th)
%
%  Argument: Th - Transducer handle
%
%  Return:   Plot of the transducer surface on the current figure
%
%  Note this version onlys shows the defined rectangles
%
%  Version 1.2, August 4, 1999, JAJ

function [X,Y,Z] = show_xdc_MS (Th,kerf,width,height)

%  Do it for the rectangular elements

colormap('jet');
set(gca,'FontSize',12);
data = xdc_get(Th,'rect');
[N,M]=size(data);

%  Do the actual display
%disp(M);

for i=1:M
  x=[data(11,i), data(20,i); data(14,i), data(17,i)]*1000;
  y=[data(12,i), data(21,i); data(15,i), data(18,i)]*1000;
  z=[data(13,i), data(22,i); data(16,i), data(19,i)]*1000;
  c=data(5,i)*ones(2,2);
  
  %disp(c);
  X(i)=mean(x(:));
  Y(i)=mean(y(:));
  Z(i)=mean(z(:));
  
  %mesh(x,y,z,'LineWidth',1)
  %mesh(x,y,-z,'LineWidth',1)
  surf(x+1000*(5*width+4.5*kerf),y+1000*(1/2*height),z)
  hold on
end

%  Put som axis legends on

%Hc = colorbar('FontSize',12);
xlabel('x [mm]','FontSize',12)
ylabel('y [mm]','FontSize',12)
zlabel('z [mm]','FontSize',12)
grid
axis('image')
hold off

