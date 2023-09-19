function h = plotaveragetime(cows,realdata,simulateddata)
%PLOTDISTRIB Summary of this function goes here
%   Detailed explanation goes here
    n = length(cows);
    groupLabels = cell(1,n);
    for i=1:n
        groupLabels{i}=cows(i);
    end
    tmp = reshape(cat(1,realdata,simulateddata),length(cows),2,3);
    h = plotBarStackGroups(tmp,groupLabels);
    alleycolor = [0.5 0.4470 0.7410];
    cubcolor = [0.8500 0.3250 0.5980];
    ftcolor = [0.9290 0.6940 0.6250];
    h(1).FaceColor = [1,1,0];
    h(2).FaceColor = [0.6,0.6,0];
    h(3).FaceColor = [0.2,0.6,1];
    h(4).FaceColor = [0,0,1];
    h(5).FaceColor = [1,0.2,0.2];
    h(6).FaceColor = [0.6,0,0];
    ax = gca;
    ax.FontSize = 25;
    ax.XTickLabel = [1:28];
    xlabel("cows",'FontSize',25)
    legend("alleys","cubicles","feeding table","alleys simulated",...
        "cubicles simulated","feeding table simulated",'FontSize',25)
    ylabel("hours",'FontSize',25)
    set(gcf,'Color',[1 1 1])

end
