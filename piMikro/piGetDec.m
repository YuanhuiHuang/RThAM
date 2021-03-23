% This function finds the decceleration of the stages

function dec = piGetDec(pi)

fprintf(pi, 'DEC? 1');

dec   = fscanf(pi, '%c');
place = strfind(dec, '=');
dec   = str2double(dec(place+1:end));
end