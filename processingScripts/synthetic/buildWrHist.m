function [wt bins steps] = buildWrHist(qpwMat,stepSize,numQuestions)
% buildWrHist builds questions per worker histogram (normalized)
% Inputs:
%   qpwMat -
%   stepSize -
%   numQuestions -
% Outputs:
%   wt -
%   bins -
%   steps -
% *************************************************
    relVec = qpwMat(:,2);
    steps = stepSize:stepSize:numQuestions;
    [wt bins] = hist(relVec,steps);
    wt = wt/sum(wt);
end