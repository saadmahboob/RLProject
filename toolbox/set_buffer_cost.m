function [BufferCost, HoldingCost, OverflowCost] = set_buffer_cost(dynamics_l,dynamics_f,bufferStates,channelStates,cardStates,BEPActions,cardActions,throughputActions,B,eta)
% Returns the matrices of the cost constraints 
% Inputs
%   dynamics_l:                 matrix of transition of the arrivals
%   dynamics_f:                 matrix of transition of the goodput
%   bufferStates:               possible states of the buffer
%   channelStates:              possible states of the channels
%   cardStates:                 possible states of the wireless card
%   BEPActions:                 possible values for BEP
%   cardActions:                possible dynamics power management actions
%   throughputActions:          possible values for the throughput
%   B:                          maximum capacity of the buffer
%   eta:                        learning parameter
%   
% Outputs
%   BufferCost:                 matrix of cost of the buffer
%   HoldingCost:                matrix of holding cost
%   OverflowCost:               matrix of overflow cost

BufferCost = zeros(length(bufferStates),length(channelStates),length(cardStates),length(BEPActions),length(cardActions),length(throughputActions));
HoldingCost = zeros(length(bufferStates),length(channelStates),length(cardStates),length(BEPActions),length(cardActions),length(throughputActions));
OverflowCost = zeros(length(bufferStates),length(channelStates),length(cardStates),length(BEPActions),length(cardActions),length(throughputActions));
M = length(dynamics_l)-1;

% x~=on || y~=on
for i=1:length(bufferStates)
    arrivals = 0:M;
    b = bufferStates(i);
    HoldingCost(i,:,:,:,:,:) = b/B;
    OverflowCost(i,:,:,:,:,:) = eta * sum(dynamics_l'.* max((b+arrivals-B),0))/B;
    BufferCost(i,:,:,:,:,:) = HoldingCost(i,:,:,:,:,:) + OverflowCost(i,:,:,:,:,:);
end

% x=on && y=on
for i=1:length(bufferStates)
    for j=1:length(channelStates)
        for k=1:length(BEPActions)
            for l=1:length(throughputActions)
                b=bufferStates(i);
                h=channelStates(j);
                BEP = BEPActions(k);
                z = throughputActions(l);
                goodput = [0:z]';
                
                HoldingCost(i,j,1,k,1,l) = sum(dynamics_f(goodput+1,k,l).*((max(b-goodput,0))/B));
                OverflowCost(i,j,1,k,1,l) = 0;
                
                for arrival=0:M
                    OverflowCost(i,j,1,k,1,l) = OverflowCost(i,j,1,k,1,l) + dynamics_l(arrival+1)*sum(dynamics_f(goodput+1,k,l).*(max(max(b-goodput,0) + arrival-B,0)/B))*eta;
                end
                
                BufferCost(i,j,1,k,1,l) = HoldingCost(i,j,1,k,1,l) + OverflowCost(i,j,1,k,1,l);
                
            end
        end
    end
end
                
                
                
                
                
                
                
                
                
                

