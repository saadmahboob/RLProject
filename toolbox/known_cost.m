function ck = known_cost(bufferStates,channelStates,cardStates,BEPActions,cardActions,throughputActions,dynamics_f,mu,rau)
% Returns a matrix of the cost of the known dynamics
% Inputs
%   bufferStates:               states of the buffer
%   channelStates:              states of the channels
%   cardStates:                 states of the wireless card
%                                           [on, off]
%   BEPActions:                 possible values of BEP
%   cardActions:                dynamic power management actions
%                                       [s_on, s_off]
%   throughputActions:          possible values of the throughput
%   dynamics_f:                 matrix of transition of the goodput
%                                        [lengthZ+1xlengthBEPxlengthZ]
%   mu:                         lagrangian multiplier
%   rau:                        required power matrix
% Outputs
%   ck:                         matrix of the known cost
%                                       [lengthBufferxlengthChannelxlengthCardxlengthBEPxlengthCardActionxlengthZ]

ck = zeros(length(bufferStates),length(channelStates),length(cardStates),length(BEPActions),length(cardActions),length(throughputActions));

for i=1:length(bufferStates)
    for j=1:length(channelStates)
        for k=1:length(cardStates)
            for l=1:length(BEPActions)
                for m=1:length(cardActions)
                    for n=1:length(throughputActions)
                        z = throughputActions(n);
                        b = bufferStates(i);
                        ck(i,j,k,l,m,n) = rau(i,j,k,l,m,n);
                        if(cardStates(k) ~=1 || cardActions(m)~= 1) % no throughput
                            ck(i,j,k,l,m,n) = ck(i,j,k,l,m,n) + mu*dynamics_f(1,l,1)*b;
                        else
                            for f=0:z
                                ck(i,j,k,l,m,n) = ck(i,j,k,l,m,n) + mu*dynamics_f(f+1,l,n)*(b-f);
                            end
                        end
                    end
                end
            end
        end
    end
end

NumStates = length(bufferStates)*length(channelStates)*length(cardStates);
NumActions = length(BEPActions)*length(cardActions)*length(throughputActions);
ck = reshape(ck,[NumStates,NumActions]);
                        
end

