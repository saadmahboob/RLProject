function cu = unknown_cost(bufferStates,channelStates,cardStates,dynamics_l,mu,eta,B)
% Returns the matrix of the unknown cost
% Inputs
%   bufferStates:               states of the buffer
%   channelStates:              states of the fadding channels
%   cardStates:                 states of the wireless card
%                                       [on, off]
%   dynamics_l:                 matrix of transition of the arrivals
%   mu:                         lagrangian multiplier
%   eta:                        learning parameter
%   B:                          maximum capacity of the buffer
% Outputs
%   cu:                         matrix of the unknown cost

cu = zeros(length(bufferStates),length(channelStates),length(cardStates));
M = length(dynamics_l) - 1;

for i=1:length(bufferStates)
    for j=1:length(channelStates)
        for k=1:length(cardStates)
            b = bufferStates(i);
            cu(i,j,k) = 0;
            for arrivals=0:M
                cu(i,j,k) = cu(i,j,k) + mu*eta*dynamics_l(arrivals+1)*max(b+arrivals-B,0);
            end
        end
    end
end

end

