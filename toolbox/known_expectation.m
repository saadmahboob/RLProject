function Kexp = known_expectation(state, CardIndState, CardAction, bufferIndState, bufferStates, BEPAction, channelState, throughputIndAction, V_PDS, cardStates, throughputActions, dynamics_x, dynamics_f)
% Returns the expectation sum(pk*V_PDS) over every post decision state for
% an action a
% Inputs
%   state:                      matrix which returns the index of the state
%                               from the indices (bufferState,channelState,cardState)
%   CardIndState:           	current state index of the wireless card
%                                       [on, off]
%   CardAction:                 current dynamic power management action
%                                       [s_on, s_off]
%   bufferIndState:             current state index of the buffer
%   bufferStates:               possible states of the buffer
%   BEPAction:                  current BEP action
%   channelState:               current state of the fadding channel
%   throughputIndAction:           current throughput value
%   V_PDS:                      current post decision state value function
%   CardStates:                 possible states of the wireless card
%   throughputActions:          possible values of the throughput
%   dynamics_x:                 matrix of transition of the wireless card
%   dynamics_l:                 matrix of transition of the arrivals
% Outpus
%   Kexp:                       expectation of the post decision state
%                               value function

Kexp = 0;
z = throughputActions(throughputIndAction);
for i=1:length(cardStates)
    if(CardIndState ~= 1 || CardAction ~= 1) % no throughput z=0 so f=0
        currentState = state(bufferIndState,channelState,i);
        Kexp = Kexp + dynamics_x(i,CardIndState,CardAction)*dynamics_f(1,BEPAction,1)*V_PDS(currentState);
    else
        lim_arrivals = min(z,bufferStates(bufferIndState));% cannot have more goodputs than elements in the buffer
        for f=0:lim_arrivals
            currentBufferIndState = find(bufferStates == (bufferStates(bufferIndState)-f));
            currentState = state(currentBufferIndState,channelState,i);
            Kexp = Kexp + dynamics_x(i,CardIndState,CardAction)*dynamics_f(f+1,BEPAction,throughputIndAction)*V_PDS(currentState);
        end
    end
end

end

