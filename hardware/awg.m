% References
% [1] https://siglentna.com/application-note/programming-example-create-a-stair-step-waveform-using-matlab-sdg1000x-sdg2000x-sdg6000x/
% [2] https://www.mathworks.com/help/instrument/generate-swept-sinusoid-and-capture-waveform.html

% See also
% https://siglentna.com/application-note/python-sdg-x-basics-lan/
% https://siglentna.com/application-note/programming-example-sdg-waveform-creation-with-python-and-sockets-no-visa/
% https://www.siglenteu.com/operating-tip/instrument-socket-and-telnet-port-information/

assert(~ismac)

% FIXME
dev = visadev('USB0::0xF4EC::0x1101::SDG6XEBC5R0143::INSTR');

% Configure VISA object properties
dev.OutputBufferSize = 20480000; % (20 MB)
dev.Timeout = 10; % (seconds)

% waveform 
points = {'8000', '8000', 'c0fa', 'c0fa', '0000', '0000', '3f06', '3f06', '7fff', '7fff'};
len = length(points);
data = zeros(1, len, 'uint16');
for i = 1:len
    data(i) = uint16(hex2dec(points{i}));
end

fileName = 'wave2.bin';
fileID = fopen(fileName, 'wb');
fwrite(fileID, data, 'uint16');
fclose(fileID);

fileID = fopen(fileName, 'rb');
binaryData = fread(fileID, 'uint16');
fclose(fileID);

% VISA command
visaStr = sprintf('C1:WVDT WVNM,wave2,FREQ,2000.0,AMPL,4.0,OFST,0.0,PHASE,0.0,WAVEDATA,%s', ...
                      mat2str(binaryData'));

writeline(dev, visaStr);
writeline(dev, 'C1:ARWV NAME,wave2'); % Assign waveform name
writeline(dev, 'C1:OUTP OFF'); % Ensure output is off before configuring
writeline(dev, 'C1:OUTP ON'); % Turn output on

clear dev;
