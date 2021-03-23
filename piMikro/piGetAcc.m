% This function finds the acceleration of the stages

function acc = piGetAcc(pi)

fprintf(pi, 'ACC? 1');                                                               % Ask for acceleration of axis corresp. to port obj. pi

acc   = fscanf(pi, '%c');                                                            % Read answer from serial port obj. pi
place = strfind(acc, '=');                                                           % Look for position of '='
acc   = str2double(acc(place+1:end));                                                % Get number (after '=')
end