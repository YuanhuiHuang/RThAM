% This function checks if an error occured during the operation

function answer = piError(pi)
fprintf(pi, 'ERR?');

answer = fscanf(pi, '%c');
answer = str2double(answer);

if answer ~= 0
    warning('The following error occured: %i!\n', answer);
end

end