
% https://www.mathworks.com/help/matlab/supportpkg/communicate-with-spi-device-on-arduino-hardware.html
% Adapted for MCP4251-103E/P-ND

% Layout (Arduino Uno -> MCP4251)
% 10 -> 1  CS
% 11 -> 3  SDI
% 12 -> 13 SDO
% 13 -> 2  SCK

clear ard digpot
ard = arduino();
digpot = device(ard, 'SPIChipSelectPin', 'D10');
Rab = 10000;
Rw = 75;
n = 257;
% while true
for wp = 0:5:n-1
    % Resistance of channel 1 is across pins 6 and 7. Measured value from 
    % multimeter is within ~10ohms
    writeRead(digpot, [hex2dec('12'), wp]); % ~0.03s
    R = Rab*(n-wp)/n + Rw;
    fprintf('%d Ohm\n', R);
end
% end


