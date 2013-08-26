function [systemASamples systemBSamples] = createSamples(systemA,systemB,savePath,varargin)
    swapProb = 0.5;
    if(~exist(savePath,'dir'))
        assert(mkdir(savePath),'Failed to make save directory');
    end
    
    if(isempty(varargin))
        numSamples = 100000;
    else
        numSamples = varargin{1};
    end
    
    assert(length(systemA) == length(systemB),'Input vectors of unequal length');
    swapMat = logical(getBernoulliSample(swapProb,length(systemA),numSamples));
    
    systemARep = repmat(systemA,1,numSamples);
    systemBRep = repmat(systemB,1,numSamples);
    
    systemARepCopy = systemARep;
    systemARep(swapMat) = systemBRep(swapMat);
    systemBRep(swapMat) = systemARepCopy(swapMat);
%     formatSpec = numel(num2str(numSamples+1));
%     for i = 1:numSamples
%         t = systemARep(:,i);
%         dlmwrite([savePath '/system_a_' num2str(i,['%.' num2str(formatSpec) 'd']) '.txt'],t);
%         t = systemBRep(:,i);
%         dlmwrite([savePath '/system_b_' num2str(i,['%.' num2str(formatSpec) 'd']) '.txt'],t);
%     end

    systemASamples = systemARep;
    systemBSamples = systemBRep;
    
end