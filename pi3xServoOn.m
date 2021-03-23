function pi3xServoOn(pi,switchOn)

switch switchOn
    case 1
        piServoOn(pi.X,1);
        piServoOn(pi.Y,1);
        piServoOn(pi.Z,1);
    case 0
        piServoOn(pi.X,0);
        piServoOn(pi.Y,0);
        piServoOn(pi.Z,0);
end
