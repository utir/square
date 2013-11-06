function generateSQUAREData(loadPath, savePath)
% generateData(loadPath, savePath)
% This function generates data acceptable by the algorithms of the benchmark 
% Paramters can be tuned to generate data with different train and test
% splits. 
% Inputs:
%   loadPath -- Path to original data
%   savePath -- Path where data is to be saved
% Example usage:
%   generateData('/Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/mediaEval1Q1'...
%               ,'/Users/aashish/dev/java/nFoldSets/nFoldSet_10/mediaEval1Q1/')
% ********************************************************************************************
    targetPath = '/Users/aashish/dev/java/crwdQA/crowdQA_Algorithms';
    targetClass = 'org.square.qa.analysis.Main';
    bin = ['java -Xmx2048m -ea -cp '...
        targetPath '/target/lib/jblas-1.2.3.jar:'...
        targetPath '/target/lib/log4j-1.2.14.jar:'...
        targetPath '/target/qa-1.0.jar ' targetClass];
        
    parameters = [' --responses ' loadPath '/responses.txt'...
                ' --category ' loadPath '/categories.txt'...
                ' --groundTruth ' loadPath '/groundTruth.txt'...
                ' --method All'... %Use all consensus methods
                ' --nfold 10'... %10 Fold Cross Validation
                ' --estimation unsupervised'... %Unsupervised estimation
                ' --saveDir ' savePath];
    tic;
    system([bin parameters]);
    toc;
    
end