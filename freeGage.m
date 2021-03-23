function freeGage(DAQ)

if nargin == 1
    ret = CsMl_FreeSystem(DAQ);                                                       % Free the system up
else 
    ret = CsMl_FreeAllSystems();  
end
