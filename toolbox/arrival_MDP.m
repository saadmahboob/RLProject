function [dynamics] = arrival_MDP(M, arrivalRate)
% Returns the matrix of probability of number of packets arrival
% Inputs
%   M:                  maximum number of packets arrival
%   arrivalRate:        average number of packets arrival
% Outputs
%   dynamics:           matrix of probability of arrival (Poisson
%                       distribution)
%                                       [Mx1]
tic;
dynamics = zeros(M+1,1);
for l=1:M
    dynamics(l) = (l-1)*log(arrivalRate) - arrivalRate - sum(log(1:(l-1)));
end
dynamics(M+1) = log(1 - sum(exp(dynamics(1:(end-1)))));
dynamics = exp(dynamics);
fprintf('Arrival MDP ............ %d s\n',toc);
if(sum(dynamics) ~= 1)
    fprintf('ERROR in arrival probability: distribution should sum to 1');
else         
    fprintf('Arrival MDP ....... safety check OK \n');
end
end

