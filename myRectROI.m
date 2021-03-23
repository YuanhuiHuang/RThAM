function RectPos = myRectROI(himage)
figure(1001),imagesc(himage.CData)
set(1001,'Units','Pixels');
axis image
title('draw rectangle for ROI')
% k = waitforbuttonpress;
rect=imrect;
RectPos = wait(rect);
% RectPos = getrect

RectPos = round(RectPos);
RectPos(RectPos<0) = 0;

[ImX,ImY] = size(himage.CData);
if RectPos(3)>ImX
    RectPos(3) = ImX;
    RectPos(3) = RectPos(3) - RectPos(1);
end

if RectPos(4)>ImY
    RectPos(4) = ImY;
    RectPos(4) = RectPos(4) - RectPos(2);
end
close(1001)
