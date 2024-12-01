
remote_ip = '192.168.55.110';

% should be for socket
port = 5025; % or 5024?

try
    t = tcpclient(remote_ip, port);
catch ME
    rethrow(ME);
end


try
    SocketSend(t, '*RST');              % Reset to factory defaults
    SocketSend(t, 'C1:BSWV WVTP,SQUARE'); % Set CH1 Wavetype to Square
    SocketSend(t, 'C1:BSWV FRQ,1000');  % Set CH1 Frequency
    SocketSend(t, 'C1:BSWV AMP,1');    % Set CH1 Amplitude
catch ME
    rethrow(ME);
end

clear t;
disp('Connection closed.');


function SocketSend(t, cmd)
try
    write(t, [cmd, newline]);
    pause(1);
catch ME
    rethrow(ME);
end
end
