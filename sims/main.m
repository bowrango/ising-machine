

out = sim("breadboard.slx");
toWksData = out.simout;
x = toWksData.Data;
t = toWksData.Time;

% pspectrum(x, t)

lyapExp = lyapunovExponent(x)