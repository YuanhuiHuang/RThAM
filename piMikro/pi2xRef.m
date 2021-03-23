function pi2xRef(pi, method)
if nargin < 2
    method = 1;
end

piRef(pi.piX,method);
piRef(pi.piY,method);
piRef(pi.piZ,method);
