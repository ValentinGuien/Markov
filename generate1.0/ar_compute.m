clear all
%% Lecture donnees
filename = "../Data/mainActivity_filtered.csv";
rawdata = readtable(filename,'TreatAsMissing','NA'); % Donnees brutes


%% Initialisation
cows = unique(rawdata.CowId); % Les noms de vaches (numeros a 4 chiffres)
ncows = length(cows); % Nombre de vache
icowlist =1:ncows; % Les vaches numerotes 1,2,3,... qui vont etre regardees
ncowlist = length(icowlist);
data = struct; %Les donnees sont enregistrees dans data

dirwrite = 'Dataprocess/AR/Healthy/filtered/';

% 1 si on souhaite enregistrer les resultats, 0 sinon
saveresults=1;
if not(exist(dirwrite))
    mkdir(dirwrite);
end
%% Mode DEBUG
DEBUG = 0;
if DEBUG
    icowlist = 1; % DEBUG : pour un tableau d'entree moins lourd
    ncowlist = length(icowlist);
    disp('MODE DEBUGGAGE')
end
%% Stockage calculs des RA
for icow = icowlist % Pour chaque vache
    cow = cows(icow);
    Dcow = rawdata(ismember(rawdata.CowId,cow),:); % Tableau reduit a une vache
    Dcow.date = datetime(Dcow.date,'InputFormat','dd.MM.yyyy');
    Dcow.mainActivity = associate(Dcow.mainActivity); % 1 a 5 -> 1 a 3
    dates = unique(Dcow.date);
    
    % Nettoyage : si + de donnees manquantes que 60 minutes, on retire le jour
    isvalid = @(date)(sum(isnan(Dcow(ismember(Dcow.date,date),:).mainActivity)) < 60);
    validdates = dates(arrayfun(isvalid,dates));
    Dcowfiltered = Dcow(ismember(Dcow.date,validdates),:);
    
    Vcow = reshape(Dcowfiltered.mainActivity,1440,length(validdates));
    %Vcow_i,j = Etat a la minute i du jour j
    Vcow = fillmissing(Vcow,'nearest'); % On remplace les NaN par l'etat le plus proche
    %celldays = cellcons(validdates); % Regroupage des dates qui se suivent

    AR = ar(Vcow);

    if saveresults == 1
            data.cow = cow;
        data.AR = AR;
        data.dates = validdates;
    
    filenamewrite = [dirwrite num2str(cow) '.mat'];
        save(filenamewrite,'-struct','data','-v7.3');
        disp(['Donnees enregistrees sur ' filenamewrite]); 
    end
end
%%