% *******************************************
% This script loads and plots statistics data
% Workers per question histogram wpq.tiff
% Questions per worker histogram qpw.tiff
% Worker accuracies histrogram accuracies.tiff
% Requires workerProfiles.mat
% *******************************************

clear all;
close all;
load workerProfiles.mat
stats = loadStatisticsData('/Users/aashish/dev/java/crwdQA/crowdData/nFoldSets/nFoldSet_10');
saveDir = './stats';
if(~isdir(saveDir))
    mkdir(saveDir);
end
figureHandlesAll = [];
% exceptions = {'WaterBird','trec2011'};
for i = 1:length(stats)
    figureHandles = [];
    assert(strcmp(stats(i).name,workerProfiles(i).name));
    thisSaveDir =  [saveDir '/' workerProfiles(i).name];
    if(~isdir(thisSaveDir))
        mkdir(thisSaveDir);
    end
    figure;
    histfit(stats(i).wpqMat(:,2));
    title(workerProfiles(i).name);
    set(gca,'ytick',0:20:1000);
    xlim([0,inf]);
    keyboard;
    saveas(gcf,[thisSaveDir '/wpq.tiff'],'tiffn');
    close all;
%     xlim('auto');
    figureHandles = [figureHandles gca];
    figure;
    histfit(stats(i).qpwMat(:,2));
    title(workerProfiles(i).name);
    set(gca,'ytick',0:20:1000);
    keyboard;
    saveas(gcf,[thisSaveDir '/qpw.tiff'],'tiffn');
    close all;
%     xlim('auto');
    figureHandles = [figureHandles gca];
    figure;
    histfit(workerProfiles(i).accuracies);
    title(workerProfiles(i).name);
    set(gca,'ytick',0:20:1000);
    figureHandles = [figureHandles gca];
    figureHandlesAll = [figureHandlesAll;figureHandles];
    keyboard;
    saveas(gcf,[thisSaveDir '/accuracies.tiff'],'tiffn');
    close all;
end

% totalRows = size(figureHandlesAll,1);
% figure;
% hold on;
% title('Data Statistics');
% for i = 1:totalRows/3
%     s1 = subplot(totalRows,3,i);
%     s2 = subplot(totalRows,3,i+1);
%     s3 = subplot(totalRows,3,i+2);
%     fig1 = get(figureHandlesAll((i-1)*3+3,1),'children');
%     fig2 = get(figureHandlesAll((i-1)*3+3,2),'children');
%     fig3 = get(figureHandlesAll((i-1)*3+3,3),'children');
%     copyobj(fig1,s1);
%     copyobj(fig2,s2);
%     copyobj(fig3,s3);
% end