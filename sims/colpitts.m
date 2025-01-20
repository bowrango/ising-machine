

close all

[t, out] = ode45(@breadboard,[0 500],[0; 0; 0]);

figure
plot(t, out*0.7)
grid on
legend('V_{C1}', 'I_{L}', 'V_{C2}')

x = out(:,1);
z = out(:,3);
% Phase Portrait
% figure
% plot(x+z, z)
% grid on

figure
pspectrum(z*0.7, t);
grid on

function dsdt = breadboard(t, s)
L = 850e-6;
R = 36;
Re = 510;
C0 = 47e-6;
C1 = 470e-9;
C2 = C1;
R1 = 3e3;
R2 = R1;
V0 = 15;

rho = sqrt(L/C1);
tau = sqrt(L*C1);
eps = C2/C1;

% Differential resistance of base-emitter
r = rho/30; % Paper
% r = 5; % Breadboard
% Break-point I–V characteristic
Vbp = 0.7;

a = rho/r;
b = R/rho;
c = V0/Vbp;
d = rho/Re;
e = R2*c/(R1+R2);

% a = 30;
% b = 0.8;
% c = 20;
% d = 0.08;
% e = 10;

x = s(1);
y = s(2);
z = s(3);

if z < e-1
    F = e-1-z;
else
    F = 0;
end

dsdt = ...
[
    y - a*F;
    c - x - b*y - z;
    (y - d*z)/eps;
];
end