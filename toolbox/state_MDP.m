function dynamics_s = state_MDP(bufferStates,channelStates,cardStates,BEPActions,cardActions,throughputActions,dynamics_b,dynamics_h,dynamics_x)
% Returns the transition matrix of the states (b,h,x)
% Inputs
%   bufferStates
%   channelStates
%   cardStates
%   BEPActions
%   cardActions
%   throughputActions
% Outputs
%   dynamics_s:                         matrix of transition of the states


NumStates = length(bufferStates)*length(channelStates)*length(cardStates);
NumActions = length(BEPActions)*length(cardActions)*length(throughputActions);
temp_dynamics = zeros(length(bufferStates),length(channelStates),length(cardStates),...
                        length(BEPActions),length(cardActions),length(throughputActions),...
                        length(bufferStates),length(channelStates),length(cardStates));

for i=1:length(bufferStates)
    for k=1:length(cardStates)
        for l=1:length(BEPActions)
            for m=1:length(cardActions)
                for n=1:length(throughputActions)
                    for o=1:length(bufferStates)
                        for p=1:length(cardStates)
                            temp_dynamics(i,:,k,l,m,n,o,:,p) = dynamics_b(o,i,k,l,m,n)*dynamics_x(p,m,k);
                        end
                    end
                end
            end
        end
    end
end

for i=1:length(channelStates)
    for j=1:length(channelStates)
        temp_dynamics(:,i,:,:,:,:,:,j,:) = temp_dynamics(:,i,:,:,:,:,:,j,:)*dynamics_h(j,i);
    end
end

dynamics_s = reshape(temp_dynamics,[NumStates,NumActions,NumStates]);

check = 1;
for i=1:NumStates
    for j=1:NumActions
        if(single(sum(dynamics_s(i,j,:))) == 1)
            continue;
        else
            fprintf('Column does not sum to 1 (%s)',sum(dynamics_s(i,j,:)));
            check=0;
        end
    end
end
if(check==1)
    disp('Safety check state MDP ...... OK');
else
    disp('ERROR in state MDP');
end

end

