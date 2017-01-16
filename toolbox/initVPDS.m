function V_PDS = initVPDS(bufferStates,channelStates,cardStates,B,NumStates,mu,eta,initer,dynamics_x,dynamics_l,dynamics_f,state,action,gamma,ck)
% Initialize the PDS value function

% V is initialized to 0
% Estimation of cu
% We suppose p(l) is deterministic with 5 packets


V_PDS = zeros(1,NumStates);
V = zeros(1,NumStates);
NumActions = length(action(:));

for t=1:initer
    fprintf('init %d \n',t);
    for s=1:NumStates
        [b_tilde,h_tilde,x_tilde] = ind2sub(size(state),s);
        V_PDS(s) = mu*eta*max(b_tilde+5-B,0);
        for s_next=1:NumStates
            [b_next,h_next,x_next] = ind2sub(size(state),s);
            V_PDS(s) = V_PDS(s) + gamma*(h_next == h_tilde)*(bufferStates(b_next) - bufferStates(b_tilde) == 5)*(x_next == x_tilde);
        end
    end
    for s=1:NumStates
        [b,h,x] = ind2sub(size(state),s);
        transition = zeros(1,NumActions);
        for a=1:NumActions
            [BEP,y,z] = ind2sub(size(action),a);
            transition(a) = ck(s,a);
            for s_tilde=1:NumStates
                [b_tilde,h_tilde,x_tilde] = ind2sub(size(state),s_tilde);
                transition(a) = transition(a) + dynamics_x(x_tilde,x,y)*dynamics_f(min(max(bufferStates(b) - bufferStates(b_tilde)+1,1),11),BEP,z)*(h_tilde == h);
            end
        end
        V(s) = min(transition);
    end
end
            
end

