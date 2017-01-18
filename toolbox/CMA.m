function cumulative_average = CMA(vec)
% Computes the cumulative average of a vector
% Inputs
%   vec:                        one dimensional matrix
% Outputs
%   cumulative_average:         cumulative average of the vector

count = 1:length(vec);
vec = cumsum(vec);
cumulative_average = vec(:) ./ count(:);


end

