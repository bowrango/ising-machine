

% https://arxiv.org/pdf/1710.02015

% Analyze oscillator steady-state xs(t) under small perturbation b(t).
% Differential algebraic equation:

% d(q(xs(t) + b(t)))/dt + f(xs(t) + b(t)) = 0

% Steps to compute the scalar quality factor Q

% 1) Compute periodic steady state solution xs by shooting method
% 2) Linearize functions q and f along xs. Calculate Jacobian matrices C and G
% 3) Solve for X(T) of the matrix DAE C'(t)*X(t) + G(t)*X(t) = 0
% 4) Perform eigenanalysis on X(T) to obtain λ2 and calculate Q

L = 0.5*1e-9; % (0.5nH)
C = 0.5*1e-9; % (0.5nF)
R = -Inf; % FIXME
K = 1;

%f = @(v) K*(v - tanh(1.01*v)); % (1/Ohms)
fp = @(v) K*(1 - 1.01 * sech(1.01*v).^2);

v0 = 0.3;
dv0 = 0;
x0 = [v0; dv0];
tspan = [0 10e-7];

circuit = @(t, x) [
    x(2)
    (-x(1)/(L*R) - fp(x(1))/C - x(1)/(L*C))
];

[t, x] = ode45(circuit, tspan, x0);

v = x(:, 1);
plot(t, v);
xlabel('time (s)');
ylabel('voltage (V)');
grid on;
