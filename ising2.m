
%G22 = importdata('wherever_set1_is/g1.rud’, ’ ’, 1); p = G22.data(:,1);
%n = G22.data(:,2);
%w = G22.data(:,3);
%W = sparse(p, n, w, nOsc, nOsc);

% problem matrix
nOsc = 100;
h = rand(nOsc, 1);
W = rand(nOsc);
J = - W - W.';

% coupling strength
Ac = 7;
% noise gain
An = 0.1; 

tstop = 40; tstep = 2e-3;

% Ac schedule
a1.k = (Ac-1)/tstop;
f1 = @(t, args) 1 + t*args.k;

% As schedule
a2.T = tstop/20;
f2 = @(t, args) 1+2*tanh(10*cos(2*pi*t/args.T));

F = @(t,X) KuramotoF(X, f1(t, a1), f2(t, a2), nOsc,h,J); 
G = @(t,X) An*eye(nOsc);

obj = sde(F, G, 'StartState', rand(nOsc, 1));
[S, T] = simulate(obj, tstop/tstep, 'DeltaTime', tstep);

figure
plot(T, S)
box on; grid on;

cuts = zeros(size(T));
for k = 1:length(T)
    ix = find(mod(round(S(k,:)), 2));
    cuts(k) = -sum(sum(J(ix, setdiff(1:nOsc, ix)))); 
end

figure; plot(T, cuts);

function fout = KuramotoF(x, Ac, As, n, h, J) 
% Schedules:
% square wave SYNC
% step constant noise
% linear coupling strength

k = 10; % sharpness of square wave
for c = 1:n
    fout(c, 1) = - Ac * h(c) * tanh(k*sin(pi*x(c))) - Ac * J(c, :) * tanh(k*sin(pi*(x(c) - x)));
end
fout = (fout - As * sin(2*pi*x))/pi; 
end