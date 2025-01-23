
nOsc = 50;

% Problem matrix
rng default
Q = rand(nOsc);
Q = Q+Q.';
Q(1:nOsc+1:end)=0;

% Classical tabu search
g = graph(Q);
qb = maxcut2qubo(g);
sol = solve(qb);

% Ising matrix
J = -Q;

tstop = 10;
dt = 2e-3;

% Coupling schedule (ramp)
K = 7;
a1.k = (K-1)/tstop;
f1 = @(t, args) 1 + t*args.k;

% Sync schedule (square wave)
a2.T = tstop/20;
f2 = @(t, args) 1+2*tanh(10*cos(2*pi*t/args.T));

drift = @(t,X) Kuramoto(X, f1(t, a1), f2(t, a2), J);

% Noise schedule (constant)
Kn = 0.2;
diffusion = @(t,X) Kn*eye(nOsc);

mdl = sde(drift, diffusion, StartState=rand(nOsc, 1));
[S, T] = simulate(mdl, tstop/dt, DeltaTime=dt);

% Integrate
cuts = zeros(size(T));
nodes = 1:nOsc;
for k = 1:length(T)
    mask = true(nOsc,1);
    x1 = find(mod(round(S(k,:)), 2));
    mask(x1) = false;
    x2 = nodes(mask);
    cuts(k) = -sum(J(x1, x2), "all");
end

tiledlayout

nexttile
plot(T, S); hold on; grid on;
ylabel('phases (\pi)')

nexttile
yyaxis left
plot(T, cuts); grid on
yline(-sol.BestFunctionValue, LineWidth=2)
ylabel('cut value')
yyaxis right
plot(T, f1(T, a1)); hold on; grid on
plot(T, f2(T, a2)); grid on
xlabel('time (cycles)');

function dxdt = Kuramoto(x, K, Ks, J)
% Equation 4.16
n = length(x);
dxdt = zeros(n,1);
for ii = 1:n
   % Coupling
    dxdt(ii) = -K*J(ii, :)*tanh(10*sin(pi*(x(ii) - x)));
end

% Sync
dxdt = dxdt - Ks*sin(2*pi*x);

% Normalize
dxdt = dxdt/pi;

% TODO Lyapunov analysis
% tanh(sin()) used for coupling changes the cos(.) term in (4.7) to a 
% triangle function (see page 77).
end
