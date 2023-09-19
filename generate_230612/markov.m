clear all % Nettoyage des donnees
%% Lecture donnees
filename = "../Data/mainActivity_filtered.csv";
rawdata = readtable(filename,'TreatAsMissing','NA');

%% Initialisation

cows = unique(rawdata.CowId); % Les noms des vaches (numeros a 4 chiffres)
ncows = length(cows); % Nombre de vaches
icowlist =1:ncows; % Les vaches numerotes 1,2,3,... qui vont etre regardees
% DEBUG : icowlist = 1 pour un tableau d'entree moins lourd
ncowlist = length(icowlist); 
data = cell(ncowlist,1); % Les donnees sont enregistres dans data

% Pour mesurer les temps moyens passes dans chaque activite
all_spent_time = zeros(ncowlist,3); 


%% Choix sur la taille des periodes
periodsize = 60; % taille de la periode en minutes
nperiod = 1440/periodsize; % nombre de periodes par jour

%% Stockage des donnees nettoyee dans une matrice
for icow = icowlist % Pour chaque vache
    cow = cows(icow);
    Dcow = rawdata(ismember(rawdata.CowId,cow),:); % Tableau reduit a une vache
    Dcow.date = datetime(Dcow.date,'InputFormat','dd.MM.yyyy');
    Dcow.mainActivity = associate(Dcow.mainActivity); % 1 a 5 -> 1 a 3
    dates = unique(Dcow.date); % les dates ou on a des mesures pour la vache
    
    % Nettoyage : si + de donnees manquantes que 60 minutes, on retire le jour
    isvalid = @(date)(sum(isnan(Dcow(ismember(Dcow.date,date),:).mainActivity)) < 60);
    validdates = dates(arrayfun(isvalid,dates));    
    Dcowfiltered = Dcow(ismember(Dcow.date,validdates),:);
    
    V = reshape(Dcowfiltered.mainActivity,1440,length(validdates));
    %V_i,j = Etat a la minute i du jour j
    V = fillmissing(V,'nearest'); % On remplace les NaN par l'etat le plus proche

    % Regroupement des dates successives entre elles par cellules
    celldays = cellcons(validdates); % La fonction cellcons fonctionne avec les dates
    n = length(celldays); %Nombre de groupes de jour
    
    M = zeros(3,nperiod); % Nombre d'état AL/LO/AU a chaque periode
    %M i,j = Nombre d'etat i a l'heure j
    T = zeros(3,3,nperiod); % Nombre de transition entre chaque periode 
    %T i,j,k = Transitions de l'etat i a j dans la periode k
    
    % Index min et max sur celldays.
    % DEBUG : datestart = dateend
    datestart = 1;
    dateend = n;
    
    
    % Remplissage des matrices M, T
    k = 0; %le jour k
    for iserie=datestart:dateend % Pour chaque serie
        serie = celldays{iserie}; % Une serie de jours
        nserie = length(serie); % Nombre de jours dans la serie
        precstate = 0; % Etat precedent, initialise a 0 pour le debut d'une serie
        for idate = 1:nserie % Pour chaque date
            date = serie(idate); 
            k = k+1;
            for iperiod = 1:nperiod % Pour chaque periode
                for minute = 1:periodsize % Pour chaque minute
                    state = V(periodsize*(iperiod-1)+minute,k);
                    M(state,iperiod) = M(state,iperiod)+1;
                    if precstate ~=0 % Ne s'applique pas quand 2 heures ne se suivent pas
                        i = precstate;
                        j = state;
                        T(i,j,iperiod)=T(i,j,iperiod)+1;
                    end
                    precstate = state;
                end
            end
        end
    end
    
    % Obtention des matrices de frequences 
    
    Mf = M./sum(M); %Frequence d'état P/L/M a chaque periode
    Tf = T./sum(T,2); % Matrice des probabilites de transition
    Tf_all = T./sum(T,[1 2]); % Matrice des probabilites de transition totales
    spent_time = sum(Mf,2)*24/nperiod;
    spent_time = [spent_time(1),spent_time(2),spent_time(3)]; % les temps passes dans chaque activite par jour
    % Calcul des ecart-type sur la proportion quotidienne de chaque etat
    % par periode
    std_dist = zeros(3,nperiod); 
    Vtmp = reshape(V,periodsize,nperiod,length(validdates));
    for j=1:3
        std_dist(j,:)=std(sum(Vtmp==j)/periodsize,0,3);
    end
    % Stockage des resultats pour la vache
     data{icow}.periodsize = periodsize;
     data{icow}.dates = validdates;
     data{icow}.cow = cow;
     data{icow}.V = V;
     data{icow}.M = M;
     data{icow}.Mf = Mf;
     data{icow}.T = T;
     data{icow}.Tf = Tf;
     data{icow}.Tf_all = Tf_all;
     data{icow}.spent_time = spent_time;
     data{icow}.std_dist = std_dist;
     all_spent_time(icow,:) = spent_time;
end

%% Stockage des resultats dans des fichiers pour des executions longues

% 1 si on reecrit des resultats deja existant
% 0 sinon
overwrite=1;

% repertoire d'ecriture associes aux modeles de la periode precisee
dirwrite = ['Dataprocess/Models/' num2str(periodsize) 'minutes/'];
 
if not(exist(dirwrite))
    mkdir(dirwrite);
end
for i=icowlist
    filenamewrite = [dirwrite num2str(data{i}.cow) '.mat'];
    if not(exist(filenamewrite)) || overwrite==1
        model_cow = data{i};
        save(filenamewrite,'model_cow');
        disp(['Donnees enregistrees sur ' filenamewrite])        
    end
end

%%  Histogrammes du temps passe pour toutes les vaches
figure
subplot(131)
hist(all_spent_time(:,1))
title("Alleys")
ylabel("cows")
xlabel("hours")
subplot(132)
hist(all_spent_time(:,2))
title("Cubicles")
ylabel("cows")
xlabel("hours")
subplot(133)
hist(all_spent_time(:,3))
title("Feeding table")
ylabel("cows")
xlabel("hours")
