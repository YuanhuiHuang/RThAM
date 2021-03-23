function ret = isDirExist(directory, createFlag)
if nargin < 2
    createFlag = 1;
end

xyz = exist(directory, 'dir');

if  xyz == 0 && ~createFlag
    ret = 0;
elseif xyz == 7 && ~createFlag
    ret = 7;
elseif  xyz == 0 && createFlag
    mkdir(directory);
    ret = 5; % successfully created the directory
elseif xyz == 7 && createFlag
    warning('Directory already exists, be careful!');
    ret = -1;
end
% isDirExist.m
% Displaying isDirExist.m.