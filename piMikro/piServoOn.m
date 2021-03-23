% This function turns on the servo of the motor for closed loop operation

function piServoOn(pi, switchOn)
if switchOn == 1
    fprintf(pi, 'SVO 1 1');
elseif switchOn == 0
    fprintf(pi, 'SVO 1 0');
end

end