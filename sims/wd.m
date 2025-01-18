
clear; clc;

fs = 48000;       
Ts = 1/fs;      
dur = 0.01;    
N   = floor(dur*fs);

R  = 1000;          % ohms
L  = 0.1;           % H
C  = 1e-6;          % F

% Excitation voltage source
Vin = zeros(N,1);
Vin(1:floor(N/2)) = 1.0;
% Vin  = sin(2*pi*f0*(0:N-1)'/fs);

% Define Port Resistances
R0_R = R;
R0_L = 2*L / Ts;
R0_C = 1 / (2*C / Ts);

bL_prev = 0;
bC_prev = 0;

Vout = zeros(N,1);
i_R = zeros(N,1);
i_L = zeros(N,1);
i_C = zeros(N,1);
for n = 1:N
    
    b_R = 0;
    b_L = bL_prev;
    b_C = bC_prev;

    Rsum = R0_R + R0_L + R0_C;
    a_R = Vin(n) + b_R;  
    a_L = b_L;        
    a_C = b_C;        
    
    Vnode = (R0_R*a_R + R0_L*a_L + R0_C*a_C) / Rsum;

    b_R_new = 2*Vnode - a_R;
    b_L_new = 2*Vnode - a_L;
    b_C_new = 2*Vnode - a_C;
    
    bL_prev = b_L_new;
    bC_prev = b_C_new;

    Vout(n) = Vnode;

    i_R(n) = Vnode / R;
    i_L(n) = (a_L - b_L_new)/(2*R0_L);
    i_C(n) = (a_C - b_C_new)/(2*R0_C);
end

time = (0:N-1).'*Ts;

figure('Name','Parallel RLC via WDF','Color','w','Position',[100 100 900 600]);

subplot(3,1,1);
plot(time, Vin, 'LineWidth',1.5); grid on;
xlabel('Time (s)'); ylabel('Amplitude (V)');
title('excitation voltage');

subplot(3,1,2);
plot(time, Vout, 'LineWidth',1.5); grid on;
xlabel('Time (s)'); ylabel('Amplitude (V)');
title('node voltage');

subplot(3,1,3);
plot(time, i_R, 'r',  time, i_L, 'b',  time, i_C, 'g','LineWidth',1.2);
grid on;
xlabel('Time (s)'); ylabel('Current (A)');
legend('i_R','i_L','i_C');
title('current');