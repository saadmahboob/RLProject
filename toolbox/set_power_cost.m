function [RequiredPower, Ptx] = set_power_cost()
% Returns the required power and transmission power

load parameters
RequiredPower = zeros(length(bufferStates),length(channelStates),length(cardStates),length(BEPActions),length(cardActions),length(throughputActions));
Ptx = zeros(length(channelStates),length(BEPActions),length(throughputActions));

% x=off && y=s_on || x=on && y=s_off
RequiredPower(:,:,:,:,:,:) = Ptr;

% x=off && y=off
RequiredPower(:,:,2,:,2,:) = Poff;

%x=on && y=s_on
for i=1:length(bufferStates)
    for j=1:length(channelStates)
        for k=1:length(BEPActions)
            for l=1:length(throughputActions)
                z = throughputActions(l);
                beta = ceil(z*L*symbolDuration / dT);
                h = channelStates(j);
                BEP = BEPActions(k);
                if(beta==0)
                    Ptx(j,k,l) = 0;
                else
                    Ptx(j,k,l) = (N0*(2.^beta - 1)/(3*h*symbolDuration))*sqrt(2).*erfinv(1 - beta*BEP/4);
                end
                RequiredPower(i,j,1,k,1,l) = Pon + Ptx(j,k,l);
            end
        end
    end
end

end

