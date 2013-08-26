clear all;

load allFA.mat

reorder = [18,4,6,3,2,5,9,11,8,10,14,16,13,15,17,12,7,1];
allAccuracy = allAccuracy(reorder,:);
allFMeasure = allFMeasure(reorder,:);

for i = 1:(length(reorder)-3)
    disp([ ' & ' num2str(allAccuracy(i,1),'%1.3f') ' & ' num2str(allFMeasure(i,1),'%1.3f') ' & '...
        num2str(allAccuracy(i,2),'%1.3f') ' & ' num2str(allFMeasure(i,2),'%1.3f') ' & '...
        num2str(allAccuracy(i,3),'%1.3f') ' & ' num2str(allFMeasure(i,3),'%1.3f') ' & '...
        num2str(allAccuracy(i,4),'%1.3f') ' & ' num2str(allFMeasure(i,4),'%1.3f') ' & '...
        num2str(allAccuracy(i,5),'%1.3f') ' & ' num2str(allFMeasure(i,5),'%1.3f')]);
end