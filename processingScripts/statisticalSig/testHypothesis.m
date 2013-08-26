function [boolResultMetA, boolResultMetF] = testHypothesis(actualMetA,samplesMetA,actualMetB,samplesMetB)
    sigThresh = 0.05;
    compAbsSamples = abs(samplesMetA - samplesMetB);
    compAbs = abs(actualMetA - actualMetB);
    
    metAP = sum(compAbsSamples(:,1)>compAbs(1))/size(compAbsSamples,1);
    metFP = sum(compAbsSamples(:,2)>compAbs(2))/size(compAbsSamples,2);
    
    boolResultMetA = metAP <= sigThresh;
    boolResultMetF = metFP <= sigThresh;    
end