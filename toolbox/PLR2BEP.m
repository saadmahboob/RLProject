function BEP = PLR2BEP(PLR,L)
% Conversion from Packet Loss Rate to Bit Error Probability
% PLR: Packet Loss Rate
% L: length of the packet
if(length(PLR)==1)
    BEP = 1 - (1 - PLR)^(1/L);
else
    BEP = [];
    for i=1:length(PLR)
        BEP = [BEP,1 - (1 - PLR(i))^(1/L)];
    end
end
end

