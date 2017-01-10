function ns = simu_s(dynamics_s,s,a)
% Returns the next state from the transition matrix
% Inputs
%   dynamics_s:                 matrix of transition of the state
%   s:                          current state of the system
%   a:                          current action of the system
% Outputs
%   ns:                         next state of the system

transition = cumsum(dynamics_s(s,a,:));
r = rand();
for i=1:length(transition)
    if(transition(i) >= r)
        ns = i;
        break;
    end
end
end

