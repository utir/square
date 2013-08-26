function [accuracy fmeasure] = getMetricsMat(labels,gt,categories)
% getMetrics computes metrics 
% Inputs:
%   labels - 
%   gt - 
%   categories -
% Outputs:
%   accuracy - 
%   fmeasure -
% ***************************
    gt = repmat(gt,1,size(labels,2));
    accuracy = sum((gt == labels),1)./size(gt,1);
    pr = [];
    re = [];
    for i = 1:length(categories)
        thisCategActualL = gt==categories(i);
        thisCategPredictedL = labels==categories(i);
        re = cat(3,re,sum(thisCategActualL.*thisCategPredictedL,1)./sum(thisCategActualL,1));
        pr = cat(3,pr,sum(thisCategActualL.*thisCategPredictedL,1)./(sum(thisCategActualL.*thisCategPredictedL,1)...
            + sum((~thisCategActualL).*thisCategPredictedL,1)));
    end
    re = mean(re,3);
    pr = mean(pr,3);
    fmeasure = (2*(pr.*re))./(re+pr);
end