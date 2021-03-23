% This function reboots the controller

function piReboot(pi)
fprintf(pi,'RBT');

piServoOn(pi,1);
piRef(pi,1);

piSetVel(pi,5);
end