clear all;
close all;

numSamples = 10;
categories = 1:2;
nFoldDir = '/Users/aashish/dev/java/crwdQA/crowdData/nFoldSets';

folderNames = {'nFoldSet_50','nFoldSet_80','nFoldSet_90'};
datasetNames = {'BarzanMozafari','HyunCatherines_Binary','rteStandardized','SpamCF','tempStandardized','trec2011Task2','WaterBird','WVSCM'};

algorithms = {'Bayes_supervised','DS_supervised','DS_semisupervised',...
    'DS_unsupervised','Majority_unsupervised','Raykar_supervised','Raykar_semisupervised'...
    ,'Raykar_unsupervised','Zen_supervised','Zen_semisupervised','Zen_unsupervised'...
    ,'GLAD_supervised','GLAD_semisupervised','GLAD_unsupervised','CUBCAM_unsupervised'};

relPathToAggredated = 'results/nFold/aggregated';
allPairs = nchoosek(algorithms,2);

metAPairs = zeros(size(allPairs,1));
metFPairs = zeros(size(allPairs,1));

for i = 1:length(folderNames)
    for j = 1:length(datasetNames)
        gold = load([nFoldDir '/' folderNames{i} '/' datasetNames{j} '/' relPathToAggredated '/gold.txt']);
        gold = sortedReturn(gold);
        for k = 1:size(allPairs,1)
            
            metricsA = [];
            metricsB = [];
            
            systemA = load([nFoldDir '/' folderNames{i} '/' datasetNames{j} '/' relPathToAggredated '/' allPairs{k,1} '_aggregated.txt']);
            systemA = sortedReturn(systemA);
           
            systemB = load([nFoldDir '/' folderNames{i} '/' datasetNames{j} '/' relPathToAggredated '/' allPairs{k,2} '_aggregated.txt']);
            systemB = sortedReturn(systemB);
            
            savePath = [nFoldDir '/' folderNames{i} '/' datasetNames{j} '/' relPathToAggredated '/' allPairs{k,1} '_' allPairs{k,2}]; 
            
            if(~exist(savePath,'dir'))
                assert(mkdir(savePath),'Failed to make directory');
                createSamples(systemA,systemB,savePath,numSamples);
            end
            
            [actualAMet actualFMet] = getMetrics(systemA,gold,categories);
            actualMetricsA = [actualAMet actualFMet];
            
            [actualAMet actualFMet] = getMetrics(systemB,gold,categories);
            actualMetricsB = [actualAMet actualFMet];
            
            formatSpec = numel(num2str(numSamples+1));
            
            
            
            for l = 1:numSamples
                systemA = load([savePath '/system_a_' num2str(l,['%.' num2str(formatSpec) 'd']) '.txt']);
                systemB = load([savePath '/system_b_' num2str(l,['%.' num2str(formatSpec) 'd']) '.txt']);
                
                [sampleAMet sampleFMet] = getMetrics(systemA,gold,categories);
                metricsA = [metricsA;[sampleAMet sampleFMet]];
            
                [sampleAMet sampleFMet] = getMetrics(systemB,gold,categories);
                metricsB = [metricsB;[sampleAMet sampleFMet]];
            end
            
            
            [boolResultMetA, boolResultMetF] = testHypothesis(actualMetricsA,metricsA,actualMetricsB,metricsB);
            
            if(boolResultMetA)
                if(actualMetricsA(1)>actualMetricsB(1))
                    disp([allPairs{k,1} '_' allPairs{k,2} ' -- ' allPairs{k,1} ' significantly better -- Accuracy -- ' folderNames{i} ' ' datasetNames{j}]);
                else
                    disp([allPairs{k,1} '_' allPairs{k,2} ' -- ' allPairs{k,2} ' significantly better -- Accuracy -- ' folderNames{i} ' ' datasetNames{j}]);
                end
            else
                disp([allPairs{k,1} '_' allPairs{k,2} ' Null Hypothesis Holds -- Accuracy -- ' folderNames{i} ' ' datasetNames{j}]);
            end
            
            if(boolResultMetF)
                if(actualMetricsA(1)>actualMetricsB(1))
                    disp([allPairs{k,1} '_' allPairs{k,2} ' -- ' allPairs{k,1} ' significantly better -- FMeasure -- ' folderNames{i} ' ' datasetNames{j}]);
                else
                    disp([allPairs{k,1} '_' allPairs{k,2} ' -- ' allPairs{k,2} ' significantly better -- FMeasure -- ' folderNames{i} ' ' datasetNames{j}]);
                end
            else
                disp([allPairs{k,1} '_' allPairs{k,2} ' Null Hypothesis Holds -- FMeasure -- ' folderNames{i} ' ' datasetNames{j}]);
            end
            
            save([savePath '/statSigResults.mat'],'actualMetricsA','actualMetricsB','metricsA','metricsB','boolResultMetA','boolResultMetF');
        end
    end
end


