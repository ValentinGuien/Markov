function plotar(t,AR,lineform, colorline,namereal,stdAR,colorfill,namesim)
%PLOTAR Summary of this function goes here
%   Detailed explanation goes here

%     plot(t, AR, colorline, 'LineWidth', 2,"DisplayName",name);
%     errorbar(t,AR,stdAR,'.',"MarkerEdgeColor",colorline)
    if nargin > 5
        curve1 = AR + stdAR;
        curve2 = AR - stdAR;
        t2 = [t, fliplr(t)];
        inBetween = [curve1', fliplr(curve2')];
        fill(t2, inBetween,colorfill,'FaceAlpha',0.3,"DisplayName",namesim);
        hold on;
    end
    plot(t, AR, lineform,'color',colorline, 'LineWidth', 3,"DisplayName",namereal);
    
end

