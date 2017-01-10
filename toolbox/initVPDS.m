function V_PDS = initVPDS(bufferStates,channelStates,cardStates,B,NumStates,mu,eta)
% Initialize the PDS value function

% V is initialized to 0
% Estimation of cu
% We suppose p(l) is deterministic with 5 packets


cu = zeros(length(bufferStates),length(channelStates),length(cardStates));
for i=1:length(bufferStates)
    b=bufferStates(i);
    cu(i,:,:) = mu*eta*max(b+5-B,0);
end
cu = reshape(cu,[NumStates,1]);
V_PDS = cu;

end

