
% https://www.mathworks.com/help/matlab/supportpkg/communicate-with-spi-device-on-arduino-hardware.html
% Adapted for MCP4251
clear ard digpot
ard = arduino();
digpot = device(ard, 'SPIChipSelectPin', 'D10');
Rab = 10000;
Rw = 75;
n = 257;
while true
for wp = 0:5:n-1
    writeRead(digpot, [hex2dec('12'), wp]); % ~0.03s
    R = Rab*(n-wp)/n + Rw;
    fprintf('%d Ohm\n', R);
end
end
