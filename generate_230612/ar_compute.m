
%% Lecture donnees
filename = "../Data/mainActivity_filtered.csv";
rawdata = readtable(filename,'TreatAsMissing','NA'); % Donnees brutes

%% Initialisation
cows = unique(rawdata.CowId); % Les noms de vaches (66XX)
ncows = length(cows); % Nombre de vache
icowlist =1:ncows; % Les vaches numerotes 1,2,3,... qui vont etre regardees
%icowlist = 1;% DEBUG
ncowlist = length(icowlist);
data = cell(ncowlist,1);
%% Stockage calculs des RA
for icow = icowlist
    cow = cows(icow);
    Dcow = rawdata(ismember(rawdata.CowId,cow),:); 
    Dcow.date = datetime(Dcow.date,'InputFormat','dd.MM.yyyy');
    Dcow.mainActivity = associate(Dcow.mainActivity); % 1 a 5 -> 1 a 3
    dates = unique(Dcow.date);
    % Nettoyage : si + de donnees manquantes que 60 minutes, on retire le jour
    isvalid = @(date)(sum(isnan(Dcow(ismember(Dcow.date,date),:).mainActivity)) < 60);
    validdates = dates(arrayfun(isvalid,dates));
    celldays = cellcons(validdates); % Regroupage des dates qui se suivent
    Dcowfiltered = Dcow(ismember(Dcow.date,validdates),:);
    Vcow = reshape(Dcowfiltered.mainActivity,1440,length(validdates));
    %Vi,j = Etat a la minute i du jour j
    Vcow = fillmissing(Vcow,'nearest'); % On remplace les NaN ponctuels par l'etat le plus proche
    AR = ar(Vcow);
    data{icow}.cow = cow;
    data{icow}.AR = AR;
    data{icow}.dates = validdates;
end
%%
dirwrite = 'Data/Dataprocess/AR/';
if not(exist(dirwrite))
    mkdir(dirwrite);
end
for i=icowlist
    filenamewrite = [dirwrite '/' num2str(data{i}.cow) '.mat'];
    if not(exist(filenamewrite))
        ar_cow = data{i};
        save(filenamewrite,'ar_cow','-v7.3');
    else
        disp('File already exist !'); 
    end
end

