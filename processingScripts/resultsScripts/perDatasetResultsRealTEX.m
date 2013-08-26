function perDatasetResultsRealTEX(resultsDir,metric,datasetColIdx,saveDir)
% perDatasetResultsRealTEX generates latex files with mean performance for 
% the given metric (Real-Data)
% Inputs:
%   resultsDir - Directory where results are located
%   metric - desired metric
%   datasetColIdx - coloumn of desired metric
%   saveDir - Directory to save _results.csv
% eg: perDatasetResultsReal('/Users/aashish/dev/java/crwdQA/crowdData/nFoldRealResults','accuracy',1,'/Users/aashish/dev/java/crwdQA/crowdData/nFoldRealResults/filtered');
% **********************************************************************

    allFiles = dir(resultsDir);
    
    rowName = {'GAL','GAL','GAL','DS','DS','DS','Bayes','Zen','Zen','Zen','Majority','CUBCAM','Raykar','Raykar','Raykar','GLAD','GLAD','GLAD'};
    rowTypePrint = {'Supervised','Semi-Supervised','Unsupervised','Supervised','Semi-Supervised','Unsupervised','Supervised','Supervised','Semi-Supervised','Unsupervised','Unsupervised','Unsupervised','Supervised','Semi-Supervised','Unsupervised','Supervised','Semi-Supervised','Unsupervised'};
    coloumnName = {'Method','Type','5%','10%','20%','50%','80%','90%','95%'};    
    coloumnNameMatch = {'05','10','20','50','80','90','95'};
    datasetName = {'AdultContent2','BarzanMozafari','HyunCatherines','HyunCatherines_Binary','SpamCF','WVSCM','WaterBird','rteStandardized','tempStandardized','trec2011Task2','wsdStandardized','wsdStandardized_Binary'};
    
    metricMean = zeros(length(rowName),length(coloumnNameMatch)); 
    metricCI = zeros(length(rowName),length(coloumnNameMatch));
    
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
                
                if(strcmp(fileMetric,metric))
                    if(strcmp(type,'ci'))
                        tempMat = load(readFile);
                        relCol = tempMat(:,datasetColIdx);
                        relCol = relCol(2:2:end);
                        insertIdx = find(strcmp(coloumnNameMatch,superPercent)==1);
                        metricCI(:,insertIdx) = relCol;
                    end
                    if(strcmp(type,'mean'))
                        tempMat = load(readFile);
                        relCol = tempMat(:,datasetColIdx);
                        insertIdx = find(strcmp(coloumnNameMatch,superPercent)==1);
                        metricMean(:,insertIdx) = relCol;
                    end
                end
            end
        end
    end
    if(~isdir(saveDir))
        mkdir(saveDir);
    end
    saveFile = [saveDir '/' datasetName{datasetColIdx} '_results.csv'];
    fid = fopen(saveFile,'w');
    printFile(fid,metricMean,metricCI,rowName,rowTypePrint,coloumnName);
end

function printFile(fid,matM,matCI,rowName,rowTypePrint,coloumnName)
%         header
    boolFirst = true;
    for coloumnHeaders = 1:length(coloumnName)
        if(~boolFirst)
            fprintf(fid,',');
        end
        fprintf(fid,'%s',coloumnName{coloumnHeaders});
        boolFirst = false;
    end
%         done header

    for rows = 1:length(rowName)
        fprintf(fid,'\n');
        rowVals = matM(rows,:);
        rowValsCI = matCI(rows,:);
        fprintf(fid,'%s,%s,',rowName{rows},rowTypePrint{rows});
        printCommaBool = true;
        for val =  1:length(rowVals)
            if(~printCommaBool)
                    fprintf(fid,',');
            end
            fprintf(fid,'%s %s %s',num2str(rowVals(val),'%1.2f'),setstr(177),num2str(rowValsCI(val),'%1.2f'));
            printCommaBool = false;
        end
    end
    fclose(fid);
end