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
%% Comparaison difference chaine 1 heure

diffprob = zeros(3,3,ncows);
for i = 1:ncows
    Tf = data_real{i}.Tf;
    Tf1 = Tf(:,:,1:23);
    Tf2 = Tf(:,:,2:end);
    Tfdiff = (Tf2 - Tf1).^2;
    diffprob(:,:,i) = mean(Tfdiff,3);
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
%% SIMULATION PART
%%
t = linspace(0,24,nperiod+1);
t = t(1:end-1);
%% Average spent time on activities
spent_time = zeros(ncows,3);
spent_time_sim = zeros(ncows,3);
for icow=1:ncows
    spent_time(icow,:)=data_real{icow}.spent_time;
    spent_time_sim(icow,:)=data_sim{icow}.spent_time_sim;
end
%% Plot
b = plotaveragetime(cows,spent_time,spent_time_sim)
%% Distribution of individual cow act per hour
Mf = data_real{1}.Mf;
std_dist = data_real{1}.std_dist;
Ms = data_sim{1}.Ms;
std_dist_sim = data_sim{1}.std_dist_sim;

plotdistribstates(t,Mf,std_dist,Ms,std_dist_sim)
%% Distribution of average
all_Mf = zeros(3,nperiod,ncows);
all_std_dist = zeros(3,nperiod,ncows);
all_Ms = zeros(3,nperiod,ncows);
all_std_dist_sim = zeros(3,nperiod,ncows);
for i =1:ncows
    all_Mf(:,:,i) = data_real{i}.Mf;
    all_std_dist(:,:,i) = data_real{i}.std_dist;
    all_Ms(:,:,i) = data_sim{i}.Ms;
    all_std_dist_sim(:,:,i) = data_sim{i}.std_dist_sim;
end
meanmf = mean(all_Mf,3);
meanstddist = mean(all_std_dist,3);
meanms = mean(all_Ms,3);
meanstddistsim = mean(all_std_dist_sim,3);
plotdistribstates(t,meanmf,meanstddist,meanms,meanstddistsim)
%% Individual vs average
plotdistribstates(t,Mf,std_dist,meanmf,meanstddist)

%% Rythme d'activite REAL
all_AR_h = cell(1,ncows);
for i=1:ncows
    all_AR_h{i} = data_ar_healthy{i}.AR;
end
mean2 = @(x)(mean(x,2));
all_mean_AR = cell2mat(cellfun(mean2,all_AR_h,'UniformOutput',false));
mean_all_AR = mean(all_mean_AR,2);
std2 = @(x)(std(x,0,2));
all_std_AR = cell2mat(cellfun(std2,all_AR_h,'UniformOutput',false));
std_all_AR = mean(all_std_AR,2);
%% Rythme d'activite SIM
all_AR_h_sim = cell(1,ncows);
for i=1:ncows
    all_AR_h_sim{i} = data_sim{i}.AR;
end
mean2 = @(x)(mean(x,2));
all_mean_AR_sim = cell2mat(cellfun(mean2,all_AR_h_sim,'UniformOutput',false));
mean_all_AR_sim = mean(all_mean_AR_sim,2);
std2 = @(x)(std(x,0,2));
all_std_AR_sim = cell2mat(cellfun(std2,all_AR_h_sim,'UniformOutput',false));
std_all_AR_sim = mean(all_std_AR_sim,2);
%%
figure
xlabel('hours')
ylabel('activity level')
ax = gca;
ax.FontSize = 20;
hold on
%% REAL
plotar(t,mean_all_AR,'-',[0.4660 0.6740 0.1880],'Mean A.R. of all healthy cows REAL',std_all_AR,[0,0.7,0.7],'Std A.R. of all healthy cows REAL');
%% SIM
plotar(t,mean_all_AR_sim,'-','b','Mean A.R. of all healthy cows SIM',std_all_AR_sim,[0.7,0.7,0],'Std A.R. of all healthy cows SIM');
%%
legend()
set(gcf,'Color',[1 1 1])
%% 3 single ar of a cow real
ARcow = all_AR_h{1};
lineform = ["-.","--",":"];
for i=1:3

    AR = ARcow(:,i);
    plotar(t, AR, lineform(i), [i*0.3,0.7-i*0.2,1-i*0.3], ['AR of day ' num2str(i)]);
    hold on
end
axis([t(1) t(end) -inf inf])
xticks(t);
%% 3 single ar of a cow simulated
ARcowsim = all_AR_h_sim{1};
lineform = ["-.","--",":"];
for i=1:3

    ARsim = ARcowsim(:,i);
    plotar(t, ARsim, lineform(i), [i*0.3,0.7-i*0.2,1-i*0.3], ['AR of day ' num2str(i) ' SIM']);
    hold on
end
axis([t(1) t(end) -inf inf])
xticks(t);
%% 3 average ar of 3 cows healthy
figure
hold on
icowlist = 1:3;
for icow = icowlist
    ARcow = data_ar_healthy{icow}.AR_healthy;
    meanARcow = mean(ARcow,2);
    plot(t, meanARcow, 'LineWidth', 1,'LineWidth',2);
end
set(gcf,'Color',[1 1 1])
ax = gca;
ax.FontSize=20;
xlabel('hours')
xticks(t);
axis([t(1) t(end) -inf inf])
ylabel('activity level')
title('3 different average activity levels')
%%
for i=1:8
    AR_uh = data_ar_uh{i}.AR_uh;
    plot(t, mean(AR_uh,2), 'LineWidth', 1,'LineWidth',2,"DisplayName",data_ar_uh{i}.state);
end
legend()
set(gcf,'Color',[1 1 1])
ax = gca;
ax.FontSize=20;
xlabel('hours')
xticks(t);
axis([t(1) t(end) -inf inf])
ylabel('activity level')