function resultVec = flowCUBCAM(nFoldDataEval,nFoldDataTune,hasSupervision)
% flowCUBAM creates temporary files required by the CUBAM implementation
% and makes a system call to the algorithm
% Inputs:
%   nFoldDataEval -
%   nFoldDataTune -
%   hasSupervision -
% Outputs:
%   resultVec -
% ***********************************************************************
    tic;
    resultVec = []; 
    aggregatedLabels = [];
    binFile = '/Users/aashish/dev/java/crwdQA/3rdParty/cubam/demo/run1dModel.py';
    tempFile = '/Users/aashish/dev/java/crwdQA/crowdData/processingScripts/WVSCMScripts/temp.txt';
    for i = 1:length(nFoldDataEval)
        tic;
        if(length(unique(nFoldDataTune(i).goldResponses))>2)||(length(unique(nFoldDataEval(i).goldResponses))>2)
            return;
        end
        saveMat = [];
        goldMat = [];
        if(hasSupervision)            
        else
            saveMat = [saveMat;[nFoldDataEval(i).workerQuestions nFoldDataEval(i).workerIds nFoldDataEval(i).workerResponses]];
            goldMat = [goldMat;[nFoldDataEval(i).goldQuestions nFoldDataEval(i).goldResponses]];
            actualQuestions = saveMat(:,1);
            [saveMat goldMat] = changeToCUBCAM(saveMat,goldMat);
            saveMat = [[nFoldDataEval(i).numQuestions nFoldDataEval(i).numWorkers length(nFoldDataEval(i).workerResponses)];saveMat];
            fid = fopen(tempFile,'w');
            for j = 1:size(saveMat,1)
                fprintf(fid,'%d %d %d\n',saveMat(j,1),saveMat(j,2),saveMat(j,3));
            end
            fclose(fid);
%             hack
            currentEvn = getenv('DYLD_LIBRARY_PATH');
            setenv('DYLD_LIBRARY_PATH','');
            system(['python ' binFile ' --evalFile=' tempFile])
            setenv('DYLD_LIBRARY_PATH',currentEvn);
        end
        toc;
        estLabels = load('/Users/aashish/dev/java/crwdQA/crowdData/processingScripts/WVSCMScripts/estLabels.txt');
        estResponses = estLabels(:,2);
        estQuestions = estLabels(:,1);
        goldQuestions = goldMat(:,1);
        goldResponses = goldMat(:,2);
        categories = unique([unique(nFoldDataEval(i).goldResponses);unique(nFoldDataTune(i).goldResponses)]);
        [acc pr re fm categ] = getMetrics(estResponses,estQuestions,goldQuestions,goldResponses,categories);
        resultVec = [resultVec;acc' pr' re' fm'];
        
        logicalEst = ismember(estQuestions,goldQuestions);
        estQuestions = estQuestions(logicalEst);
        estResponses = estResponses(logicalEst);
        
        estQuestions = estQuestions + 1;
        questions = unique(actualQuestions,'stable');
        actualQuestions = questions(estQuestions);
       
        aggregatedLabels = [aggregatedLabels;[actualQuestions (estResponses+1)]]; 
    end
%     write to file
    [path name ext] = fileparts(nFoldDataEval(1).path);
    if(hasSupervision)
        name = 'CUBCAM_semisupervised_results.txt';
    else
        name = 'CUBCAM_unsupervised_results.txt';
        aggLName = 'CUBCAM_unsupervised_aggregated.txt';
    end
    fid = fopen([path '/results/nFold/' name],'w');
    fprintf(fid,'%s\n','%Accuracy Precision Recall Fmeasure');
    fprintf(fid,'%s\n',['% ' num2str(categ'+1)]);
    for i = 1:size(resultVec,1)
        fprintf(fid,'%s\n',num2str(resultVec(i,:)));
    end
    fclose(fid);
    if(exist([path '/results/nFold/aggregated'],'dir'))
        fid = fopen([path '/results/nFold/aggregated/' aggLName],'w');
        for i = 1:size(aggregatedLabels,1)
            fprintf(fid,'%s\n',num2str(aggregatedLabels(i,:)));
        end
        fclose(fid);
    end
end