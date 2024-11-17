%% All to All example code
% This example runs an AND gate on the All-To-All topology by default. To change the
% connection schemes, try modifying the flags, like setting J to 0 to observe a
% high temperature p-circuit which should occupy all states with equal
% probability. Any J can be substituted in place of the existing AND gate
% J. 

% Modifying values in the 'parameter setup' section below should be enough
% to run the network. 

% Developed by Anirudh Ghantasala, Brian Sutton as part of Supriyo Datta's
% research group at Purdue University. 

%% Parameter setup
Nm = 3;                                 % number of p-bits in the p-circuit, gets overriden by custom J if custom J size is present
NFPGA = 1000;                           % number of samples to collect
betaPSL = 1.0;                          % pseudo-inverse-temperature (higher is cooler, lower is hot, 0 leads to equal peaks in histogram)
aws_instance_ip_adr = "54.86.255.192";    % public ip address of aws instance which is running the fpga. Can be found in instance description on the aws ec2 console. 
dt_fpga = 1/(2*Nm);                     % how many p-bits to update in parallel per timestep
max_weight_for_rand_J = 3;              % maximum weight if random J is selected
create_random_J = 0;                    % Flag to create a random J
create_zero_J = 0;                      % Flag to create 0 J
connect_to_fpga = 1;                    % Flag to connect to FPGA

% The following is the J and h for an AND gate. Running with this should
% produce a histogram matching that found for the simulator (running and gate)
% at https://www.purdue.edu/p-bit/simulation-tool.html
J = [0 -2 -2; 
    -2 0 1; 
    -2 1 0];
h = [2;-1;-1];

if(create_random_J)
    J = (rand(Nm,Nm) * max_weight_for_rand_J)/2;
    J = J + J';
    J = J - diag(diag(J));
    h = rand(Nm,1);
end
if (create_zero_J)
    J = zeros(Nm,Nm);
    h = zeros(1,Nm)';
end
Nm = size(J,1);
dt_fpga = 1/(3*Nm);


%% Obtain boltzmann distribution for specified J,h matrices
Look = 2.^(Nm-1:-1:0);
PB = zeros(2^Nm,1);
E = 0;
for ii = 1:1:2^Nm
    m = sign(2*de2bi(ii-1,Nm,'left-msb')-1)';
    E = 0.5*m'*J*m+h.'*m;
    X2 = 1+Look*(1+m)/2;
    PB(X2) = PB(X2) + exp(-E);
end
Boltz = PB/sum(PB);


%% Run fpga
SumErrorPSL_fpga = 0;
simulation_size = 400;
Jfpga = zeros(simulation_size,simulation_size);
Jfpga(1:Nm, 1:Nm) = J;
hfpga = zeros(simulation_size,1);
hfpga(1:Nm) = h;
Jfpga(1:1+size(Jfpga,1):end) = hfpga;
if(connect_to_fpga)
    psl_accel("SetIPAndPort", aws_instance_ip_adr, 1234);
    rc = psl_accel("SetWeights", Jfpga);
    rc = psl_accel("SetActivationParameters", 1/betaPSL, dt_fpga);
    fprintf("Starting fpga emulation...\n");
    psl_accel("ResumeNetwork");
    psl_accel("ResumeNetwork");
    [rc,ms] = psl_accel("SampleN", NFPGA);
    fprintf("Recieved samples from fpga...\n");

    m_all = squeeze(ms);
    clear ms;
    PFPGA = zeros(2^Nm,1);
    for ii = 1:1:NFPGA
        ms = m_all(ii,1:Nm)';
        X2 = 1+Look*(1+ms)/2;
        PFPGA(X2) = PFPGA(X2) + 1;
    end
    PFPGA = PFPGA/sum(PFPGA);
    SumErrorPSL_fpga = SumErrorPSL_fpga + sqrt(sum(sum((abs(Boltz-PFPGA)).^2))./sum(sum((abs(Boltz)).^2)))

end

%% plot histograms for the fpga and the exact boltzmann distribution for Nm p-bits with the given J,h. 
a = 1:1:2^Nm;
if(connect_to_fpga)
    plots = [Boltz PFPGA];
    legend_str = {'Boltzmann', 'fpga'};
    dtfpga_str = sprintf(' %.4f',dt_fpga);
    str = {strcat('d_t fpga = ', dtfpga_str)};
else
    plots = [Boltz];
    legend_str = {'boltz'};
    str = "";
end

bar(a,plots);
legend(legend_str);
title('PSL Comparisons');
dim = [.7 .45 .3 .3];
annotation('textbox',dim,'String',str,'FitBoxToText','on');










      