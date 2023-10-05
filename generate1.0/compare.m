clear all
%% Donnees reelles
cows = [6601,6610,6612,6613,6621,6629,6633,6634,6637,6638,6643,6646,6656,6664,6674,6675,6683,6686,6689,6690,6693,6695,6699,6701,6714,6721,6750,7600]; % Choix des vaches a simuler
ncows = length(cows);
periodsize = 60; % taille de la periode que l'on souhaite en minutes
nperiod = 1440/periodsize;
dir = ['Dataprocess/Models/' num2str(periodsize) 'minutes/']; dir = dir(ones(ncows,1),:);
mat = '.mat'; mat = mat(ones(ncows,1),:);
filenames = [dir num2str(cows') mat];
data_real = cell(ncows,1); % Tableau de cellules donnant les donnees reelles
for i=1:ncows
   filename = filenames(i,:);
   data_real{i} = load(filename);
end
%% Donnees simulees
nsd = 100;
dir = ['Dataprocess/Simulation/' num2str(periodsize) 'minutes/' num2str(nsd) 'days/']; dir = dir(ones(ncows,1),:);
mat = '.mat'; mat = mat(ones(ncows,1),:);
filenames = [dir num2str(cows') mat];
data_sim = cell(ncows,1);
for i=1:ncows
   filename = filenames(i,:);
   data_sim{i} = load(filename);
end
%% Rythme d'activite sains
dir = ['Dataprocess/AR/Healthy/all/']; dir = dir(ones(ncows,1),:);
mat = '.mat'; mat = mat(ones(ncows,1),:);
filenames = [dir num2str(cows') mat];
data_ar_healthy = cell(ncows,1);
for i=1:ncows
   filename = filenames(i,:);
   data_ar_healthy{i} = load(filename);
end
%% RA pas sain
abn_states = ["oestrus","calving",...
        "lameness","mastitis","LPS","other_disease",...
        "accidents","mixing"];
nabnstates = length(abn_states);
dir = ['Dataprocess/AR/Unhealthy/']; dir = dir(ones(nabnstates,1),:);
mat = '.mat'; mat = mat(ones(nabnstates,1),:);
filenames = dir + abn_states' +mat;
data_ar_uh = cell(nabnstates,1);
for i=1:nabnstates
   filename = filenames(i,:);
   data_ar_uh{i} = load(filename);
end
%%
%% TRAITEMENT
all_AR_h = cell(1,ncows);
for i=1:ncows
    all_AR_h{i} = data_ar_healthy{i}.AR_healthy;
end
mean2 = @(x)(mean(x,2));
all_mean_AR = cell2mat(cellfun(mean2,all_AR_h,'UniformOutput',false));
mean_all_AR = mean(all_mean_AR,2);
std2 = @(x)(std(x,0,2));
all_std_AR = cell2mat(cellfun(std2,all_AR_h,'UniformOutput',false));
std_all_AR = mean(all_std_AR,2);
%%
% S = cell(ncows,1);
% myfunc = @(X)(euclidiandist(X,mean_all_AR));
% for icow = 1:ncows
%     ndays = size(all_AR_h{icow},2);

%     s = zeros(ndays,1);
%     for iday = 1:ndays
%         s(iday) = myfunc(all_AR_h{icow}(:,iday));
%     end
%     S{icow} = s;
% end
%% 
figure;
S = getprobdist(mean_all_AR,all_AR_h,@euclidiandist,1);

subplot(1,2,1); g = histogram(S);
    xlabel("Bin Centres"); ylabel("Bin Counts");
 
    g.BinCounts = g.BinCounts/sum(g.BinCounts);
       Bin_Counts = g.BinCounts;
    Bin_Width = g.BinWidth;
    Bin_Centres = g.BinEdges(2:end) - Bin_Width/2;

    subplot(1,2,2); plot(Bin_Centres,Bin_Counts);
    xlabel("Bin Centres"); ylabel("Bin Counts");
    hold on;
%%
S = getprobdist(mean_all_AR,data_ar_uh{8},@euclidiandist,0);
subplot(1,2,1); g = histogram(S);
    xlabel("Bin Centres"); ylabel("Bin Counts");

    g.BinCounts = g.BinCounts/sum(g.BinCounts);
        Bin_Counts = g.BinCounts;
    Bin_Width = g.BinWidth;
    Bin_Centres = g.BinEdges(2:end) - Bin_Width/2;

    subplot(1,2,2); plot(Bin_Centres,Bin_Counts/2);
    xlabel("Bin Centres"); ylabel("Bin Counts");