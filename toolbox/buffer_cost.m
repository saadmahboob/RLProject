function [cost, holding_cost, overflow_cost] = buffer_cost(bufferStates,cardStates,BEPActions,cardActions,throughputActions, dynamics_l, dynamics_f, eta, B)
% Returns the matrix of buffer cost
% Inputs
%   bufferStates:               possible states of the buffer
%   cardStates:                 possible states of the wireless card
%                                       [on, off]
%   BEPActions:               	possible values for BEP
%   cardActions:                dynamic power management actions
%                                       [s_on, s_off]
%   throughputActions:          possible values for the throughput
%   dynamics_l:                 matrix of transition of the arrivals
%   dynamics_f:                 matrix of transition of the goodputs
%   eta:                        learning parameter
%   B:                          maximum capacity of the buffer
% Outputs
%   cost:                       buffer cost matrix

tic;
cost = zeros(length(bufferStates),length(cardStates),length(BEPActions),length(cardActions),length(throughputActions));
holding_cost = zeros(length(bufferStates),length(cardStates),length(BEPActions),length(cardActions),length(throughputActions));
overflow_cost = zeros(length(bufferStates),length(cardStates),length(BEPActions),length(cardActions),length(throughputActions));

M = length(dynamics_l) - 1;

for i=1:length(bufferStates)
    for j=1:length(cardStates)
        for k=1:length(BEPActions)
            for l=1:length(cardActions)
                for m=1:length(throughputActions)
                    holding_cost(i,j,k,l,m) = 0;
                    overflow_cost(i,j,k,l,m) = 0;
                    cost(i,j,k,l,m) = 0;
                    z = throughputActions(m);
                    for arrival=0:M
                        for f=0:z
                            holding_cost(i,j,k,l,m) = holding_cost(i,j,k,l,m) + dynamics_l(arrival+1) * dynamics_f(f+1,k,m) * (bufferStates(i) - f);
                            overflow_cost(i,j,k,l,m) = overflow_cost(i,j,k,l,m) + dynamics_l(arrival+1) * dynamics_f(f+1,k,m)  * eta * max(bufferStates(i) - f + arrival - B,0);
                            cost(i,j,k,l,m) = cost(i,j,k,l,m) + holding_cost(i,j,k,l,m) + overflow_cost(i,j,k,l,m);
                        end
                    end
                end
            end
        end
    end
end
disp(sprintf('Buffer cost ............ %d s',toc));

end

