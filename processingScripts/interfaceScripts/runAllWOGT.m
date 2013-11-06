clear all;
close all;
evalPath = '/Users/aashish/dev/java/crwdQA/crowdData/mediaEval1Fold2';

responses = load([evalPath '/' 'responses_eval.txt']);
workerIds = responses(:,2);
workerQuestions = responses(:,1);
workerResponses = responses(:,3) - 1;
numWorkers = length(unique(workerIds));
numQuestions = length(unique(workerQuestions));
disp(['Number of workers: ' num2str(numWorkers)]);
disp(['Number of questions: ' num2str(numQuestions)]);
disp(['Number of responses: ' num2str(length(workerResponses))]);


flowSQUAREWOGT(evalPath,evalPath);
flowGALWOGT(evalPath, workerIds, workerQuestions, workerResponses);
flowCUBCAMWOGT(evalPath, workerQuestions, workerIds, workerResponses, numQuestions, numWorkers);
flowGLADWOGT(evalPath, workerQuestions, workerIds, workerResponses, numQuestions, numWorkers);

% Print aggregated labels to reflect original questions
printAggregatedFiles('CUBAM',evalPath);
printAggregatedFiles('GLAD',evalPath);
printAggregatedFiles('DS',evalPath);
printAggregatedFiles('Majority',evalPath);
printAggregatedFiles('Raykar',evalPath);
printAggregatedFiles('Zen',evalPath);



