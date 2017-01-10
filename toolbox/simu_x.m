function nx = simu_x(cardState,cardAction,dynamics_x)
% Returns the new state index of the card from the transition matrix
% Inputs
%   cardState:          current state index of the card
%   cardAction:         current action index of dynamic power management
%   dynamics_x:         matrix of transition of the card states
%                                       [lengthCardxlengthCardxlengthCardAction]
% Outputs
%   nx:                 new state index of the card

transition = cumsum(dynamics_x(:,cardState,cardAction));
r = rand();
for i=1:length(transition)
    if(transition(i) >= r)
        nx = i;
        break;
    end
end
end

