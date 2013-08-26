function acrossNoiseProfiles(resultsDir,metric,datasetColIdx,saveDir)
% acrossNoiseProfiles prints csv across noise profiles for each algorithm
% Inputs:
%   resultsDir - directory containing result files
%   metric - 'accuracy'/'precision'/'recall'/'fmeasure'
%   datasetColIdx - Data Coloumns 
%   saveDir - write directory (csv files will be written)
%   Supervison fixed to 20%
% eg: acrossNoiseProfiles('/Users/aashish/dev/java/crwdQA/crowdData/nFoldSynthResults','accuracy',1:9,'/Users/aashish/dev/java/crwdQA/crowdData/nFoldSynthResults/acrossNoiseProfiles_20');
% ************************************************************

    allFiles = dir(resultsDir);
    
    rowName = {'GAL','DS','NB','ZC','RY','GLAD','GAL','DS','ZC','RY','GLAD','GAL','DS','ZC','RY','GLAD','CUBCAM','MV'};
    rowTypePrint = {'supervised','supervised','supervised','supervised','supervised','supervised','semisupervised','semisupervised','semisupervised','semisupervised','semisupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised'};
    coloumnName = {'Method','Type','55%','60%','65%','70%','75%','80%','85%','90%','95%'};    
    supervisionPct = '20';
    load datasetName;
    
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
                    if(strcmp(type,'ci'))
                        tempMat = load(readFile);
                        relCols = tempMat(:,datasetColIdx);
                        relCols = relCols(2:2:end,:);
                        metricCI = relCols;
                    end
                    if(strcmp(type,'mean'))
                        tempMat = load(readFile);
                        relCols = tempMat(:,datasetColIdx);
                        metricMean = relCols;
                    end
                end
            end
        end
    end
    if(~isdir(saveDir))
        mkdir(saveDir);
    end
    saveFile = [saveDir '/' datasetName{datasetColIdx(1)} '_results.csv'];
    fid = fopen(saveFile,'w');
    printFile(fid,metricMean,[],rowName,rowTypePrint,coloumnName);
end

function printFile(fid,matM,matCI,rowName,rowTypePrint,coloumnName)
    
    zerosIdx = matM == 0;
    matM = matM - repmat(matM(end,:),size(matM,1),1);
    matM(zerosIdx) = 0;
%         header
    boolFirst = true;
    for coloumnHeaders = 1:length(coloumnName)
        if(~boolFirst)
            fprintf(fid,',');
        end
        fprintf(fid,'%s',coloumnName{coloumnHeaders});
        boolFirst = false;
    end
    fprintf(fid,'\n');
%         done header

    for rows = 1:length(rowName)
        rowVals = matM(rows,:);
        fprintf(fid,'%s,%s,',rowName{rows},rowTypePrint{rows});
        printCommaBool = true;
        for val =  1:length(rowVals)
            if(~printCommaBool)
                    fprintf(fid,',');
            end
            fprintf(fid,'%s',num2str(rowVals(val),'%1.2f'));
            printCommaBool = false;
        end
        fprintf(fid,'\n');
    end
    
%     fprintf(fid,'\n');
%     
%     for rows = 1:length(rowName)
%         rowVals = matCI(rows,:);
%         printCommaBool = true;
%         for val =  1:length(rowVals)
%             if(~printCommaBool)
%                     fprintf(fid,',');
%             end
%             fprintf(fid,'%s',num2str(rowVals(val),'%1.2f'));
%             printCommaBool = false;
%         end
%         fprintf(fid,'\n');
%     end
    fclose(fid);
end