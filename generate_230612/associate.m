function Y = associate(X)
%ASSOCIATE Transforme les valeurs des activites du jeu de données en de
%nouvelles activites parmis ALLEE, LOGETTE et AUGE 
%(cf CorrespondanceActivites.csv)
   % 1/2/5 : Immobile/Promenade/Boire -> 1 : ALLEE
   % 3 : Logette -> 2 : LOGETTE
   % 4 : Manger/Boire -> 3 : AUGE
   
   % Y = associate(X) retourne un tableau de meme taille que X dont les
   % valeurs correspondent a chaque association
   Y = arrayfun(@associate_single,X); 
end

function y = associate_single(x)
    if isnan(x)
        y = nan;
    elseif x==1 || x==2 || x==5
        y=1;
    elseif x==3
        y=2;
    elseif x==4
        y=3;
    else
        y=0;
    end
end