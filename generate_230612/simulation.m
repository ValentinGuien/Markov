clear all
rng('default') % DEBUG : Graine a 0

%% Initialisation
cows = [6601,6610,6612,6613,6621,6629,6633,6634,6637,6638,6643,6646,6656,6664,6674,6675,6683,6686,6689,6690,6693,6695,6699,6701,6714,6721,6750,7600]; % Choix des vaches a simuler
% cows = 6601 % Simulation pour une seule vache

periodsize = 60; % taille de la periode que l'on souhaite en minutes
nperiod = 1440/periodsize;
nsd = 10000; % Nombre de jours a simuler
%% Chargement des donnees
ncows = length(cows); 
dir = ['Dataprocess/Models/' num2str(periodsize) 'minutes/']; dir = dir(ones(ncows,1),:);
mat = '.mat'; mat = mat(ones(ncows,1),:);
filenames = [dir num2str(cows') mat];
data = cell(ncows,1);
for i=1:ncows
   filename = filenames(i,:);
   data{i} = load(filename);
end


data_sim = cell(ncows,1); % Tableau de cellules qui contiendra chaque simulation

%% Debut de la simulation
for icow = 1:ncows
    cow = cows(icow);
    Vs = zeros(1440,nsd); % Matrice des etats simules
    % Vs i j  : minute i du jour simule j
    Ms = zeros(3,nperiod); % Nombre d'etats simules
    % M i j : nombre d'apparition de l'etat i a la periode j
    
    Mf = data{icow}.model_cow.Mf;
    Tf = data{icow}.model_cow.Tf;
    
    for sd = 1:nsd % Pour chaque jour simule
        for minute=1:1440 % Pour chaque minute simulee
            if minute == 1 && sd == 1 % Pas d'etat precedent, on choisit un etat initial base sur le plus present dans Mf
                [~,tmp] = max(Mf);
                Vs(1,1)= tmp(1); % Etat initial
                Ms(tmp(1),1) = 1;
            else
                if minute==1
                    precstate = Vs(end,sd-1);
                else
                    precstate = Vs(minute-1,sd);
                end
                period = fix((minute-1)/periodsize)+1;
                state = simulstate(Tf(precstate,1,period),...
                    Tf(precstate,3,period)); % Etat simule a partie des probabilites de transition
                Vs(minute,sd) = state;
                Ms(state,period)=Ms(state,period)+1;
            end
        end
    end
    
    Ms = Ms./sum(Ms,1); % Proportions des temps passes dans chaque activite par periode
    spent_time_sim = sum(Ms,2)*24/nperiod;
    spent_time_sim = [spent_time_sim(1),spent_time_sim(2),spent_time_sim(3)]; % les temps passes dans les activites par jour
    ARsim = ar(Vs);
    std_dist_sim = zeros(3,nperiod); % Les ecarts-types des proportion de chaque activite par periode
    Vstmp = reshape(Vs,periodsize,nperiod,nsd);
    for j=1:3
        std_dist_sim(j,:)=std(sum(Vstmp==j)/periodsize,0,3);
    end
    % Stockage
    data_sim{icow}.periodsize = periodsize;
    data_sim{icow}.cow = cow;
    data_sim{icow}.nsd = nsd;
    data_sim{icow}.Ms = Ms;
    data_sim{icow}.AR = ARsim;
    data_sim{icow}.spent_time_sim = spent_time_sim;
    data_sim{icow}.std_dist_sim=std_dist_sim;
end

%% Stocker simulation

% 1 si on reecrit sur des resultats deja existant
% 0 sinon
overwrite=1;

dirwrite = ['Dataprocess/Simulation/' num2str(periodsize) 'minutes/' num2str(nsd) 'days/'];
if not(exist(dirwrite))
    mkdir(dirwrite);
end
for i=1:ncows
    filenamewrite = [dirwrite num2str(data_sim{i}.cow) '.mat'];
    if not(exist(filenamewrite)) || overwrite==1
        sim_cow = data_sim{i};
        save(filenamewrite,'sim_cow');
        disp(['Donnees enregistrees sur ' filenamewrite]) 
    end
end
