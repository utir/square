function flowSQUAREWOGT(loadPath, savePath)
% flowSQUAREWOGT(evalPath)
% Inputs:
%   loadPath -- Path to original data
%   savePath -- Path where data is to be saved
% Example usage:
%   flowSQUAREWOGT('/Users/aashish/dev/mediaEval1Fold2/'...
%               ,'/Users/aashish/dev/mediaEval1Fold2/')
% ********************************************************************************************
    targetPath = '/Users/aashish/dev/java/crwdQA/crowdQA_Algorithms';
    targetClass = 'org.square.qa.analysis.MainWOGT';
    bin = ['java -Xmx2048m -ea -cp '...
        targetPath '/target/lib/jblas-1.2.3.jar:'...
        targetPath '/target/lib/log4j-1.2.14.jar:'...
        targetPath '/target/qa-1.0.jar ' targetClass];
        
    parameters = [' --method All --saveDir ' savePath ' --loadDir ' loadPath];
    system([bin parameters]);
end