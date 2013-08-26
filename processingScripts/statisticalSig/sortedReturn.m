function sortedRVec = sortedReturn(qrPairVec)
    questions = qrPairVec(:,1);
    [sorted idx] = sort(questions);
    sortedRVec = qrPairVec(:,2);
    sortedRVec = sortedRVec(idx);
end