function pi2xServoOn(pi,switchOn)

switch switchOn
    case 1
        piServoOn(pi.piX,1);
        piServoOn(pi.piY,1);
    case 0
        piServoOn(pi.piX,0);
        piServoOn(pi.piY,0);
end