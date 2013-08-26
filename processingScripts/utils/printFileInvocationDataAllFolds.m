function printFileInvocationDataAllFolds(file)
% printFileInvocationDataAllFolds prints invocation for the SQUARE
% algorithms
% Inputs:
%   file -
% eg:
% printFileInvocationDataAllFolds(/Users/aashish/dev/java/crwdQA/crowdQA_Algorithms/genNFoldRealData_CLA.txt)
% eg:
% printFileInvocationDataAllFolds(/Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes)
% ****************************************************************
    fid = fopen(file,'w');
    dataFolders = {'AdultContent2','BarzanMozafari','HyunCatherines'...
                    'HyunCatherines_Binary','rteStandardized',...
                    'SpamCF','tempStandardized','trec2011Task2',...
                    'WaterBird','wsdStandardized','wsdStandardized_Binary',...
                    'WVSCM'};
    nFoldLevels = [5;10;20;50;80;90;95];
    nFoldParam = [20;10;5;2;-5;-10;-20];
    
    boolFirst = true;

    for i = 1:length(dataFolders)
        for j = 1:length(nFoldLevels)
            s1 = ['--responses /Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/' dataFolders{i} '/responses.txt']; 
            s2 = ['--category /Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/' dataFolders{i} '/categories.txt']; 
            s3 = ['--groundTruth /Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/' dataFolders{i} '/groundTruth.txt']; 
            s4 = '--method All'; 
            s5 = ['--nfold ' num2str(nFoldParam(j))]; 
            s6 = '--estimation unsupervised'; 
            s7 = ['--saveDir /Users/aashish/dev/java/crwdQA/crowdData/nFoldSets/nFoldSet_' num2str(nFoldLevels(j),'%02d') '/' dataFolders{i} '/'];
            printString = [s1 ' ' s2 ' ' s3 ' ' s4 ' ' s5 ' ' s6 ' ' s7];
            if(~boolFirst)
                fprintf(fid,'\n\n');
            end
            boolFirst = false;
            fprintf(fid,'%s',printString);
        end
    end
end