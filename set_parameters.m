addpath('toolbox/');
% Power management parameters
on = 1;
off = 2;
s_on = 1;
s_off = 2;

% Channel parameters
H = [-18.82, -13.79, -11.23, -9.37, -7.8, -6.3, -4.68, -2.08]; % in dB


% PHY parameters
Poff = 0;                               % W, consumption of the wireless card in off state
Pon = 320;                              % mW, consumption of the wireless card in on state
Ptr = 320;                           % mW, transition power, high value to penalize switching
L = 5000;                               % bits/packets
bitsPerSymbol = 1:10;
symbolRate = 500000;
symbolDuration = 1/symbolRate; 
noisePower = 1e-5;
N0 = noisePower/symbolRate; 

% Define states and actions
B = 25;                                 % capacity of the buffer
bufferStates = 0:B;                     % states of the buffer
channelStates = 10.^(H/10);             % states of the channels (SNR)
cardStates = [on, off];                 % states of the wireless card
PLR = [0.01,0.02,0.04,0.08,0.16];                     % %, Packet Loss Rate
BEPActions = PLR2BEP(PLR,L);              % %, Bit Error Probability
cardActions = [s_on, s_off];
throughputActions = 0:10;
NumberStates = length(bufferStates)*length(channelStates)*length(cardStates);  % Number of states of the MDP
NumberActions = length(BEPActions)*length(cardActions)*length(throughputActions); % Number of actions of the MDP

% Packet arrival parameters
arrivalRate = 9;                      % packets/time slot, Average number of packets arrival
M = B;                                % Maximum number of arrivals

% General parameters
gamma = 0.98;
dT = 0.01;
holding_cost = 4;
eta = gamma/(1 - gamma);
mu = 0.1;

save parameters;