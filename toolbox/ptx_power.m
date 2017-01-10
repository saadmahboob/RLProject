function [power] = ptx_power(channelStates,BEPActions,throughputActions,symbolDuration,N0,L,dT)
% Returns a matrix of the minimum power to transmit at beta bits/symbol and
% BEP
% Inputs
%   channelStates:              possible states of the fading channels
%   BEPActions:                 possible values for BEP
%   throughputActions:          possible values for throughput
%   symbolDuration:             seconds/symbol
%   N0:                         noise power spectral density (watts/Hz)

tic;
% Compute the number of bits per symbol to achieve each throughput
beta = zeros(1,length(throughputActions));
for i=1:length(throughputActions)
    beta(i) = ceil(throughputActions(i) * L * symbolDuration / dT);
end

power = zeros(length(channelStates),length(BEPActions),length(throughputActions));
for i=1:length(channelStates)
    for j=1:length(BEPActions)
        for k=1:length(throughputActions)
            for l=1:length(beta)
                if(beta(l) == 0)
                    power(i,j,k,l) = 0;
                else
                    power(i,j,k,l) = (N0*(2.^beta(l) - 1)/(3*channelStates(i)*symbolDuration))*sqrt(2).*erfinv(1 - beta(l)*BEPActions(j)/4);
                end
            end
        end
    end
end
disp(sprintf('Transmission power ..... %d s',toc));

end

