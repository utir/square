function printAllResults(nfoldDir)
% printAllResults calls third-party algorithms on the n-fold data
% inputs:
%   nfoldDir - /Users/aashish/dev/java/crwdQA/crowdData/nFoldSets
% ***************************************************************
directories = dir(nfoldDir);

for j = 1:length(directories)
    if(directories(j).name(1) == '.')
        continue;
    end
%     if(~(strcmp(directories(j).name,'nFoldSet_95')))
%         continue;
%     end
    allData = loadNFold([nfoldDir '/' directories(j).name],{'mediaEval1Q1','mediaEval1Q2'});
    for i = 1:length(allData)
        idx = strfind(allData(i).both(1).path,'/');
        flowSQUARE(allData(i).both(1).path(1:idx(end)),allData(i).both(1).path(1:idx(end)));
        
        flowGAL(allData(i).eval,allData(i).tune,true,false);
        flowGAL(allData(i).eval,allData(i).tune,false,true);
        flowGAL(allData(i).eval,allData(i).tune,false,false);
        
        flowGLAD(allData(i).eval,allData(i).tune,true,false);
        flowGLAD(allData(i).eval,allData(i).tune,false,true);
        flowGLAD(allData(i).eval,allData(i).tune,false,false);
        
        flowCUBCAM(allData(i).eval,allData(i).tune,false);
    end
end