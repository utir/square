function printAggregatedFiles(method, evalPath)
    mapQI = [evalPath '/model/map_question_integer.txt'];
    mapCI = [evalPath '/model/map_category_integer.txt'];
    system(['java -Xmx2048m -ea printMappedFiles'...
        ' ' evalPath '/results/nFold/aggregated/' method '_unsupervised_aggregated.txt'...
        ' ' mapQI ' ' mapCI...
        ' ' evalPath '/results/nFold/aggregated/temp.txt']);
    system(['rm ' evalPath '/results/nFold/aggregated/' method '_unsupervised_aggregated.txt']);
    system(['mv ' evalPath '/results/nFold/aggregated/temp.txt' ' ' evalPath '/results/nFold/aggregated/' method '_unsupervised_aggregated.txt']);
end