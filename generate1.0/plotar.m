function plotar(t,AR,lineform, colorline,namereal,stdAR,colorfill,namesim)
%PLOTAR Permet d'afficher les courbes de rythmes d'activites

% t : echelle temporelle
% AR : courbe a afficher
% lineform : forme de la courbe
% colorline : couleur de la courbe
% namereal :
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

