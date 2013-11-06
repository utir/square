function aggregatedLabels = flowGLADWOGT(path, workerQuestions, workerIds, workerResponses, numWorkers, numQuestions)
% flowGLAD creates temporary files required by the GLAD implementation
% and makes a system call to the algorithm
% Inputs:
%   nFoldDataEval -
%   nFoldDataTune -
%   hasSupervision -
%   hasSemiSupervision -
% Outputs:
%   resultVec -
% ***********************************************************************

    tic;
    P_Z1 = 0.5;
%     [ imageStats, labelerStats ] = em(workerQuestions, workerIds, workerResponses, P_Z1, ones(numWorkers, 1), ones(numQuestions, 1));
    [ imageStats, labelerStats ] = em(workerQuestions, workerIds, workerResponses, P_Z1);
        
    toc;
    estResponses = imageStats{2} >= 0.5;
    estQuestions = imageStats{1};


    aggregatedLabels = [estQuestions (estResponses+1)];
    aggLName = 'GLAD_unsupervised_aggregated.txt';
%     write to file
    
    if(exist([path '/results/nFold/aggregated'],'dir'))
        fid = fopen([path '/results/nFold/aggregated/' aggLName],'w');
        for i = 1:size(aggregatedLabels,1)
            fprintf(fid,'%s\n',num2str(aggregatedLabels(i,:)));
        end
        fclose(fid);
    end
end