function getNoiseOverallResults(resultsDir,metric)
% getNoiseOverallResults extracts results from results stored in csv files for noise
% configurations
% Inputs:
%   resultsDir - Directory where results are saved
%   metric - desired metric
% Outputs:
%   Generates a metricAll.mat 
% **********************************************************************

    allFiles = dir(resultsDir);
    
    rowName = {'GAL','DS','NB','ZC','RY','GLAD','GAL','DS','ZC','RY','GLAD','GAL','DS','ZC','RY','GLAD','CUBCAM','MV'};
    rowTypePrint = {'supervised','supervised','supervised','supervised','supervised','supervised','semisupervised','semisupervised','semisupervised','semisupervised','semisupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised'};
    coloumnName = {'Method','Type','55%','60%','65%','70%','75%','80%','85%','90%','95%'};    
    supervisionPct = '80';
    load datasetName;
    load rejectIdx.mat;
    metricAll = [];
    
    for i = 1:length(allFiles)
        if(allFiles(i).name(1) == '.')
            continue;
        end
        [path name ext] = fileparts(allFiles(i).name);
        readFile = [resultsDir '/' allFiles(i).name];
        
        if(strcmp(ext,'.csv'))
            partsIdx = strfind(name,'_');
            if(strcmp(name(partsIdx(end)+1:end),'matlab'))
                superPercent = name(partsIdx(1)+1:partsIdx(2)-1);
                type = name(partsIdx(2)+1:partsIdx(3)-1);
                fileMetric = name(partsIdx(3)+1:partsIdx(4)-1);
                if(~strcmp(superPercent,supervisionPct))
                    continue;
                end
                if(strcmp(fileMetric,metric))
                    if(strcmp(type,'mean'))
                        tempMat = load(readFile);
                        startIdx = 1:9:100;
                        for j = 0:8
                            tempIdx = startIdx+j;
                            tempIdx(ismember(tempIdx,rejectIdx)) = [];
                            relCols = tempMat(:,tempIdx);
                            metricAll = [metricAll mean(relCols,2)];
                        end
                    end
                end
            end
        end
    end
    clearvars -except metricAll;
    save metricAll.mat
end
