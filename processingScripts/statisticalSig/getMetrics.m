function [accuracy fmeasure] = getMetrics(labels,gt,categories)
% getMetrics computes metrics 
% Inputs:
%   labels - 
%   gt - 
%   categories -
% Outputs:
%   accuracy - 
%   fmeasure -
% ***************************
    accuracy = [];
    fmeasure = [];
   
    for i = 1:length(categories)
        thisGtL = gt == categories(i);
        allThisCateg = sum(thisGtL);
        
        thisPL = labels == categories(i);
        
        thisCategPredCorr = sum(thisPL.*thisGtL);
        thisCategPredWrong = sum(thisPL.*(~thisGtL));
               
        thisRecall = thisCategPredCorr/allThisCateg;
        thisPrecision = thisCategPredCorr/(thisCategPredCorr+thisCategPredWrong);
        if(isnan(thisRecall))
            thisRecall = 1;
        end
        if(isnan(thisPrecision))
            thisPrecision = 1;
        end
        if(isinf(thisRecall))
            thisRecall = 0;
        end
        if(isinf(thisPrecision))
            thisPrecision = 0;
        end
        thisFMeasure = (2.*thisRecall*thisPrecision)/(thisRecall+thisPrecision);
        thisAccuracy = sum(labels==gt)/length(gt);
        if(isnan(thisAccuracy))
            thisAccuracy = 1;
        end
        if(isinf(thisAccuracy))
            thisAccuracy = 0;
        end
        accuracy = [accuracy;thisAccuracy];
        fmeasure = [fmeasure;thisFMeasure];
    end
    accuracy = mean(accuracy);
    fmeasure = mean(fmeasure);
end