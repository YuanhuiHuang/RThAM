% stephan kellnberger
% 2010/12/06
% trig start
% version 1.0
function trig = trig_start(buffer,Timeout)
visa_brand = 'ni';
% visa_address = 'TCPIP::146.107.56.78::INSTR';
% visa_address = 'TCPIP::146.107.56.175::INSTR';
% visa_address = 'USB0::2391::11271::MY52801014::0::INSTR';
visa_address = 'USB0::0x1AB1::0x0641::DG4E171901391::INSTR'; % RIGOL DG4162
% visa_address = 'USB0::0x09C4::0x0400::DG1D154402292::INSTR';
% buffer = 20 * 1024; %20 KiB

trig = visa(visa_brand, visa_address, 'InputBufferSize', buffer, ...
    'OutputBufferSize', buffer,'Timeout',Timeout);
