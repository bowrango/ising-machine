
clear
ard = arduino();
mcp = device(ard, 'SPIChipSelectPin', 'D10');

writeRegister(mcp, 0x00, 0x00);
writeRegister(mcp, 0x01, 0x00);

for pinNum = 0:15
    if pinNum < 8
        % Port A
        latchDataA = bitset(uint8(0), uint8(pinNum));
        latchDataB = 0;                     
    else
        % Port B
        latchDataA = 0;
        latchDataB = bitset(uint8(0), pinNum-8, 1);
    end

    writeRegister(mcp, 0x14, latchDataA);  % OLATA
    writeRegister(mcp, 0x15, latchDataB);  % OLATB

    pause(0.1);

    % Turn off pins
    writeRegister(mcp, 0x14, 0x00);
    writeRegister(mcp, 0x15, 0x00);
end

function writeRegister(spiObj, registerAddress, dataByte)
% Writes single byte to MCP23S17 register.
% opcode = 0x40 for write (hardware address = 0, see datasheet)
opcode = 0x40;
writeRead(spiObj, [opcode, registerAddress, dataByte]);
end