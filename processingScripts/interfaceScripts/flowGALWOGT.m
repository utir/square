function aggregatedLabelsDS = flowGALWOGT(path, workerIds,workerQuestions,workerResponses)
% flowGAL creates temporary files required by the GetAnotherLabel implementation
% and makes a system call to the algorithm
% Inputs:
%   nFoldDataEval -
%   nFoldDataTune -
%   hasSupervision -
%   hasSemiSupervision -
% Outputs:
%   resultVec -
% ******************************************************************************

    tic;
    bin = 'java -Xmx8000m -ea -cp /Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/args4j-2.0.16.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/commons-beanutils-1.8.3.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/commons-collections-3.2.1.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/commons-lang3-3.1.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/commons-logging-1.1.1.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/commons-math3-3.0.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/hamcrest-core-1.1.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/junit-4.10.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/opencsv-2.3.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/slf4j-api-1.6.6.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/dependency/junit-4.10.jar:/Users/aashish/dev/java/crwdQA/3rdParty/Get-Another-Label/target/get-another-label-2.2.0-SNAPSHOT.jar com.ipeirotis.gal.Main';
    filePathPrefix = '/Users/aashish/dev/java/crwdQA/crowdData/processingScripts/WVSCMScripts';
    resultFile = [filePathPrefix '/results/object-probabilities.txt'];
    
    
    
    writeTempFiles(workerIds,workerQuestions,workerResponses);
    system([bin ' --cost ' filePathPrefix '/cost.txt ' '--input ' filePathPrefix '/responses.txt ' '--categories ' filePathPrefix '/categories.txt']);

    fid = fopen(resultFile);
    inputDataStruct = textscan(fid,'%s%s%s%s%s%s%*[^\n]');
    fclose(fid);

    estQuestions = inputDataStruct{1};
    estResponsesDS = inputDataStruct{3};


    estQuestions(1) = [];
    estResponsesDS(1) = [];


    estQuestions = cellfun(@str2num,estQuestions);
    estResponsesDS = cellfun(@str2num,estResponsesDS);






    aggregatedLabelsDS = [estQuestions (estResponsesDS + 1)]; 
        
    aggLNameDS = 'DS_unsupervised_aggregated.txt';
    toc;
%     write to file
    if(exist([path '/results/nFold/aggregated'],'dir'))
        fidDS = fopen([path '/results/nFold/aggregated/' aggLNameDS],'w');
        for i = 1:size(aggregatedLabelsDS,1)
            fprintf(fidDS,'%s\n',num2str(aggregatedLabelsDS(i,:)));
        end
        fclose(fidDS);
    end
end

function writeTempFiles(evalW,evalQ,evalR)
    fid = fopen('responses.txt','w');
    for i=1:length(evalW)
        fprintf(fid,'%s\t%s\t%s\n',num2str(evalW(i)),num2str(evalQ(i)),num2str(evalR(i)));
    end
    fclose(fid);
    
    categories = unique(evalR);
    fid = fopen('categories.txt','w');
    for i=1:length(categories)
        fprintf(fid,'%s\n',num2str(categories(i)));
    end
    fclose(fid);
    
    fid = fopen('cost.txt','w');
    costMat = perms(categories);
    costMat = costMat(:,1:2);
    costMat = unique(costMat,'rows');
    costs = ones(size(costMat,1),1);
    costMat = [costMat costs];
    addOn = [categories categories];
    addOnCost = zeros(length(categories),1);
    addOn = [addOn addOnCost];
    costMat = [costMat;addOn];
    for i=1:size(costMat,1)
        fprintf(fid,'%s\t%s\t%s\n',num2str(costMat(i,1)),num2str(costMat(i,2)),num2str(costMat(i,3)));
    end
    fclose(fid);
end