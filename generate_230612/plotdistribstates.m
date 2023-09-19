function plotdistribstates(t,realdata,stdrealdata,simulateddata,stdsimulateddata)
%PLOTDISTRIB Affiche les distributions d'etats
%   Detailed explanation goes here
    confintreal = 1.96*stdrealdata/sqrt(length(realdata));
    confintsim = 1.96*stdsimulateddata/sqrt(length(simulateddata));
    figure
    for i = 1:3
        h(1,i)=subplot(2,3,i);
        bar(t,realdata(i,:),'FaceColor',[0.9290 0.6940 0.1250])
        hold on
        errorbar(t,realdata(i,:),confintreal(i,:),'.','color','k','LineWidth',1)
        axis([t(1) t(end) 0 1])
        ax = gca;
        ax.XAxis.TickValues = [0 4 8 12 16 20];
        ax.XAxis.FontSize = 25;
        ax.YAxis.FontSize = 25;
        h(2,i) = subplot(2,3,i+3);
        bar(t,simulateddata(i,:),'FaceColor',[0.9290 0.6940 0.7250])
        hold on
        errorbar(t,simulateddata(i,:),confintsim(i,:),'.','color','k','LineWidth',1)
        axis([t(1) t(end) 0 1])
        ax = gca;
        ax.XAxis.TickValues = [0 4 8 12 16 20];
        ax.XAxis.FontSize = 25;
        ax.YAxis.FontSize = 25;
    end
    set(gcf,'Color',[1 1 1])
    h(1,1).YLabel.String = 'proportion';
    h(1,1).YLabel.FontSize = 25;
    h(2,1).YLabel.String = 'proportion';
    h(2,1).YLabel.FontSize = 25;
    h(2,1).XLabel.String = 'hours';
    h(2,1).XLabel.FontSize=25;
    h(2,2).XLabel.String = 'hours';
    h(2,2).XLabel.FontSize=25;
    h(2,3).XLabel.String = 'hours';
    h(2,3).XLabel.FontSize=25;
    

   
end

