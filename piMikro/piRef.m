% This function performs referencing of the motors

function piRef(pi, method)
if nargin < 2
    method = 1;
end

switch method
    case 1                                                                 % Limit switch
        fprintf(pi,'FRF 1');
    case 2                                                                 % Negative limit
        fprintf(pi,'FNL 1');
    case 3                                                                 % Positive Limit
        fprintf(pi,'FPL 1');
    otherwise                                                              % Go the the limit switch
        fprintf(pi,'FRF 1');
end

end