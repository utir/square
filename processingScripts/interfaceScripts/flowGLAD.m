function resultVec = flowGLAD(nFoldDataEval,nFoldDataTune,hasSupervision,hasSemiSupervision)
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
    resultVec = [];
    aggregatedLabels = [];
    aggregatedGold = [];
    for i = 1:length(nFoldDataEval)
        if(length(unique(nFoldDataTune(i).goldResponses))>2)||(length(unique(nFoldDataEval(i).goldResponses))>2)
            return;
        end
        if(hasSupervision)
            P_Z1 = sum(nFoldDataTune(i).goldResponses)/length(nFoldDataTune(i).goldResponses);
            allQuestions = [unique(nFoldDataEval(i).workerQuestions);unique(nFoldDataTune(i).workerQuestions)];
            allQuestions = sort(allQuestions,1,'ascend');
            P_Clamped = ones(length(allQuestions),1).*P_Z1;
            for j=1:length(allQuestions)
                idx = nFoldDataTune(i).goldQuestions == allQuestions(j);
                if(sum(idx) == 0)
                    continue;
                end
                if(nFoldDataTune(i).goldResponses(idx) == 1)
                    P_Clamped(j) = 0.999;
                else
                    P_Clamped(j) = 0.001;
                end
            end
            [ imageStats, labelerStats ] = em([nFoldDataEval(i).workerQuestions;nFoldDataTune(i).workerQuestions],...
                                            [nFoldDataEval(i).workerIds;nFoldDataTune(i).workerIds],...
                                            [nFoldDataEval(i).workerResponses;nFoldDataTune(i).workerResponses],...
                                            P_Clamped, ones(length(unique([nFoldDataEval(i).workerIds;nFoldDataTune(i).workerIds])), 1),...
                                            ones(nFoldDataEval(i).numQuestions+nFoldDataTune(i).numQuestions, 1));
        elseif(hasSemiSupervision)
            P_Z1 = sum(nFoldDataTune(i).goldResponses)/length(nFoldDataTune(i).goldResponses);
            [ imageStats, labelerStats ] = em(nFoldDataEval(i).workerQuestions, nFoldDataEval(i).workerIds, nFoldDataEval(i).workerResponses, P_Z1, ones(nFoldDataEval(i).numWorkers, 1), ones(nFoldDataEval(i).numQuestions, 1));
        else
            P_Z1 = 0.5;
            [ imageStats, labelerStats ] = em(nFoldDataEval(i).workerQuestions, nFoldDataEval(i).workerIds, nFoldDataEval(i).workerResponses, P_Z1, ones(nFoldDataEval(i).numWorkers, 1), ones(nFoldDataEval(i).numQuestions, 1));
        end
        toc;
        estResponses = imageStats{2} >= 0.5;
        estQuestions = imageStats{1};
        categories = unique([unique(nFoldDataEval(i).goldResponses);unique(nFoldDataTune(i).goldResponses)]);
        [acc pr re fm categ] = getMetrics(estResponses,estQuestions,nFoldDataEval(i).goldQuestions,nFoldDataEval(i).goldResponses,categories);
        resultVec = [resultVec;acc' pr' re' fm'];
        
        logicalEst = ismember(estQuestions,nFoldDataEval(i).goldQuestions);
        
        aggregatedLabels = [aggregatedLabels;[estQuestions(logicalEst) (estResponses(logicalEst)+1)]];
        aggregatedGold = [aggregatedGold;[nFoldDataEval(i).goldQuestions (nFoldDataEval(i).goldResponses+1)]];
    end
%     write to file
    [path name ext] = fileparts(nFoldDataEval(1).path);
    if(hasSupervision)
        name = 'GLAD_supervised_results.txt';
        aggLName = 'GLAD_supervised_aggregated.txt';
    elseif(hasSemiSupervision)
        name = 'GLAD_semisupervised_results.txt';
        aggLName = 'GLAD_semisupervised_aggregated.txt';
    else
        name = 'GLAD_unsupervised_results.txt';
        aggLName = 'GLAD_unsupervised_aggregated.txt';
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
        fidGold = fopen([path '/results/nFold/aggregated/gold.txt'],'w');
        for i = 1:size(aggregatedLabels,1)
            fprintf(fid,'%s\n',num2str(aggregatedLabels(i,:)));
        end
        for i = 1:size(aggregatedGold,1)
            fprintf(fidGold,'%s\n',num2str(aggregatedGold(i,:)));
        end
        fclose(fid);
        fclose(fidGold);
    end
end