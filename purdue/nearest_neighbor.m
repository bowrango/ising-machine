%% Nearest Neighbor example code
% This code will run a maxcut problem on a 90x90 p-bit network. This
% problem has been explained thoroughly here https://arxiv.org/pdf/1907.09664.pdf
% (figure 2). 

% Modifying values in the 'parameter setup' section below should be enough
% to run the network. 

% Developed by Anirudh Ghantasala, Brian Sutton as part of Supriyo Datta's
% research group at Purdue University. 

clear all; close all; clc; clearvars;
%% Parameter setup
annealing_factor = 0.9;
Ti = 40;                % intial temperature
Tf = 0.5;               % final temperature
p = 1/4;                % percent of p-bits that will update per timestep
num_samples = 2;        % number of samples to collect
psl_accel("SetIPAndPort", "54.165.83.117", 1234); % ip address must be updated to match aws instance public ip address

%%
%Construct J from a B&W image. Try replacing purduePmaxcut.png with any
%other 90x90 pixel image to make it the ground state!
[img,map,alpha] = imread('ground_state.png');
temp = zeros(90,90);
temp(1:90,1:90) = img(1:90,1:90,1)';
img = temp;
img_size = size(img);
ROWS=img_size(1);
COLS=img_size(2);
Nm = ROWS*COLS;
J = zeros(Nm,Nm);
h = zeros(Nm,1);
J_send = zeros(Nm, 5);

for row=1:ROWS
	for col=1:COLS
            if (row == 1)
            up_row = ROWS;
            else
                up_row = row - 1;
            end
            up_col = col;
            up = (up_row-1)*COLS + up_col;

            if (row == ROWS)
                down_row = 1;
            else
                down_row = row + 1;
            end
            down_col = col;
            down = (down_row-1)*COLS + down_col;

            if (col == 1)
                left_col = COLS;
            else
                left_col = col-1;
            end
            left_row = row;
            left = (left_row-1)*COLS + left_col;

            if (col == COLS)
                right_col = 1;
            else
                right_col = col+1;
            end
            right_row = row;
            right = (right_row-1)*COLS + right_col;
            ii = (row-1)*COLS + col;

            J(ii,up) = -1*sign((img(up_row,up_col) == img(row, col)) - 0.5);
            J(ii,down) = -1*sign((img(down_row,down_col) == img(row, col)) - 0.5);
            J(ii,left) = -1*sign((img(left_row,left_col) == img(row, col)) - 0.5);
            J(ii,right) = -1*sign((img(right_row,right_col) == img(row, col)) - 0.5);
            
            J_send(ii,1) = 0;
            J_send(ii,2) = J(ii, up);
            J_send(ii,3) = J(ii, down);
            J_send(ii,4) = J(ii, left);
            J_send(ii,5) = J(ii, right);
	end
end


rc = psl_accel("SetWeights", J_send);
clear mm;
%%
% Prepare a random initial state.
X=rand(Nm,1);m=sign(X.*2-1);
T = Ti;
fprintf("Simulate until T is <= 0.5\n\n", Tf);

%While T is greater than Tf, 1. collect num samples, 2. reduce temperature,
%repeat
tic
while (T >= Tf)
  tic
    I0 = 1/T;

    rc = psl_accel("SetActivationParameters", T, p);
    fprintf("p = %f, T = %f\n", p, T);
    [rc, m] = psl_accel("SampleN", num_samples);
    m=squeeze(m);
  toc
    figure(1)
    clf(1)
    imagesc(reshape(m(end, :),ROWS,COLS));
    colormap(gray)
    refresh    

    T = T*annealing_factor; 
    
end
toc