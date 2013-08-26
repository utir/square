function stats = loadStatisticsData(nFoldEvalDir)
% loadStatisticsData loads data from nFold Evaluation directory
% Inputs: 
%   nFoldEvalDir -
% Outputs:
%   stats -
% ****************************************************
    stats = struct();
    allDir = dir(nFoldEvalDir);
    statIdx = 1;
    for i=1:length(allDir)
        if(strcmp(allDir(i).name(1),'.'))
            continue;
        end
        if(~isdir([nFoldEvalDir '/' allDir(i).name]))
            continue;
        end
        dirInDir = dir([nFoldEvalDir '/' allDir(i).name]); 
        stats(statIdx).name = allDir(i).name;
        for j=1:length(dirInDir)
            if(~isdir([nFoldEvalDir '/' allDir(i).name '/' dirInDir(j).name]))
                continue;
            end
            if(strcmp(dirInDir(j).name,'statistics'))
                desDir = dir([nFoldEvalDir '/' allDir(i).name '/' dirInDir(j).name]);
                for k=1:length(desDir)
                    if(strcmp(desDir(k).name,'train'))
                        filesInDir = dir([nFoldEvalDir '/' allDir(i).name '/' dirInDir(j).name '/' desDir(k).name]);
                        for l=1:length(filesInDir)
                            if(strcmp(filesInDir(l).name,'question_Statistics.txt'))
                                stats(statIdx).wpqMat = load([nFoldEvalDir '/' allDir(i).name '/' dirInDir(j).name '/' desDir(k).name '/' filesInDir(l).name]);
                            end
                            if(strcmp(filesInDir(l).name,'worker_Statistics.txt'))
                                stats(statIdx).qpwMat = load([nFoldEvalDir '/' allDir(i).name '/' dirInDir(j).name '/' desDir(k).name '/' filesInDir(l).name]);
                            end
                        end
                    end
                end
            end
        end
        statIdx = statIdx + 1;
    end
end