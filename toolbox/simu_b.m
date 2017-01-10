function nb = simu_b(bufferState,channelState,cardState,BEPAction,cardAction,throughputAction, dynamics_b)
% Returns the new state index of the buffer from the transition matrix
% Inputs
%   bufferState:           	current buffer state index
%   channelState:          	current channel state index
%   cardState:            	current card state index
%   BEPAction:            	current BEP action index
%   cardAction:             current dynamic power management action index
%   throughputAction:       current throughput action index
%   dynamics_b:             matrix of transition of buffer states
%                       [lengthBufferxlengthBufferxlengthCardxlengthBEPxlengthCardActionxlengthz]
% Outputs
%   nb:                     new state index of the buffer

transition = cumsum(dynamics_b(:,bufferState,cardState,BEPAction,cardAction,throughputAction));
r = rand();
for i=1:length(transition)
    if(transition(i) >= r)
        nb = i;
        break;
    end
end

end

