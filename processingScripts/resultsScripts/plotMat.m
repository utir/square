function plotMat(mat)
    mat(:,1) = [];
    mat(:,end) = [];
    mat(1:3,:) = [];
    xLabels = [];
    for i = 1:size(mat,1)
        xLabels = [xLabels; 1:size(mat,2)];
    end
    scatterplot(mat);
    lineFormats = {'.+','.o','.*','.-+','.x','.-s','.d','.^','.v','.>','.<','.p','.h''','.+','.o','.*'};
    
    for i = 1:size(mat,1)
        plot(xLabels(i,:),mat(i,:),lineFormats{i});
        hold on;
    end
    hold off;
end