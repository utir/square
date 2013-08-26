function [accuracies meanAccuracy stdAccuracy rawWorkerData] = inferWorkerStats(workerIds,allWorkerQuestions,allWorkerResponses,allGoldQuestions,allGoldResponses)
% inferWorkerStats infers worker statistics from real data
% Inputs:
%   workerIds -
%   allWorkerQuestions -
%   allWorkerResponses -
%   allGoldQuestions -
%   allGoldResponses -
% Outputs:
%   accuracies -
%   meanAccuracy -
%   stdAccuracy -
%   rawWorkerData -
% **************************************
    ids = unique(workerIds);
    accuracies = [];
    rawWorkerData = struct();
    for i = 1:length(ids)
        workerLogical = logical(workerIds == ids(i));
        answeredQuestions = allWorkerQuestions(workerLogical);
        rawWorkerData(i).answeredQuestions = answeredQuestions;
        rawWorkerData(i).answeredLogical = workerLogical;
        answeredResponses = allWorkerResponses(workerLogical);
        uniqueAnswered = unique(answeredQuestions);
        correct = 0;
        all = 0;
        for j=1:length(uniqueAnswered)
            if(ismember(uniqueAnswered(j),allGoldQuestions))
                actualResponseLogical = logical(allGoldQuestions == uniqueAnswered(j));
                actualResponse = allGoldResponses(actualResponseLogical);
                relAnsweredResponseLogical = logical(answeredQuestions == uniqueAnswered(j));
                relAnsweredResponses = answeredResponses(relAnsweredResponseLogical);
                for k = 1:length(relAnsweredResponses)
                    if(relAnsweredResponses(k) == actualResponse)
                        correct = correct+1;
                    end
                    all = all+1;
                end
            end
        end
        accuracies = [accuracies;correct/all];
    end
    meanAccuracy = mean(accuracies);
    zMeanAccuracies = accuracies - meanAccuracy;
    stdAccuracy = sqrt((1/(length(zMeanAccuracies)-1))*(zMeanAccuracies'*zMeanAccuracies));
end