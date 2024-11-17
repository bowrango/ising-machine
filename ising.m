
% Reference
% [1] https://arxiv.org/pdf/1903.07163

nOsc = 8;
h = zeros(nOsc, 1);
J = zeros(nOsc, nOsc);

J(1, 2) = -1; J(2, 3) = -1; J(3, 4) = -1; J(4, 5) = -1;
J(5, 6) = -1; J(6, 7) = -1; J(7, 8) = -1; J(1, 8) = -1; 
J(1, 5) = -1; J(2, 6) = -1; J(3, 7) = -1; J(4, 8) = -1;

J = J + J.';

tstop = 5; 
tstep = 1e-3;

% SYNC magnitude 
As = 1; 
% coupling strength
Ac = 0.1; 
% noise gain
An = 0.1;

F = @(t,X) KuramotoF_sin(X, Ac*t/tstop, As, nOsc, h, J); 
G = @(t,X) An*eye(nOsc);

rng default

obj = sde(F, G, 'StartState', rand(nOsc, 1));
[S, T] = simulate(obj, tstop/tstep, 'DeltaTime', tstep);

figure
plot(T, S, 'LineWidth', 2); 
legend('\phi_1', '\phi_2', '\phi_3', '\phi_4', '\phi_5', '\phi_6', '\phi_7', '\phi_8');
xlabel('time (cycles)');
ylabel('phases (\pi)'); 
box on; grid on;

function fout = KuramotoF_sin(x, Ac, As, n, h, J) 

for c = 1:n
fout(c, 1) = - Ac*h(c)*sin(pi*x(c)) - Ac*J(c, :)*sin(pi*(x(c) - x));
end

fout = (fout - As * sin(2*pi*x))/pi;
end