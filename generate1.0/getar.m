clear all
%% Import des donnees
filename = "../Data/dataset1-1.csv"; % Jeu de donnees contenant le statut de la vache et les RA a chaque heure
rawdata = readtable(filename,'TreatAsMissing','NA');
data = removevars(rawdata,{'acidosis'}); % Nettoyage de 'acidosis'
cows = unique(data.cow);
ncows = length(cows);

%% Sauvegarde des resultats
saveresults = 1;
dirwrite_healthy = 'Dataprocess/AR/Healthy/all/';
if not(exist(dirwrite_healthy))
    mkdir(dirwrite_healthy);
end
dirwrite_unhealthy = 'Dataprocess/AR/Unhealthy/';
if not(exist(dirwrite_unhealthy))
    mkdir(dirwrite_unhealthy);
end
%% Liste des regles
% Les regles se presentent sous la forme [-k1,k2]
% Si un jour est detecte comme etant un jour d'etat anormal pour une vache,
% alors la regle en question consiste a considerer les k1 jours precedents
% et les k2 jours suivants comme des jours flous

% ex : si la vache est sous oestrus le jour J, alors le jour J-1 et le jour
% J+1 sont des jours flous.
rules = struct;
rules.oestrus = [-1;1];
rules.calving = [-2;1];
rules.lameness = [-2;1];
rules.mastitis = [-2;1];
rules.LPS = [0;1];
rules.acidosis = [-1;2];
rules.other_disease = [-2;1];
rules.disturbance = [0;1];
rules.mixing = [0;1];
% 
% bigrules = [-2;7];
% rules.oestrus = bigrules;
% rules.calving = bigrules;
% rules.lameness = bigrules;
% rules.mastitis = bigrules;
% rules.LPS = bigrules;
% rules.acidosis = bigrules;
% rules.other_disease = bigrules;
% rules.disturbance = bigrules;
% rules.mixing = bigrules;
%%
data.date = datetime(data.date,'InputFormat','yyyy-MM-dd');
abn_data = data(data.OK~=1,:); % table des donnees ou les etats sont anormaux
fuzzy_data = getfuzzytable(abn_data,rules); % table contenant les couplets Vache-Jour flou
%% Vaches saines
data_ar_healthy = struct;
for icow = 1:ncows % Pour chaque vache
  cow = cows(icow);
  Dcow = data(ismember(data.cow,cow),:); 
  Dcowfuzzy = fuzzy_data(ismember(fuzzy_data.cow,cow),:); % Table des donnees floues pour la vache
  Dcowabn = abn_data(ismember(abn_data.cow,cow),:); % Table des donnees anormales pour la vache
  dates = unique(Dcow.date);
  isvalid = @(date)(height(Dcow(ismember(Dcow.date,date),:)) == 24);
  validdates = dates(arrayfun(isvalid,dates)); % Pas de donnees manquante sur les 24 heures
  validdates = setdiff(validdates,Dcowabn.date); % Pas de donnees de vache non saines
  validdates = setdiff(validdates,Dcowfuzzy.date); % Pas de donnees floues
  Dcowfiltered = Dcow(ismember(Dcow.date,validdates),:);
  AR_healthy = reshape(Dcowfiltered.ACTIVITY_LEVEL,24,length(validdates));

  % Enregistrement des donnees
  if saveresults
    data_ar_healthy.cow = cow;
    data_ar_healthy.AR = AR_healthy;
    data_ar_healthy.validdates = validdates;
    filenamewrite = [dirwrite_healthy num2str(data_ar_healthy.cow) '.mat'];
    save(filenamewrite,'-struct','data_ar_healthy','-v7.3');
    disp(['Donnees enregistrees sur ' filenamewrite])
  end
end

%% Vaches non saines
cows_uh = unique(abn_data.cow); % Les vaches ayant des donnees anormales
ncows_uh = length(cows_uh); 
abn_states = ["oestrus","calving",...
        "lameness","mastitis","LPS","other_disease",...
        "accidents","mixing"]; % Les etats anormaux possibles
% acidosis et disturbance est exclu dans ce jeu de donnees
abn_states_num = [8:14,16]; % index en colonnes des etats anormaux decrits
% TMP : Disturbance exclu
nabnstates = length(abn_states);
data_ar_unhealty =struct;

for i=1:nabnstates
    state = abn_states(i);
    numstate = abn_states_num(i);
    Dstate = abn_data(table2array(abn_data(:,abn_data.Properties.VariableNames{numstate}))==1,:);
    AR_uh = reshape(Dstate.ACTIVITY_LEVEL,24,height(Dstate)/24);
    

    if saveresults
        data_ar_unhealty.state = state;
        data_ar_unhealty.AR = AR_uh;
        filenamewrite = [dirwrite_unhealthy char(data_ar_unhealty.state) '.mat'];
        save(filenamewrite,'-struct', 'data_ar_unhealty','-v7.3');
        disp(['Donnees enregistrees sur ' filenamewrite])
    end
end
%%