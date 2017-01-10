function [cost] = required_power(channelStates, cardStates, BEPActions, cardActions, throughputActions,Pon,Poff,Ptr,Ptx)
% Return the required power matrix depending on state and action
% Inputs
%   channelStates:              possible states of the channel
%   cardStates:                 states of the wireless card
%                                       [on, off]
%   BEPActions:                 possible BEP
%   cardActions:                dynamic power management actions
%                                       [s_on, s_off]
%   throughputActions:          possible values for throughput
% Outputs
%   cost:                       matrix of required power
%                                       [lengthChannelxlenghtCardStatesxlengthBEPxlengthcardActionsxlengthZ]

tic;
cost = zeros(length(channelStates),length(cardStates),length(BEPActions),length(cardActions),length(throughputActions));

for i=1:length(channelStates)
    for j=1:length(cardStates)
        for k=1:length(BEPActions)
            for l=1:length(cardActions)
                for m=1:length(throughputActions)
                    if(cardStates(j) == 1 && cardActions(l) == 1) % [on, s_on]
                        cost(i,j,k,l,m) = Pon + Ptx(i,k,m);
                    elseif(cardStates(j) == 2 && cardActions(l) == 2) % [off, s_off]
                        cost(i,j,k,l,m) = Poff;
                    else
                        cost(i,j,k,l,m) = Ptr;
                    end
                end
            end
        end
    end
end
disp(sprintf('Required power ......... %d s',toc));
end

