function [X, Y] = generateSequence(xLim, yLim, dx, dy, isSnake)
% 20190325 yuanhui change the RS scan to Snake scan
% 
if nargin <5
    isSnake = 1;
end

x = xLim(1):dx:xLim(2);
y = yLim(1):dy:yLim(2);

Nx = length(x);
Ny = length(y);

X = zeros(Nx, Ny);
Y = y;

if isSnake == 0 % Raster scan
    for i = 1:Ny
        X(:,i) = x;                                                                      % Always move in one direction
    end
else % Snake scan
   for i = 1:Ny
        if rem(i,2) == 1
            X(:,i) = x;
        else
            X(:,i) = x(end:-1:1);                                                        % Move back and forth
        end
    end
    
end



    

