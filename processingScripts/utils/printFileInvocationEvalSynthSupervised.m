function printFileInvocationEvalSynthSupervised(file)
% printFileInvocationEvalSynthSupervised prints invocation for the SQUARE
% algorithms configured to run supervised on synthetic data
% Inputs:
%   file -
% eg:
% /Users/aashish/dev/java/crwdQA/crowdQA_Algorithms/evalSynthData_supervised_CLA.txt
    fid = fopen(file,'w');
    dataFolders = dir('/Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/Synthetic');
    nFoldLevels = [5;10;20;50;80;90;95];
    boolFirst = true;

    for i = 1:length(dataFolders)
        if(strcmp(dataFolders(i).name(1),'.'))
            continue;
        end
        for j = 1:length(nFoldLevels)
            s1 = '--method All'; 
            s2 = '--estimation supervised'; 
            s3 = ['--saveDir /Users/aashish/dev/java/crwdQA/crowdData/synthNFoldSets/nFoldSet_' num2str(nFoldLevels(j),'%02d') '/' dataFolders(i).name '/'];
            s4 = ['--loadDir /Users/aashish/dev/java/crwdQA/crowdData/synthNFoldSets/nFoldSet_' num2str(nFoldLevels(j),'%02d') '/' dataFolders(i).name '/'];
            printString = [s1 ' ' s2 ' ' s3 ' ' s4];
            if(~boolFirst)
                fprintf(fid,'\n\n');
            end
            boolFirst = false;
            fprintf(fid,'%s',printString);
        end
    end
end