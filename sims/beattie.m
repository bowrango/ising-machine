

[tSol, xSol] = ode45(@(t,x) rlc(t, x), [0 10], [0;0]);

% FIXME
function dx = rlc(t, x)
    
    R0 = 4.7e3;
    Rp = 47e3;
    L = 23.5;
    C = 100e-6;
    U0 = 0.24;

    u    = x(1);
    i_L  = x(2);

    i_n_val = u^3 / (3*U0^2) - u;

    e_p_val = sin(t);
    i_c_val = sin(t);

    du_dt = - (1/C) * ( i_L + u/R0 + i_n_val + (u - e_p_val)/Rp + i_c_val );
    diL_dt = u / L;

    dx = [ du_dt; diL_dt ];
end