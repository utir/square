function qpw = drawQPWSamples(wt,bins,steps,numSamples)
% drawQPWSamples draws samples from questions per worker distribution
% Inputs:
%   wt -
%   bins -
%   steps -
%   numSamples -
% Outputs:
%   qpw -
% ***************************************************
    qpw = bins(randsample(length(steps),numSamples,true,wt));
end