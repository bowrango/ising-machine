
clear all

ard = arduino();

dev = device(ard, 'SPIChipSelectPin', 'D10');

% MCP4251
Rab = 10000;
Rw = 75;
n = 257;

for wp = 0:5:n-1
    writeRead(dev, [hex2dec('12'), wp]);
    R = Rab*(n-wp)/n + Rw;
    fprintf('%d Ohm\n', R);
    pause(0.5)
end