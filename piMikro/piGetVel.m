% This function finds the velocity of the stages

function v = piGetVel(pi)

fprintf(pi, 'VEL? 1');

v     = fscanf(pi, '%c');
place = strfind(v, '=');
v     = str2double(v(place+1:end));
end