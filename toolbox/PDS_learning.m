function [V_PDS, V, BufferCost, requiredPower, holding, overflow, Mu, Cost] = PDS_learning(state,action,bufferStates,channelStates,cardStates,BEPActions,cardActions,throughputActions,dynamics_l,dynamics_h,dynamics_x, ck, cu, rau, g, holding_cost, overflow_cost,mu,gamma,delayConstraint,mu_max,niter,initialState,dynamics_f,B,M,eta)
% Performs PDS learning on the MDP
% Inputs
%   state:                  matrix which returns the index of the state
%                           from the indices (bufferState,channelState,cardState)
%   action:                 matrix which returns the index of the action
%                           from the indices (BEPAction,cardAction,throughputAction)
%   bufferStates:           possible states of the buffer
%   channelStates:          possible states of the fading channel
%   cardStates:             possible states of the wireless card
%                                       [on, off]
%   BEPActions:             possible values of BEP
%   cardActions:            possible dynamic power management actions
%                                       [s_on, s_off]
%   throughputActions:      possible values for the throughput
%   dynamics_b:             matrix of transition of the buffer states
%   dynamics_h:             matrix of transition of the channel states
%   dynamics_x:             matrix of transition of the card states
%   ck:                     matrix of the known cost
%   cu:                     matrix of the unknown cost
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
%   niter:                  number of iterations to perform
%   initialState:           initial state (b,h,x) of the system
%   dynamics_f:             matrix of transition of the goodput
%   B:                      maximum capacity of the buffer
% Outputs
%   V_PDS:                  optimized PDS state value function
%   V:                      optimized state value function
%   BufferCost:             sequence of buffer cost
%   RequiredPower:          sequence of required power
%   holding:                sequence of holding cost
%   overflow:               sequence of overflow cost
%   Mu:                     sequence of lagrangian multiplier
%   Cost:                   sequence of cost 
%                                       c(s,a) = rau(s,a) + mu*g(s,a)

disp('Start PDS learning...');
tic;
% Initialization
NumStates = length(bufferStates)*length(channelStates)*length(cardStates);
NumActions = length(BEPActions)*length(cardActions)*length(throughputActions);
V = zeros(1,NumStates);
V_PDS = initVPDS(bufferStates,channelStates,cardStates,B,NumStates,mu,eta);
BufferCost = zeros(1,niter);
requiredPower = zeros(1,niter);
holding = zeros(1,niter);
overflow = zeros(1,niter);
Mu = zeros(1,niter);
Cost = zeros(1,niter);

% Iterations
currentIndBuffer = initialState(1);
currentIndChannel = initialState(2);
currentIndCard = initialState(3);
currentState = state(currentIndBuffer, currentIndChannel, currentIndCard);

for t=1:niter
    % Take greedy action (BEP,y,z)
    ckSum = reshape(ck,[NumStates, NumActions]);
    sum_PDS = zeros(1,NumActions);
    for i=1:length(BEPActions)
        for j=1:length(cardActions)
            for k=1:length(throughputActions)
                ThisAction = action(i,j,k);
                expectV = known_expectation(state, currentIndCard, j, currentIndBuffer, bufferStates, i, currentIndChannel, k, V_PDS, cardStates, throughputActions, dynamics_x, dynamics_f);
                sum_PDS(ThisAction) = ckSum(currentState,ThisAction) + expectV;
            end
        end
    end
    [~,indAction] = min(sum_PDS);
    [indBEP, indCardAction, indZ] = ind2sub(size(action),indAction);
    
    % Observe experience tuple
    currentAction = action(indBEP,indCardAction,indZ); % a_n
    currentState = state(currentIndBuffer,currentIndChannel,currentIndCard); % s_n
    PDSIndCard = simu_x(currentIndCard,indCardAction,dynamics_x); % x_tilde
    PDSGoodput = simu_f(indBEP,indZ,dynamics_f);
    PDSBuffer = max(bufferStates(currentIndBuffer) - PDSGoodput,0);
    PDSIndBuffer = find(bufferStates == PDSBuffer); % b_tilde
    PDSIndChannel = currentIndChannel;
    PDScost = cu(PDSIndBuffer,currentIndChannel,PDSIndCard);
    PDSState = state(PDSIndBuffer,PDSIndChannel,PDSIndCard);
    NextStateIndCard = PDSIndCard; % x_n+1
    NextStateIndChannel = simu_h(currentIndChannel,dynamics_h); % h_n+1
    NextStateArrival = simu_l(dynamics_l);
    NextStateBuffer = min(PDSBuffer + NextStateArrival, B); 
    NextStateIndBuffer = find(bufferStates == NextStateBuffer); % b_n+1
    NextState = state(NextStateIndBuffer, NextStateIndChannel, NextStateIndCard);
    
    % Evaluate the state value function
    ckSum = reshape(ck,[NumStates, NumActions]);
    sum_PDS_next = zeros(1,NumActions);
    for i=1:length(BEPActions)
        for j=1:length(cardActions)
            for k=1:length(throughputActions)
                ThisAction = action(i,j,k);
                expectV = known_expectation(state, NextStateIndCard, j, NextStateIndBuffer, bufferStates, i, NextStateIndChannel, k, V_PDS, cardStates, throughputActions, dynamics_x, dynamics_f);
                sum_PDS_next(ThisAction) = ckSum(NextState,ThisAction) + expectV;
            end
        end
    end
    V(NextState) = min(sum_PDS_next);
    
    % Update the PDS value function
    V_PDS(PDSState) = (1 - (1/(t+1)))*V_PDS(PDSState) + (1/(t+1))*(PDScost + gamma*V(NextState));
    
    % Update costs
    %fprintf('t = %d \n currentIndBuffer %d (%d), currentIndChannel %d (%d), currentIndCard %d (%d), indBEP %d (%d), indCardAction %d (%d), indZ %d (%d) \n',[t,currentIndBuffer,size(g,1),currentIndChannel,size(g,2),currentIndCard,size(g,3),indBEP,size(g,4),indCardAction,size(g,5),indZ, size(g,6)]);
    currentBufferCost = g(currentIndBuffer,currentIndChannel,currentIndCard,indBEP,indCardAction,indZ);
    currentHoldingCost = holding_cost(currentIndBuffer,currentIndChannel,currentIndCard,indBEP,indCardAction,indZ);
    currentOverflowCost = overflow_cost(currentIndBuffer,currentIndChannel,currentIndCard,indBEP,indCardAction,indZ);
    currentRequiredPower = rau(currentIndBuffer,currentIndChannel,currentIndCard,indBEP,indCardAction,indZ);
    currentCost = currentRequiredPower + mu*currentBufferCost;
    BufferCost(t) = currentBufferCost;
    requiredPower(t) = currentRequiredPower;
    overflow(t) = currentOverflowCost;
    holding(t) = currentHoldingCost;
    Cost(t) = currentCost;
    
    % Update the lagrange multiplier
    mu = min(max(mu + (1/t)*(currentBufferCost - delayConstraint),0),mu_max);
    Mu(t) = mu;
    
    % Update the state
    currentIndBuffer = NextStateIndBuffer;
    currentIndChannel = NextStateIndChannel;
    currentIndCard = NextStateIndCard;
end
fprintf('PDS Learning ....... %d s\n',toc);

end

