function h = plotaveragetime(cows,realdata,simulateddata)
%PLOTDISTRIB Afficher l'histogramme des moyennes des temps passes dans les
%activites entre les donnees reelles et les donnees simulees pour chaque
%vache

% cows : la liste des vaches dont on mesure les donnees
% realdata : tableau des moyennes passees dans chaque activite pour chaque
% vache pour les donnees reelles
% simulateddata : meme format que realdata, mais pour les donnees simulees
    n = length(cows);
    groupLabels = cell(1,n);
    for i=1:n
        groupLabels{i}=cows(i);
    end
    tmp = reshape(cat(1,realdata,simulateddata),n,2,3);
    h = plotBarStackGroups(tmp,groupLabels);
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
