function actions = IndActions(lengthBEP, lengthCard, lengthz)
% Returns a matrix that stores the index of the action corresponding to the
% tuple (BEP,y,z)
% Inputs
%   lengthBEP:              number of possible values of BEP
%   lengthCard:             number of dynamic power management actions
%   lengthz:          number of possible values for the throughtput
% Outputs
%   actions:                matrix which returns the index of the action
%                           corresponding to the tuple (BEP,y,z)
%                                       [lengthBEPxlengthCardxlengthz]

actions = 1:(lengthBEP*lengthCard*lengthz);
actions = reshape(actions, [lengthBEP, lengthCard, lengthz]);

end

