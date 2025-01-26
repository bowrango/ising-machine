
nOsc = 2;

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
% The true K of each oscillator depends on PPV and perturbation amplitude
% from other oscillators
K = 10;
a1.k = (K-1)/tstop;
coupling = @(t, args) 1 + t*args.k;

% Sync schedule (square wave)
a2.T = tstop/20;
sync = @(t, args) 1+2*tanh(10*cos(2*pi*t/args.T));

% TODO discrete points match Ising model. Rounding explains cut jitter
% Model phase state vector X
drift = @(t,X) phaseModel(X, coupling(t, a1), sync(t, a2), J);

% Noise schedule (constant)
% Curious how this related to Boltzmann re: Eq 4.17
Kn = 0;
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

tiledlayout(3,1)

nexttile
plot(T, S)
grid on
ylabel('phases (\pi)')

nexttile
hold on
grid on
yline(-sol.BestFunctionValue, LineWidth=2)
plot(T, cuts)
ylabel('cut value')
hold off

nexttile
hold on
grid on
plot(T, coupling(T, a1))
plot(T, sync(T, a2))
xlabel('time (cycles)');
hold off

function dxdt = phaseModel(x, K, Ks, J)
% Adapted Kuramoto

% FIXME Lyapunov analysis
% tanh(sin()) used for coupling changes the cos() term in (4.7) to
% triangle function (see page 77). Should be dEdt <= 0
shift = x - x.';
E = -K*sum(J(:).*cos(shift(:))) + Ks*sum(cos(2*x));

n = length(x);
dxdt = zeros(n,1);
for ii = 1:n
    % Coupling, sync, and normalize
    % 4.16
    dxdt(ii) = (-K*J(ii,:)*tanh(10*sin(pi*(x(ii)-x))) - Ks*sin(2*pi*x(ii)))/pi;

    % Basic Kuramoto (4.3 and 4.4)
    % dxdt(ii) = -K*J(ii, :)*sin(x(ii) - x);
    % E(ii) = -K*J(ii, :)*cos(x(ii) - x);
end
end
