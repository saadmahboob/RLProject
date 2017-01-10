function PLR = BEP2PLR(BEP,L)
% Conversion from Bit Error Probability to Packet Loss Rate
% BEP: Bit Error Probability 
% L: length of the packets
if(length(BEP)==1)
    PLR = 1 - (1 - BEP)^L;
else
    PLR = [];
    for i=1:length(BEP)
        PLR = 1 - (1 - BEP(i))^L;
    end
end
end

