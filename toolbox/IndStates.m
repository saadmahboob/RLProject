function states = IndStates(lengthBuffer, lengthChannel, lengthCard)
% Return a matrix that stores the index of the state corresponding
% to the tuple (b,h,x)
% Inputs
%   lengthBuffer:       number of buffer states
%   lengthChannel:      number of channel states
%   lengthCard:         number of card states
% Outputs
%   states:             matrix which returns the index of the state
%                       corresponding to the tuple (b,h,x)
%                                     (lengthBuffer x lengthChannel x lengthCard)

states = 1:(lengthBuffer*lengthChannel*lengthCard);
states = reshape(states,[lengthBuffer, lengthChannel, lengthCard]);

end

