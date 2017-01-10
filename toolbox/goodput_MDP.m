function [dynamics] = goodput_MDP(throughputActions, BEPActions, L)
% Return the matrix of dynamics of the goodput distribution
% Inputs:
%   lengthBEP:      number of BEP actions
%   lengthZ:        number of throughput actions
% Outputs
%   dynamics:       matrix of transition of the goodputs
%                                   [max_zxlengthBEPxlengthZ]

tic;
dynamics = zeros(length(throughputActions),length(BEPActions),length(throughputActions));

for i=1:length(throughputActions)
    for j=1:length(BEPActions)
        BEP = BEPActions(j);
        z = throughputActions(i);
        PLR = BEP2PLR(BEP,L);
        
        if(z~=0)
            dynamics(1,j,i) = PLR^z;
        else
            dynamics(1,j,i) = 1;
        end
        
        for k=1:z
            dynamics(k+1,j,i) = nchoosek(z,k) * (1-PLR).^k * (PLR)^(z-k);
        end
    end
end

% safety check: all the columns should sum to 1
check = 1;
issue = [];
for i=1:length(throughputActions)
    for j=1:length(BEPActions)
        if(sum(dynamics(:,j,i)) ~= 1)
            check = 0;
            issue = [issue, i];
        end
    end
end
if(check == 0)
    fprintf('ERROR in goodput probability, all columns do not sum to 1 (z=%d)\n',issue);
else       
    fprintf('Goodput MDP ....... safety check OK \n');
end
fprintf('Goodput MDP ............ %d s\n',toc);
  
end

