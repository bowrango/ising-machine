
nOsc = 10;

% ising model problem matrix
rng default
W = rand(nOsc);
J = (W+W.');
J(1:nOsc+1:nOsc^2)=0;

% classical tabu search
g = graph(J);
qb = maxcut2qubo(g);
sol = solve(qb);

J = -J;
h = zeros(nOsc,1);

tstop = 40;
tstep = 2e-3;

% couple strength schedule (linear)
K = 7;
a1.k = (K-1)/tstop;
f1 = @(t, args) 1 + t*args.k;

% sync schedule (square wave)
a2.T = tstop/20;
f2 = @(t, args) 1+2*tanh(10*cos(2*pi*t/args.T));

F = @(t,X) Kuramoto(X, f1(t, a1), f2(t, a2), nOsc,h,J);

% noise schedule (constant)
An = 0.2;
G = @(t,X) An*eye(nOsc);

obj = sde(F, G, 'StartState', rand(nOsc, 1));
[S, T] = simulate(obj, tstop/tstep, 'DeltaTime', tstep);

% integrate
cuts = zeros(size(T));
for k = 1:length(T)
    ix = find(mod(round(S(k,:)), 2));
    cuts(k) = -sum(sum(J(ix, setdiff(1:nOsc, ix))));
end

tiledlayout

nexttile
plot(T, S); hold on; grid on;
ylabel('phases (\pi)')

nexttile
yyaxis left
plot(T, cuts); grid on
ylabel('cut value')
yyaxis right
plot(T, f1(T, a1)); hold on; grid on
plot(T, f2(T, a2)); grid on
legend('', 'K', 'K_s')
xlabel('time (cycles)');

function fout = Kuramoto(x, K, Ks, n, h, J)

for c = 1:n
   % coupling
    fout(c, 1) = - K*h(c)*tanh(10*sin(pi*x(c))) - K*J(c, :)*tanh(10*sin(pi*(x(c) - x)));
end

% sync
fout = (fout - Ks*sin(2*pi*x)) / pi;
end