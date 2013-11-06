function aggregatedLabels = flowCUBCAMWOGT(path, workerQuestions, workerIds, workerResponses, numQuestions, numWorkers)
% flowCUBAM creates temporary files required by the CUBAM implementation
% and makes a system call to the algorithm
% Inputs:
%   nFoldDataEval -
% Outputs:
%   aggregatedLabels -
% ***********************************************************************

    binFile = '/Users/aashish/dev/java/crwdQA/3rdParty/cubam/demo/run1dModel.py';
    tempFile = '/Users/aashish/dev/java/crwdQA/crowdData/processingScripts/WVSCMScripts/temp.txt';
    
    tic;
    saveMat = [workerQuestions workerIds workerResponses];
    actualQuestions = saveMat(:,1);
    saveMat = changeToCUBCAMWOG(saveMat);
    saveMat = [[numQuestions numWorkers length(workerResponses)];saveMat];
    fid = fopen(tempFile,'w');
    for j = 1:size(saveMat,1)
        fprintf(fid,'%d %d %d\n',saveMat(j,1),saveMat(j,2),saveMat(j,3));
    end
    fclose(fid);

    currentEvn = getenv('DYLD_LIBRARY_PATH');
    setenv('DYLD_LIBRARY_PATH','');
    system(['python ' binFile ' --evalFile=' tempFile])
    setenv('DYLD_LIBRARY_PATH',currentEvn);
    toc;
    estLabels = load('/Users/aashish/dev/java/crwdQA/crowdData/processingScripts/WVSCMScripts/estLabels.txt');
    estResponses = estLabels(:,2);
    estQuestions = estLabels(:,1);

    estQuestions = estQuestions + 1;
    questions = unique(actualQuestions,'stable');
    actualQuestions = questions(estQuestions);

    aggregatedLabels = [actualQuestions (estResponses+1)]; 
    
    aggLName = 'CUBAM_unsupervised_aggregated.txt';
    if(exist([path '/results/nFold/aggregated'],'dir'))
        fid = fopen([path '/results/nFold/aggregated/' aggLName],'w');
        for i = 1:size(aggregatedLabels,1)
            fprintf(fid,'%s\n',num2str(aggregatedLabels(i,:)));
        end
        fclose(fid);
    end
end