function nl = simu_l(dynamics_l)
% Returns a random number of arriving packets
% Inputs
%   dynamics_l:         matrix of probability of the arrivals
% Outputs
%   nl:                 number of arrivals

transition = cumsum(dynamics_l);
r = rand();
for i=1:length(transition)
    if(transition(i) >= r)
        nl = i-1;
    end
end

end

