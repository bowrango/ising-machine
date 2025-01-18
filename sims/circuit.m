
nOsc = 2;

c1 = 1e-4;
c2 = 1e-4; 
c12 = 1e-4;
C = [c1+c12 -c12; -c12 c2+c12];
invC = inv(C);

r1 = 5e4;
r2 = 5e4;
R = [r1 r2];
invR = diag(1./R);

v0 = 5*ones(nOsc, 1);
dt = 0.01;
T = 25;

% random noise gain
rng default
Kn = 0.2;
gV = Kn*randn(nOsc);

drift = @(t, X) -invC*invR*X;
diffusion = @(t, X) -invC*invR*gV;

sdeMdl = sde(drift, diffusion, StartState=v0);

[sdeV, t] = simulate(sdeMdl, T/dt, NTrials=1, DeltaTime=dt);

% State space
A = -invC*invR;
B = eye(nOsc); % TODO add noisy control/source
C = eye(nOsc);
D = eye(nOsc);
ssMdl = ss(A,B,C,D);

% control input
% u = [sin(t); cos(t)];
u = zeros(length(t), 2);

[vss, t_out] = lsim(ssMdl, u, t, v0);

% Plot
tiledlayout(2,1);

nexttile
plot(t, squeeze(sdeV))
title('sde'); grid on
ylim([-1 max(v0)])
xlim([0 T])

nexttile
plot(t_out, vss)
title('ss'); grid on
ylim([-1 max(v0)])
xlim([0 T])



