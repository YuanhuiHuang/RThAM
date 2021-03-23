function pi2xOpen(pi)
piOpen(pi.piX);
piOpen(pi.piY);
piOpen(pi.piZ);

piSetAcc(pi.piX, 400);
piSetAcc(pi.piY, 400);
piSetAcc(pi.piZ, 400);

% fprintf(pi.piX,'ACC 40');                                                            % Default acceleration is 4000
% fprintf(pi.piY,'ACC 40');
end
