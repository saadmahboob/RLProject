%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%% Simulation of PDS learning %%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
close all;

set_parameters;
load parameters

% Build parameters
action = IndActions(length(BEPActions),length(cardActions),length(throughputActions));
state = IndStates(length(bufferStates), length(channelStates), length(cardStates));
NumStates = length(bufferStates)*length(channelStates)*length(cardStates);
NumActions = length(BEPActions)*length(cardActions)*length(throughputActions);
% dynamics
dynamics_f = goodput_MDP(throughputActions, BEPActions, L);
dynamics_l = arrival_MDP(M,arrivalRate);
dynamics_x = card_MDP(cardStates, cardActions);
dynamics_h = channel_MDP(channelStates);
dynamics_b = buffer_MDP(bufferStates, cardStates, BEPActions, cardActions, throughputActions, B, dynamics_l, dynamics_f);
dynamics_s = state_MDP(bufferStates,channelStates,cardStates,BEPActions,cardActions,throughputActions,dynamics_b,dynamics_h,dynamics_x);
% Constraints
[BufferCost, HoldingCost, OverflowCost] = set_buffer_cost(dynamics_l,dynamics_f,bufferStates,channelStates,cardStates,BEPActions,cardActions,throughputActions,B,eta);
[RequiredPower, Ptx] = set_power_cost();
mu_max = 4;
delayConstraint =4;
ck = known_cost(bufferStates,channelStates, cardStates, BEPActions, cardActions, throughputActions, dynamics_f,mu,RequiredPower);
cu = unknown_cost(bufferStates,channelStates,cardStates,dynamics_l,mu,eta,B);
niter = 75000;
discountInfinite = gamma*ones(1,niter);
discountInfinite = discountInfinite.^[1:niter];

%% One run conventional Q Learning
initialState = [1,1,1];
niter = 75000;
[Q,BufferQL,HoldingQL,OverflowQL,PowerQL,CostQL,MuQL] = QLearning(state,action,bufferStates,channelStates,cardStates,BEPActions,cardActions,throughputActions, initialState, RequiredPower,OverflowCost,BufferCost,HoldingCost,delayConstraint,niter,dynamics_s,gamma);
figure()
plot(CMA(BufferQL),'r','LineWidth',1);
title('Cumulative average buffer cost');
figure()
plot(CMA(HoldingQL),'r','LineWidth',1);
title('Cumulative average holding cost')
figure()
plot(CMA(OverflowQL),'r','LineWidth',1);
title('Cumulative average overflow cost');
figure()
plot(CMA(PowerQL),'r','LineWidth',1);
title('Cumulative average power cost');
figure()
plot(CMA(CostQL),'r','LineWidth',1);
title('Cumulative average cost');

%% Conventional Q learning Average
initialState = [1,1,1];
niter = 75000;
naverage = 1000;
Buffer=zeros(niter,naverage);
Holding=zeros(niter,naverage);
Overflow=zeros(niter,naverage);
Power =zeros(niter,naverage);
for n=1:naverage
    fprintf('n: %d \n',n);
    [Q,BufferSeq,HoldingSeq,OverflowSeq,PowerSeq,CostSeq,MuSeq] = QLearning(state,action,bufferStates,channelStates,cardStates,BEPActions,cardActions,throughputActions, initialState, RequiredPower,OverflowCost,BufferCost,HoldingCost,delayConstraint,niter,dynamics_s,gamma);
    Buffer(:,n) = BufferSeq;
    Holding(:,n) = HoldingSeq;
    Overflow(:,n) = OverflowSeq;
    Power(:,n) = PowerSeq;
end


%% PDS learning average
initialState = [1,1,1];
niter = 75000;
[V_PDS, V, BufferCostPDS, requiredPower, holding, overflow, Mu, Cost] = PDS_learning(state,action,bufferStates,channelStates,cardStates,BEPActions,cardActions,throughputActions,dynamics_l,dynamics_h,dynamics_x, ck, cu, RequiredPower, BufferCost, HoldingCost, OverflowCost,mu,gamma,delayConstraint,mu_max,niter,initialState,dynamics_f,B,M,eta);
figure()
plot(CMA(BufferCostPDS),'b','LineWidth',1);
hold on
plot(CMA(BufferQL),'r','LineWidth',1);
legend('PDS learning','Q learning');
title('Cumulative average buffer cost');
figure()
plot(CMA(requiredPower),'b','LineWidth',1);
hold on
plot(CMA(PowerQL),'r','LineWidth',1);
legend('PDS learning','Q learning');
title('Cumulative average power cost');
figure()
plot(CMA(holding),'b','LineWidth',1);
hold on
plot(CMA(HoldingQL),'r','LineWidth',1);
legend('PDS learning','Q learning');
title('Cumulative average holding cost');
figure()
plot(CMA(overflow),'b','LineWidth',1);
hold on
plot(CMA(OverflowQL),'r','LineWidth',1);
legend('PDS learning','Q learning');
title('Cumulative average overflow cost');
figure()
plot(CMA(Mu),'b','LineWidth',1);
title('Cumulative average lagrange multiplier');
figure()
plot(CMA(Cost),'b','LineWidth',1);
hold on
plot(CMA(CostQL),'r','LineWidth',1);
title('Cumulative average cost');





