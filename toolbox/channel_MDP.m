function [dynamics] = channel_MDP(channelStates)
% Returns the transition matrix of the channels
% Inputs:
%   channelStates:          states of the fadding channels
% Outputs
%   dynamics:               matrix of transition
%                                   [lengthStatesxlenghtStates]
tic;
dynamics = zeros(1,length(channelStates));
dynamics(1:2) = [0.4,0.3];
dynamics = toeplitz(dynamics)';

for i=1:length(channelStates)
    dynamics(:,i) = dynamics(:,i) ./ sum(dynamics(:,i));
end
fprintf('Channel MDP ............ %d s\n',toc);
end

