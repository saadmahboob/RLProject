function [dynamics] = card_MDP(cardStates, cardActions)
% Returns the matrix of transition of the wireless card
% Inputs
%   cardStates:         possible states of the wireless card
%                                       [on, off]
%   cardActions:        dynamic power management actions
%                                       [s_on, s_off]
% Outputs
%   dynamics:           matrix of transition of the wireless card
%                                       [cardStatesxcardStatesxcardActions]
tic;
dynamics = zeros(length(cardStates),length(cardStates),length(cardActions));
for i=1:length(cardActions)
    if(cardActions(i) == 1) % switch on
        dynamics(1,1,i) = 1;
        dynamics(1,2,i) = 1;
        dynamics(2,:,i) = 0;
    else
        dynamics(2,1,i) = 1;
        dynamics(2,2,i) = 1;
        dynamics(1,:,i) = 0;
    end
end
fprintf('Card MDP ............... %d s\n',toc);
end

