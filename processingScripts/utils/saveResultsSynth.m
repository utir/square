function saveResultsSynth(saveDir,nFoldEvalDir)
% saveResultsSynth Prints results file to saveDir
% Inputs:
%   saveDir -
%   nFoldEvalDir - 
% '/Users/aashish/dev/java/crwdQA/crowdData/nFoldRealResults','/Users/aashish/dev/java/crwdQA/crowdData/nFoldSets'
% ***********************************************
    multiclassFolders = {'AdultContent2_055','AdultContent2_060','AdultContent2_065','AdultContent2_070','AdultContent2_075','AdultContent2_080','AdultContent2_085'...
        'AdultContent2_090','AdultContent2_095','HyunCatherines_055','HyunCatherines_060','HyunCatherines_065','HyunCatherines_070','HyunCatherines_075'...
        ,'HyunCatherines_080','HyunCatherines_085','HyunCatherines_090','HyunCatherines_095','wsdStandardized_055','wsdStandardized_060','wsdStandardized_065'...
        ,'wsdStandardized_070','wsdStandardized_075','wsdStandardized_080','wsdStandardized_085','wsdStandardized_090','wsdStandardized_095'};
    allDir = dir(nFoldEvalDir);
    numMetrics = 4;
    for i=1:length(allDir)
        if(strcmp(allDir(i).name(1),'.'))
            continue;
        end
        dirInDir = dir([nFoldEvalDir '/' allDir(i).name]);
        rowName = {'GAL','DS','Bayes','Zen','Raykar','GLAD','GAL','DS','Zen','Raykar','GLAD','GAL','DS','Zen','Raykar','GLAD','CUBCAM','Majority'};
        rowType = {'supervised','supervised','supervised','supervised','supervised','supervised','semisupervised','semisupervised','semisupervised','semisupervised','semisupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised'};
        rowTypePrint = {'supervised','supervised','supervised','supervised','supervised','supervised','semisupervised','semisupervised','semisupervised','semisupervised','semisupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised','unsupervised'};
        coloumnName = {'Method','Type'};
        coloumsIdx = 3;
        
        accuracyMat = [];
        accuracyMatCIL = [];
        accuracyMatCIR = [];
        precisionMat = [];
        precisionMatCIL = [];
        precisionMatCIR = [];
        recallMat = [];
        recallMatCIL = [];
        recallMatCIR = [];
        fmeasureMat = [];
        fmeasureMatCIL = [];
        fmeasureMatCIR = [];
        
        for j=1:length(dirInDir)
            if(strcmp(dirInDir(j).name(1),'.'))
                continue;
            end
            resultFiles = dir([nFoldEvalDir '/' allDir(i).name '/' dirInDir(j).name '/' 'results' '/' 'nFold']);
            currentDirPrefix = [nFoldEvalDir '/' allDir(i).name '/' dirInDir(j).name '/' 'results' '/' 'nFold'];    
            
            accuracyVec = zeros(length(rowName),1);
            accuracyVecCIL = zeros(length(rowName),1);
            accuracyVecCIR = zeros(length(rowName),1);
            
            precisionVec = zeros(length(rowName),1);
            precisionVecCIL = zeros(length(rowName),1);
            precisionVecCIR = zeros(length(rowName),1);
            
            recallVec = zeros(length(rowName),1);
            recallVecCIL = zeros(length(rowName),1);
            recallVecCIR = zeros(length(rowName),1);
            
            fmeasureVec = zeros(length(rowName),1);
            fmeasureVecCIL = zeros(length(rowName),1);
            fmeasureVecCIR = zeros(length(rowName),1);
            
            coloumnName{coloumsIdx} = dirInDir(j).name;
            coloumsIdx = coloumsIdx + 1;
            for k = 1:length(resultFiles)
                fileToLoad = [currentDirPrefix '/' resultFiles(k).name];
                [path name ext] = fileparts(resultFiles(k).name);
                if(strcmp(ext,'.txt')==1)
                    idxUS = strfind(name,'_');
                    if(strcmp(name(idxUS(end)+1:end),'results')==1)
                        method = name(1:idxUS(1)-1);
                        type = name(idxUS(1)+1:idxUS(2)-1);
                        if((sum(strcmp(dirInDir(j).name,multiclassFolders))==1)&&((strcmp(method,'Raykar')==1)||(strcmp(method,'CUBCAM')==1)||(strcmp(method,'GLAD')==1)))
                            continue;
                        end
                        methodResults = load(fileToLoad);
                        numClasses = size(methodResults,2)/numMetrics;
                            
                        methodResultsAccuracy  = methodResults(:,1:numClasses);
                        methodResultsMeanAccuracy = mean(methodResultsAccuracy,2);
                        [a b methodAccuracyCI] = normfit(methodResultsMeanAccuracy);
                        methodAccuracyCI(methodAccuracyCI<0) = 0;
                        methodAccuracyCI(methodAccuracyCI>1) = 1;
                        methodResultsMean = mean(methodResults,1);
                        meanAccuracy = mean(methodResultsMean(1:numClasses));
                            
                        methodResultsPrecision  = methodResults(:,(1:numClasses)+numClasses);
                        methodResultsMeanPrecision = mean(methodResultsPrecision,2);
                        [a b methodPrecisionCI] = normfit(methodResultsMeanPrecision);
                        methodPrecisionCI(methodPrecisionCI<0) = 0;
                        methodPrecisionCI(methodPrecisionCI>1) = 1;
                        methodResultsMean = mean(methodResults,1);
                        meanPrecision = mean(methodResultsMean((1:numClasses)+numClasses));

                        methodResultsRecall  = methodResults(:,(1:numClasses)+numClasses*2);
                        methodResultsMeanRecall = mean(methodResultsRecall,2);
                        [a b methodRecallCI] = normfit(methodResultsMeanRecall);
                        methodRecallCI(methodRecallCI<0) = 0;
                        methodRecallCI(methodRecallCI>1) = 1;
                        methodResultsMean = mean(methodResults,1);
                        meanRecall = mean(methodResultsMean((1:numClasses)+numClasses*2));

%                         methodResultsFMeasure  = methodResults(:,(1:numClasses)+numClasses*3);
%                         methodResultsFMeasure = (2.*(methodResultsRecall.*methodResultsPrecision))./(methodResultsRecall+methodResultsPrecision);
                        methodResultsMeanFMeasure = (2.*(methodResultsMeanRecall.*methodResultsMeanPrecision))./(methodResultsMeanRecall+methodResultsMeanPrecision);
                        methodResultsMeanFMeasure(isnan(methodResultsMeanFMeasure)) = 2*meanRecall*meanPrecision/(meanRecall+meanPrecision);
                        [a b methodFMeasureCI] = normfit(methodResultsMeanFMeasure);
                        methodFMeasureCI(methodFMeasureCI<0) = 0;
                        methodFMeasureCI(methodFMeasureCI>1) = 1;
                        methodResultsMean = mean(methodResults,1);
%                         meanFMeasure = mean(methodResultsMean((1:numClasses)+numClasses*3));
                        meanFMeasure = 2*meanRecall*meanPrecision/(meanRecall+meanPrecision);

                        firstLogical = strcmp(method,rowName);
                        secondLogical = strcmp(type,rowType);

                        accuracyVec(and(firstLogical,secondLogical)) = meanAccuracy;
                        accuracyVecCIL(and(firstLogical,secondLogical)) = methodAccuracyCI(1);
                        accuracyVecCIR(and(firstLogical,secondLogical)) = methodAccuracyCI(2);

                        precisionVec(and(firstLogical,secondLogical)) = meanPrecision;
                        precisionVecCIL(and(firstLogical,secondLogical)) = methodPrecisionCI(1);
                        precisionVecCIR(and(firstLogical,secondLogical)) = methodPrecisionCI(2);

                        recallVec(and(firstLogical,secondLogical)) = meanRecall;
                        recallVecCIL(and(firstLogical,secondLogical)) = methodRecallCI(1);
                        recallVecCIR(and(firstLogical,secondLogical)) = methodRecallCI(2);

                        fmeasureVec(and(firstLogical,secondLogical)) = meanFMeasure;
                        fmeasureVecCIL(and(firstLogical,secondLogical)) = methodFMeasureCI(1);
                        fmeasureVecCIR(and(firstLogical,secondLogical)) = methodFMeasureCI(2);
                    end
                end
            end
            accuracyMat = [accuracyMat accuracyVec];
            accuracyMatCIL = [accuracyMatCIL accuracyVecCIL];
            accuracyMatCIR = [accuracyMatCIR accuracyVecCIR];
            
            precisionMat = [precisionMat precisionVec];
            precisionMatCIL = [precisionMatCIL precisionVecCIL];
            precisionMatCIR = [precisionMatCIR precisionVecCIR];
            
            recallMat = [recallMat recallVec];
            recallMatCIL = [recallMatCIL recallVecCIL];
            recallMatCIR = [recallMatCIR recallVecCIR];
            
            fmeasureMat = [fmeasureMat fmeasureVec];
            fmeasureMatCIL = [fmeasureMatCIL fmeasureVecCIL];
            fmeasureMatCIR = [fmeasureMatCIR fmeasureVecCIR];
        end
        
        
        if(~isdir(saveDir))
            mkdir(saveDir);
        end
        
        accuracyMatCIL  = accuracyMatCIL - accuracyMat;
        accuracyMatCIR  = accuracyMatCIR - accuracyMat;
        
        precisionMatCIL  = precisionMatCIL - precisionMat;
        precisionMatCIR  = precisionMatCIR - precisionMat;
        
        recallMatCIL  = recallMatCIL - recallMat;
        recallMatCIR  = recallMatCIR - recallMat;
        
        fmeasureMatCIL  = fmeasureMatCIL - fmeasureMat;
        fmeasureMatCIR  = fmeasureMatCIR - fmeasureMat;
        
        fidAccuracy = fopen([saveDir '/' allDir(i).name '_mean_accuracy_results.csv'],'w');
        printFile(fidAccuracy,accuracyMat,[],rowName,rowTypePrint,coloumnName,false);
        fidAccuracy = fopen([saveDir '/' allDir(i).name '_mean_accuracy_results_matlab.csv'],'w');
        printFile(fidAccuracy,accuracyMat,[],rowName,rowTypePrint,coloumnName,true);
        
%         fidAccuracyCI = fopen([saveDir '/' allDir(i).name '_ci_accuracy_results.csv'],'w');
%         printFile(fidAccuracyCI,accuracyMatCIL,accuracyMatCIR,rowName,rowTypePrint,coloumnName,false);
%         fidAccuracyCI = fopen([saveDir '/' allDir(i).name '_ci_accuracy_results_matlab.csv'],'w');
%         printFile(fidAccuracyCI,accuracyMatCIL,accuracyMatCIR,rowName,rowTypePrint,coloumnName,true);
%         
%         fidPrecision = fopen([saveDir '/' allDir(i).name '_mean_precision_results.csv'],'w');
%         printFile(fidPrecision,precisionMat,[],rowName,rowTypePrint,coloumnName,false);
%         fidPrecision = fopen([saveDir '/' allDir(i).name '_mean_precision_results_matlab.csv'],'w');
%         printFile(fidPrecision,precisionMat,[],rowName,rowTypePrint,coloumnName,true);
%         
%         fidPrecisionCI = fopen([saveDir '/' allDir(i).name '_ci_precision_results.csv'],'w');
%         printFile(fidPrecisionCI,precisionMatCIL,precisionMatCIR,rowName,rowTypePrint,coloumnName,false);
%         fidPrecisionCI = fopen([saveDir '/' allDir(i).name '_ci_precision_results_matlab.csv'],'w');
%         printFile(fidPrecisionCI,precisionMatCIL,precisionMatCIR,rowName,rowTypePrint,coloumnName,true);
%         
%         fidRecall = fopen([saveDir '/' allDir(i).name '_mean_recall_results.csv'],'w');
%         printFile(fidRecall,recallMat,[],rowName,rowTypePrint,coloumnName,false);
%         fidRecall = fopen([saveDir '/' allDir(i).name '_mean_recall_results_matlab.csv'],'w');
%         printFile(fidRecall,recallMat,[],rowName,rowTypePrint,coloumnName,true);
%         
%         fidRecallCI = fopen([saveDir '/' allDir(i).name '_ci_recall_results.csv'],'w');
%         printFile(fidRecallCI,recallMatCIL,recallMatCIR,rowName,rowTypePrint,coloumnName,false);
%         fidRecallCI = fopen([saveDir '/' allDir(i).name '_ci_recall_results_matlab.csv'],'w');
%         printFile(fidRecallCI,recallMatCIL,recallMatCIR,rowName,rowTypePrint,coloumnName,true);
        
        fidFMeasure = fopen([saveDir '/' allDir(i).name '_mean_fmeasure_results.csv'],'w');
        printFile(fidFMeasure,fmeasureMat,[],rowName,rowTypePrint,coloumnName,false);
        fidFMeasure = fopen([saveDir '/' allDir(i).name '_mean_fmeasure_results_matlab.csv'],'w');
        printFile(fidFMeasure,fmeasureMat,[],rowName,rowTypePrint,coloumnName,true);
        
%         fidFMeasureCI = fopen([saveDir '/' allDir(i).name '_ci_fmeasure_results.csv'],'w');
%         printFile(fidFMeasureCI,fmeasureMatCIL,fmeasureMatCIR,rowName,rowTypePrint,coloumnName,false);
%         fidFMeasureCI = fopen([saveDir '/' allDir(i).name '_ci_fmeasure_results_matlab.csv'],'w');
%         printFile(fidFMeasureCI,fmeasureMatCIL,fmeasureMatCIR,rowName,rowTypePrint,coloumnName,true);
        
        
        
    end
end

function printFile(fid,matL,matR,rowName,rowTypePrint,coloumnName,matlabBool)
%         header
    boolFirst = true;
    if(~matlabBool)
        for coloumnHeaders = 1:length(coloumnName)
            if(~boolFirst)
                fprintf(fid,',');
            end
            fprintf(fid,'%s',coloumnName{coloumnHeaders});
            boolFirst = false;
        end
        fprintf(fid,'\n');
    end
    
%         done header
    for rows = 1:length(rowName)
        if(isempty(matR))
            rowVals = matL(rows,:);
            if(~matlabBool)
                fprintf(fid,'%s,%s,',rowName{rows},rowTypePrint{rows});
            end
            
            printCommaBool = true;
            for val =  1:length(rowVals)
                if(~printCommaBool)
                        fprintf(fid,',');
                end
                fprintf(fid,'%s',num2str(rowVals(val),'%1.2f'));
                printCommaBool = false;
            end
            fprintf(fid,'\n');
        else
            rowValsCIL = matL(rows,:);
            rowValsCIR = matR(rows,:);
            rowValsMat = [rowValsCIL;rowValsCIR];
            for i=1:size(rowValsMat,1)
                rowVals = rowValsMat(i,:);
                if(~matlabBool)
                    fprintf(fid,'%s,%s,',rowName{rows},rowTypePrint{rows});
                end
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
        end
    end
    fclose(fid);
end