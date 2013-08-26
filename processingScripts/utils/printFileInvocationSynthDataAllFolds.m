function printFileInvocationSynthDataAllFolds(file)
% printFileInvocationSynthDataAllFolds prints invocation for the SQUARE
% algorithms configured to run unsupervised on synthetic data
% Inputs:
%   file -
% eg:
% /Users/aashish/dev/java/crwdQA/crowdQA_Algorithms/genNFoldSynthData_CLA.txt
% /Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/Synthetic
% *********************************************************************
    fid = fopen(file,'w');
    nFoldLevels = [5;10;20;50;80;90;95];
    nFoldParam = [20;10;5;2;-5;-10;-20];
    
    dataFolders = dir('/Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/Synthetic');
    
    boolFirst = true;
    for i = 1:length(dataFolders)
        if(strcmp(dataFolders(i).name(1),'.'))
            continue;
        end
        for j = 1:length(nFoldLevels)
            s1 = ['--responses /Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/Synthetic/' dataFolders(i).name '/responses.txt']; 
            s2 = ['--category /Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/Synthetic/' dataFolders(i).name '/categories.txt']; 
            s3 = ['--groundTruth /Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/Synthetic/' dataFolders(i).name '/groundTruth.txt']; 
            s4 = '--method All'; 
            s5 = ['--nfold ' num2str(nFoldParam(j))]; 
            s6 = '--estimation unsupervised'; 
            s7 = ['--saveDir /Users/aashish/dev/java/crwdQA/crowdData/synthNFoldSets/nFoldSet_' num2str(nFoldLevels(j),'%02d') '/' dataFolders(i).name '/'];
            printString = [s1 ' ' s2 ' ' s3 ' ' s4 ' ' s5 ' ' s6 ' ' s7];
            if(~boolFirst)
                fprintf(fid,'\n\n');
            end
            boolFirst = false;
            fprintf(fid,'%s',printString);
        end
    end
end