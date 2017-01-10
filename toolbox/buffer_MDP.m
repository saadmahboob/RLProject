function [dynamics] = buffer_MDP(bufferStates, cardStates, BEPActions, cardActions, throughputActions, B, dynamics_l, dynamics_f)
% Return the transition matrix of the buffer states
% Inputs
%   bufferStates:           states of the buffer
%   cardStates:             states of the wireless card
%                                       [on, off]
%   BEPActions:             possible values of the BEP
%   cardActions:            dynamic power management actions
%                                       [s_on, s_off]
%   throughputActions:      possible throughput values
%   B:                      maximum capacity of the buffer
% Outputs
%   dynamics:               matrix of transition of the buffer states
%                           [bufferStatesxbufferStatesxcardStatesxBEPActionsxcardActionsxthroughputActionsxB]

tic;
check = 1;
M = length(dynamics_l) - 1;% maximum number of packets arrival
dynamics = zeros(length(bufferStates),length(bufferStates),length(cardStates),length(BEPActions),length(cardActions),length(throughputActions));

for j=1:length(bufferStates) % current buffer state
    for k=1:length(BEPActions)
        for l=1:length(throughputActions)
            for i=1:length(bufferStates) % new buffer state
                bp = bufferStates(i); % next state
                z = throughputActions(l);
                BEP = BEPActions(k);
                b = bufferStates(j); % current state
                if(bp < B)
                    f = 0:z;
                    arrivals = bp - max(b-f,0);
                    inds = find(arrivals >= 0 & arrivals <= M);
                    if(isempty(inds))
                        continue;
                    end
                    arrivals = arrivals(inds);
                    f = f(inds);
                    
                    % if x ~= on or y~=s_on, there is no goodput
                    if(bp >= b)
                        dynamics(i,j,2,k,2,l) = dynamics_l(arrivals(1)+1);
                        dynamics(i,j,1,k,2,l) = dynamics_l(arrivals(1)+1);
                        dynamics(i,j,2,k,1,l) = dynamics_l(arrivals(1)+1);
                    end
                    % if x=on and y=s_on
                    dynamics(i,j,1,k,1,l) = sum(dynamics_l(arrivals+1).*dynamics_f(f+1,k,l));
                    
                elseif(bp == B)
                    for f=0:z
                        arrivals =( B-max(b-f,0)):M;
                        inds = find(arrivals >=0 & arrivals <= M);
                        if(isempty(inds))
                            continue;
                        end
                        arrivals = arrivals(inds);
                        
                        % if x ~= on or y~= s_on, there is no goodput
                        if(bp >= b && f==0)
                            dynamics(i,j,2,k,2,l) = dynamics(i,j,2,k,2,l) + sum(dynamics_l(arrivals+1));
                            dynamics(i,j,2,k,1,l) = dynamics(i,j,2,k,1,l) + sum(dynamics_l(arrivals+1));
                            dynamics(i,j,1,k,2,l) = dynamics(i,j,1,k,2,l) + sum(dynamics_l(arrivals+1));
                        end
                        % if x=on and y=s_on
                        dynamics(i,j,1,k,1,l) = dynamics(i,j,1,k,1,l) + sum(dynamics_l(arrivals+1).*dynamics_f(f+1,k,l));
                    end
                end
            end
            
            % safety check: sum to 1
            for x=cardStates
                for y=cardActions
                    if(sum(dynamics(:,j,x,k,y,l)) < 1-1e-2 || sum(dynamics(:,j,x,k,y,l)) > 1+1e-2)
                        error('ERROR: the buffer transition does not sum to 1');
                        check = 0;
                    end
                end
            end
        end
    end
end
if(check == 1)
    fprintf('buffer MDP ........ safety check OK \n');
end
fprintf('Buffer MDP ............. %d s\n',toc);
                            
end

