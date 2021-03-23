% Start the pi motor controller:

function pi = piStart(portnr)

% Create VISA-serial objects connected to serial ports COMi using
% NI VISA interface

% switch axis
%     case 1
%         pi = visa('ni', 'ASRL6::INSTR');                                             % Port 3 (y-Axis)
%     case 2
%         pi = visa('ni', 'ASRL7::INSTR');
%     case 3
%         pi = visa('ni', 'ASRL5::INSTR');  % Port 4 (x-Axis)
%     otherwise
%         error 'unknown axis!';
% end

% pi = serial('COM11');
% vu = visa('agilent', 'USB::0x1234::125::A22-5::INSTR');
pi = visa('ni', ['ASRL' num2str(portnr) '::INSTR']);

% pi.BaudRate        = 38400;                                                          % Default Baud rate: #signals/s
pi.BaudRate        = 115200;                                                          % Baud rate: #signals/s
pi.InputBufferSize = 1e5;
pi.Timeout         = 10;