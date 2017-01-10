function nf = simu_f(BEPAction, throughputAction, dynamics_f)
% Returns the new goodput from the transition matrix
% Inputs
%   BEPAction:                  current action index of the BEP
%   throughputAction:           current action index of the throughput
%   dynamics_f:                 matrix of transition of the goodput
% Outputs
%   nf:                         new value of the goodput

transition = cumsum(dynamics_f(:,BEPAction, throughputAction));
r = rand();
for i=1:length(transition)
    if(transition(i) >= r)
        nf = i-1;
        break;
    end
end
end

