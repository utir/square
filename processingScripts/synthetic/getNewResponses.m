function [workerQuestions workerResponses] = getNewResponses(rawWorkerData, currentAccuracies, allWorkerQuestions, allGoldQuestions, allGoldResponses)
% getNewResponses gets new responses with synthetic worker accuracies
% Inputs:
%   rawWorkerData -
%   currentAccuracies -
%   allWorkerQuestions -
%   allGoldQuestions -
%   allGoldResponses -
% **************************************************

    workerQuestions = allWorkerQuestions;
    categories = unique(allGoldResponses);
    workerResponses = categories(1).*ones(length(allWorkerQuestions),1);
    
    allAccurate = categories(1).*ones(length(allWorkerQuestions),1);
    allWrong = [];
    if(length(categories)>2)
        for i = 1:(length(categories)-1)
            allWrong = [allWrong categories(1).*ones(length(allWorkerQuestions),1)];
        end
    else
        allWrong = categories(1).*ones(length(allWorkerQuestions),1);
    end
    
    for i=1:length(allGoldQuestions)
        tempLogical = allWorkerQuestions == allGoldQuestions(i);
        allAccurate(tempLogical) = allGoldResponses(i);
        wrongCategories = categories(~(allGoldResponses(i)==categories));
%         wrongCategories = categories(wrongCategories);
        selectWrongIdx = randperm(length(wrongCategories));
        for j=1:length(wrongCategories)
            tempWrong = allWrong(:,j);
            tempWrong(tempLogical) = wrongCategories(selectWrongIdx(j));
            allWrong(:,j) = tempWrong;
        end
    end
    
    for i = 1:length(rawWorkerData)
        answeredCount = length(rawWorkerData(i).answeredQuestions);
        correctLogical = logical(getBernoulliSample(currentAccuracies(i),answeredCount));
        answeredCorrectly = rawWorkerData(i).answeredQuestions(correctLogical);
        answeredIncorrectly = rawWorkerData(i).answeredQuestions(~correctLogical);
        
        workerAnsweredAllLogical = rawWorkerData(i).answeredLogical;
        
        correctlyAnsweredLogical = logical(ismember(allWorkerQuestions,answeredCorrectly));
        correctlyAnsweredLogical = and(workerAnsweredAllLogical,correctlyAnsweredLogical);
        incorrectlyAnsweredLogical = logical(ismember(allWorkerQuestions,answeredIncorrectly));
        incorrectlyAnsweredLogical = and(workerAnsweredAllLogical,incorrectlyAnsweredLogical);
        workerResponses(correctlyAnsweredLogical) = allAccurate(correctlyAnsweredLogical);
        wrongIdx = randsample(length(categories)-1,1);
        allWrongVec = allWrong(:,wrongIdx);
        workerResponses(incorrectlyAnsweredLogical) = allWrongVec(incorrectlyAnsweredLogical);
    end
end