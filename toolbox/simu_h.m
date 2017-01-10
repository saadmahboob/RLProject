function nh = simu_h(channelState,dynamics_h)
% Returns the new state index of the channel from the transition matrix
% Inputs
%   channelState:           current state index of the channel
%   dynamics_h:             matrix of transition of the channel states
%                                       [lengthChannelxlengthChannel]
% Outputs
%   nh:                     new state index of the channel

transition = cumsum(dynamics_h(:,channelState));
r = rand();
for i=1:length(transition)
    if(transition(i) >= r)
        nh = i;
        break;
    end
end

end

