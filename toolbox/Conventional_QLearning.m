function [Q, BufferCost, RequiredPower, holding, overflow, Mu, Cost] = Conventional_QLearning(state, action, bufferStates,channelStates,cardStates,BEPActions,cardActions,throughputActions,initialState,niter,dynamics_b,dynamics_h,dynamics_x,RequiredPower,BufferCost,HoldingCost,OverflowCost,mu,gamma,delayConstraint,mu_max)
% Performs conventional Q learning on the MDP
% Inputs
%   state:                  matrix which returns the index of the state
%                           from the indices (bufferState, channelState, cardState)
%   action:                 matrix which returns the index of the action
%                           from the indices (BEPAction, cardAction,
%                           throughputAction)
%   bufferStates:           possible states of the buffer
%   channelStates:          possible states of the channels
%   cardStates:             possible states of the wireless card
%                                       [on, off]
%   BEPActions:             possible values for BEP
%   cardActions:            possible dynamic power management actions
%                                       [s_on, s_off]
%   throughputActions:      possible values for the throughput
%   initialState:           initial state indices of the system (b,h,x)
%   niter:                  number of iterations to perform
%   dynamics_b:             matrix of transition of the buffer states
%   dynamics_h:             matrix of transition of the channel states
%   dynamics_x:             matrix of transition of the card states
%   rau:                    required power matrix
%                                       [lengthChannelxlenghtCardStatesxlengthBEPxlengthcardActionsxlengthZ]
%   g:                      buffer cost matrix
%                                       [lengthBufferxlengthCardxlengthBEPxlengthCardxlengthZ]
%   holding_cost:           holding cost matrix
%                                       [lengthBufferxlengthCardxlengthBEPxlengthCardxlengthZ]
%   overflow_cost:          overflow cost matrix
%                                       [lengthBufferxlengthCardxlengthBEPxlengthCardxlengthZ]
%   mu:                     lagrangian multiplier
%   gamma:                  learning parameter
%   delayConstraint:        delay constraint
%   mu_max:                 maximum value of the lagrangian multiplier (4)
% Outputs
%   Q:                      optimized state-action value function
%   BufferCost:           	sequence of buffer cost
%   RequiredPower:          sequence of required power
%   holding:                sequence of holding cost
%   overflow:               sequence of overflow cost
%   Mu:                     sequence of lagrangian multiplier
%   Cost:                   sequence of lagrangian costs
%                                       c(s,a) = rau(s,a) + mu*g(s,a)

%disp('Start conventional Q learning');
%tic;
% Initialization
NumStates = length(bufferStates)*length(channelStates)*length(cardStates);
NumActions = length(BEPActions)*length(cardActions)*length(throughputActions);
Q = zeros(NumStates,NumActions);
BufferCost = zeros(1,niter);
RequiredPower = zeros(1,niter);
holding = zeros(1,niter);
overflow = zeros(1,niter);
Mu = zeros(1,niter);
Cost = zeros(1,niter);

% Iterations
CurrentindBuffer = initialState(1);
CurrentindChannel = initialState(2);
CurrentindCard = initialState(3);
currentState = state(CurrentindBuffer, CurrentindChannel, CurrentindCard);

for t=1:niter
    
    % Take action (BEP,y,z)
    [~,indAction] = min(Q(currentState,:));
    [indBEP, indCardAction, indZ] = ind2sub(size(action),indAction);
    
    % Observe next state (b,h,x)
    NextindBuffer = simu_b(CurrentindBuffer,CurrentindChannel,CurrentindCard,indBEP,indCardAction,indZ, dynamics_b);
    NextindChannel = simu_h(CurrentindChannel,dynamics_h);
    NextindCard = simu_x(CurrentindCard,indCardAction,dynamics_x);
    NextState = state(NextindBuffer,NextindChannel,NextindCard);
    
    % Observe the cost
    currentBufferCost = BufferCost(CurrentindBuffer,CurrentindChannel,CurrentindCard,...
                            indBEP,indCardAction,indZ);
    currentHoldingCost = HoldingCost(CurrentindBuffer,CurrentindChannel,CurrentindCard,...
                            indBEP,indCardAction,indZ);
    currentOverflowCost = OverflowCost(CurrentindBuffer,CurrentindChannel,CurrentindCard,...
                            indBEP,indCardAction,indZ);
    currentRequiredPower = RequiredPower(CurrentindBuffer,CurrentindChannel,CurrentindCard,...
                            indBEP,indCardAction,indZ);
    currentCost = currentRequiredPower + mu*currentBufferCost;
    
    % Update Q
    optQ = min(Q(NextState,:));
    Q(currentState,indAction) = (1 - (1/t))*Q(currentState,indAction) + (1/t)*(currentCost + gamma*optQ);
    
    % Update BufferCost
    BufferCost(t) = currentBufferCost;
    % Update holding
    holding(t) = currentHoldingCost;
    % Update overflow
    overflow(t) = currentOverflowCost;
    % Update RequiredPower
    RequiredPower(t) = currentRequiredPower;
    % Update lagrangian cost
    Cost(t) = currentCost;
    
    % Update mu
    mu = min(max(mu + (1/t)*(currentBufferCost - delayConstraint),0),mu_max);
    Mu(t) = mu;
    
    % Update the state
    currentState = NextState;
    CurrentindBuffer = NextindBuffer;
    CurrentindChannel = NextindChannel;
    CurrentindCard = NextindCard; 
end
%fprintf('Conventional Q learning .......... %d s\n',toc);

end

