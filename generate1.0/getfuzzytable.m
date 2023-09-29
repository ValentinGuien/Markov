function fuzzy_table = getfuzzytable(abn_data,rules)
%GETFUZZYDAYS Permet à partir du tableau des donnees anormales de retourner
%  la table des donnees "floues" (donnees qui sont obtenues sur des jours
%  flous)

% abn_data : table des donnees ne comportant que les donnees ou la vache
% est dans un etat anormal
% rules : structure contenant les regles associees a chaque anomalie

   datescows = unique(abn_data(:,{'cow','date','oestrus','calving',...
        'lameness','mastitis','LPS','other_disease',...
        'accidents','disturbance','mixing'})); % Recuperation des valeurs aux etats anormaux
    n = height(datescows);
    fuzzy_table = table('Size',[4*n 2],'VariableTypes',["double","datetime"],...
        'VariableNames',["cow","date"]); 
    k=1;
    for irow = 1:n
        row = datescows(irow,:);
        fzydays = fuzzyrow(row,rules);
        m = length(fzydays);
        for j=1:m
            fuzzy_table(k,:) = {row.cow,fzydays(j)};
            k=k+1;
        end
    end
    fuzzy_table = fuzzy_table(1:k-1,:);
    
end


function fuzzydays = fuzzyrow(row,rules)
    if row.oestrus==1
        fuzzydays = [(row.date+rules.oestrus(1)):(row.date-1),(row.date+1:row.date+rules.oestrus(2))]; 
    elseif row.calving==1
        fuzzydays = [(row.date+rules.calving(1)):(row.date-1),(row.date+1:row.date+rules.calving(2))];
    elseif row.lameness==1
        fuzzydays = [(row.date+rules.lameness(1)):(row.date-1),(row.date+1:row.date+rules.lameness(2))];
    elseif row.mastitis==1
        fuzzydays = [(row.date+rules.mastitis(1)):(row.date-1),(row.date+1:row.date+rules.mastitis(2))];
    elseif row.LPS==1
        fuzzydays = [(row.date+rules.LPS(1)):(row.date-1),(row.date+1:row.date+rules.LPS(2))];
    elseif row.other_disease==1
        fuzzydays = [(row.date+rules.other_disease(1)):(row.date-1),(row.date+1:row.date+rules.other_disease(2))];
    elseif row.accidents==1
        fuzzydays = [];
    elseif row.disturbance==1
        fuzzydays = [(row.date+rules.disturbance(1)):(row.date-1),(row.date+1:row.date+rules.disturbance(2))];
    elseif row.mixing==1
        fuzzydays = [(row.date+rules.mixing(1)):(row.date-1),(row.date+1:row.date+rules.mixing(2))];
    end
end
