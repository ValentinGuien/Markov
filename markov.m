clear all
%% Lecture donnees
rng('shuffle');
filename = "Data/mainActivity_filtered.csv";
rawdata = readtable(filename,'TreatAsMissing','NA'); % Donnees brutes
%% Initialisation des variables
p = 24*12; % nb de mesures par jour (24 pour chaque heure, 48 pour chaque demi-heure)
min_per_p = 60*24/p; %nombre de minutes par periodes
cows = unique(rawdata.CowId); % Les noms de vaches (66XX)
ncows = length(cows); % Nombre de vache
icowlist =1:ncows; % Les vaches numerotes 1,2,3,... qui vont etre regardee
ncowlist = length(icowlist);
data = cell(ncowlist,1);
all_temps_passe = zeros(ncowlist,3);
k=0;
%% Table des donnees d'une vache
for icow = icowlist % PENDING : 1:ncows
    k=k+1;
    cow = cows(icow);
    Dcow = rawdata(ismember(rawdata.CowId,cow),:);
    Dcow.date = datetime(Dcow.date,'InputFormat','dd.MM.yyyy');
    Dcow.mainActivity = associate(Dcow.mainActivity); % 1 a 5 -> 1 a 3
    dates = unique(Dcow.date);
    % Nettoyage : si + d'une heure de donnees manquantes on retire le jour
    isvalid = @(date)(sum(isnan(Dcow(ismember(Dcow.date,date),:).mainActivity)) < min_per_p);
    validdates = dates(arrayfun(isvalid,dates));
    celldays = cellcons(validdates);
    %
    n = length(celldays);
    M = zeros(3,p); % Fréquence d'état P/L/M a chaque periode
    T = zeros(3*p,3*p); % Nombre de transition entre chaque periode
    T_tot = zeros(3,3);% Moyennes des probabilites de transitions
    datedebut = 1;
    datefin = n;
    for iserie=datedebut:datefin %PENDING : iserie = 1:n
        serie = celldays{iserie};
        m = length(serie);
        sprec = 0;
        for idate = 1:m
            date = serie(idate);
            Ddate = Dcow(ismember(Dcow.date,date),:);
            for ip = 1:p
                X = Ddate(min_per_p*(ip-1)+1:min_per_p*ip,:).mainActivity;
                s = mode(X);
                M(s,ip) = M(s,ip)+1;
                if sprec ~=0
                    i = mod(3*(ip-2),3*p)+sprec;
                    j = 3*(ip-1)+s;
                    T(i,j)=T(i,j)+1;
                    T_tot(sprec,s)= T_tot(sprec,s)+1;
                end
                sprec = s;
            end
        end
    end
    M = M./sum(M);
    Tf = T./sum(T,2); % Matrice de transition
    T_tot = T_tot./sum(T_tot,'all');
    tmp = sum(reshape(sum(T),3,p));
    tmp = reshape(tmp(ones(1,3),:),1,3*p);
    Tf_p = T./tmp; % Matrice de toutes les transitions possibles par periode
    temps_passe = sum(M,2)*24/p;
    temps_passe = [temps_passe(1),temps_passe(2),temps_passe(3)];
    % Affectation des variables
    data{k}.Dcow = Dcow;
    data{k}.dates = dates;
    data{k}.validdates = validdates;
    data{k}.M = M;
    data{k}.Tf = Tf;
    data{k}.Tf_p = Tf_p;
    data{k}.temps_passe = temps_passe;
    all_temps_passe(k,:) = temps_passe;
end
%% Visualisation des moyennes de temps passe pour chaque vache
% Alleys - Cucibles - Feeding table
all_temps_passe
%%  Histogramme
subplot(221)
hist(all_temps_passe(:,1))
title("Alleys")
xlabel("cows")
ylabel("hours")
subplot(222)
hist(all_temps_passe(:,2))
title("Cubicles")
xlabel("cows")
ylabel("hours")
subplot(223)
hist(all_temps_passe(:,3))
title("Feeding table")
xlabel("cows")
ylabel("hours")
%%
%% Simulation
icow = 1; % choix de la vache à simuler
nsd = 10000; % Nombre de jours simules
Vs = zeros(p,nsd);
M = data{icow}.M;
Tf = data{icow}.Tf;
temps_passe = data{icow}.temps_passe; 
[~,tmp] = max(M);
Vs(1)= tmp(1);
for k=2:nsd*p
    spre = Vs(k-1);
    ip = mod(k-1,p)+1;
    l = mod(3*(ip-2)+spre-1,3*p)+1;
    c = 3*ip-2;
    Vs(k) = simulstate(Tf(l,c),1-Tf(l,c+2));
end
temps_passee_simul = [mean(sum(Vs==1))*min_per_p/60,...
    mean(sum(Vs==2))*min_per_p/60,mean(sum(Vs==3))*min_per_p/60];
% Lecture de la simulation
disp(['--------------------------------------------------'])
disp(['Cow n',num2str(cows(icow))])
disp(['Data from ', datestr(celldays{datedebut}(1)), ' to ', datestr(celldays{datefin}(end))])
disp(['Average spent time in alleys :',num2str(temps_passe(1))])
disp(['Average spent time in cubicles :',num2str(temps_passe(2))])
disp(['Average spent time in feeding table :',num2str(temps_passe(3))])
disp(['Simulation :'])
disp([num2str(nsd), ' jours simulated'])
disp(['Alleys :',num2str(temps_passee_simul(1))])
disp(['Cubicle :',num2str(temps_passee_simul(2))])
disp(['Feeding table :',num2str(temps_passee_simul(3))])