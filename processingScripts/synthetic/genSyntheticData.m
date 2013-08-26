% **********************************
% Script to generate synthethic data
% **********************************

clear all;
close all;
nFoldDir = '/Users/aashish/dev/java/crwdQA/crowdData/nFoldSets/nFoldSet_05';
saveDir = '/Users/aashish/dev/java/crwdQA/crowdData/adaptedData/bayes/Synthetic';
nFoldSets = loadNFold(nFoldDir);
noiseProfiles = 0.55:0.05:0.95;
noiseProfileNames = 55:5:95;
workerProfiles = struct();
for i = 1:length(nFoldSets)
    allWorkerQuestions = nFoldSets(i).both(1).workerQuestions; 
    allWorkerResponses = nFoldSets(i).both(1).workerResponses;
    allGoldQuestions = [nFoldSets(i).tune(1).goldQuestions;nFoldSets(i).eval(1).goldQuestions];
    allGoldResponses = [nFoldSets(i).tune(1).goldResponses;nFoldSets(i).eval(1).goldResponses];
    workerIds = [nFoldSets(i).tune(1).workerIds;nFoldSets(i).eval(1).workerIds];
    ids = unique(workerIds);
    
    [accuracies meanAccuracy stdAccuracy rawWorkerData] = inferWorkerStats(workerIds,allWorkerQuestions,allWorkerResponses,allGoldQuestions,allGoldResponses);
    workerProfiles(i).name = nFoldSets(i).name;
    workerProfiles(i).meanAccuracy = meanAccuracy;
    workerProfiles(i).stdAccuracy = stdAccuracy;
    workerProfiles(i).accuracies = accuracies;
    workerProfiles(i).ids = ids;
    workerProfiles(i).rawWorkerData = rawWorkerData;
    categories = unique(allGoldResponses);
    for j = 1:length(noiseProfiles)
        dirname = [saveDir '/' nFoldSets(i).name '_' num2str(noiseProfileNames(j),'%03d')]; 
        if(~isdir(dirname))
            mkdir(dirname);
        end
        currentAccuracies = normrnd(noiseProfiles(j),stdAccuracy,length(ids),1);
        currentAccuracies(currentAccuracies>=1) = 0.99;
        currentAccuracies(currentAccuracies<=0) = 0.01;
        [newWorkerQuestions newWorkerResponses] = getNewResponses(rawWorkerData, currentAccuracies, allWorkerQuestions, allGoldQuestions, allGoldResponses);
        
        fid = fopen([dirname '/responses.txt'],'w');
        first = true;
        for k = 1:length(newWorkerQuestions)
            if(~first)
                fprintf(fid,'\n');
            end
            fprintf(fid,'%d %d %d',workerIds(k),newWorkerQuestions(k),newWorkerResponses(k));
            first = false;
        end
        fclose(fid);
        first = true;
        fid = fopen([dirname '/groundtruth.txt'],'w');
        for k = 1:length(allGoldQuestions)
            if(~first)
                fprintf(fid,'\n');
            end
            fprintf(fid,'%d %d',allGoldQuestions(k),allGoldResponses(k));
            first=false;
        end
        fclose(fid);
        first = true;
        fid = fopen([dirname '/categories.txt'],'w');
        for k = 1:length(categories)
            if(~first)
                fprintf(fid,'\n');
            end
            fprintf(fid,'%d',categories(k));
            first = false;
        end
        fclose(fid);
    end
end
save workerProfiles.mat workerProfiles
