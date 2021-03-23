if exist('DAQ', 'var')
    freeGage(DAQ);
end

clear all;

fclose(instrfind);
delete(instrfind);