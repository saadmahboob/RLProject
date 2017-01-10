function Cost = set_cost(BufferCost, RequiredPower,mu)
% Returns the total cost of the state
% Inputs
%   BufferCost:                 cost of the buffer
%   RequiredPower:              required power of the state
%   mu:                         lagrange multiplier
% Outputs
%   Cost:                       total cost of the state

Cost = RequiredPower + mu*BufferCost;
end

