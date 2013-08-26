function printFileInvocationEvalRealUnSupervised(file)
% printFileInvocationEvalRealUnSupervised prints invocation for the SQUARE
% algorithms configured to run unsupervised on real data
% Inputs:
%   file -
% eg:
% /Users/aashish/dev/java/crwdQA/crowdQA_Algorithms/evalRealData_unsupervised_CLA.txt
% **************************************************************************
    fid = fopen(file,'w');
    dataFolders = {'AdultContent2','BarzanMozafari','HyunCatherines'...
                    'HyunCatherines_Binary','rteStandardized',...
                    'SpamCF','tempStandardized','trec2011Task2',...
                    'WaterBird','wsdStandardized','wsdStandardized_Binary',...
                    'WVSCM'};
    nFoldLevels = [5;10;20;50;80;90;95];
    boolFirst = true;

    for i = 1:length(dataFolders)
        for j = 1:length(nFoldLevels)
            s1 = '--method All'; 
            s2 = '--estimation unsupervised'; 
            s3 = ['--saveDir /Users/aashish/dev/java/crwdQA/crowdData/nFoldSets/nFoldSet_' num2str(nFoldLevels(j),'%02d') '/' dataFolders{i} '/'];
            s4 = ['--loadDir /Users/aashish/dev/java/crwdQA/crowdData/nFoldSets/nFoldSet_' num2str(nFoldLevels(j),'%02d') '/' dataFolders{i} '/'];
            printString = [s1 ' ' s2 ' ' s3 ' ' s4];
            if(~boolFirst)
                fprintf(fid,'\n\n');
            end
            boolFirst = false;
            fprintf(fid,'%s',printString);
        end
    end
end