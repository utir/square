datasetName = {'AdultContent2','BarzanMozafari','HyunCatherines','HyunCatherines_Binary','SpamCF','WVSCM','WaterBird','rteStandardized','tempStandardized','trec2011Task2','wsdStandardized','wsdStandardized_Binary'};

add = 55:5:95;
colIdx = 1;
for i = 1:length(datasetName)
    for j = 1:length(add)
        newDatasetNames{colIdx} = [datasetName{i} '_' num2str(add(j),'%03d')];
        colIdx = colIdx+1;
    end
end