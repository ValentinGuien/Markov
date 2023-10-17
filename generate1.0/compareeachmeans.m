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
%% TRAITEMENT
meanar = @(x)(mean(x.AR,2));


all_mean_AR = reshape(cell2mat(cellfun(meanar,data_ar_healthy,'UniformOutput',false)),24,ncows);
mean_all_AR = mean(all_mean_AR,2);
stdar = @(x)(std(x.AR,0,2));
all_std_AR = reshape(cell2mat(cellfun(stdar,data_ar_healthy,'UniformOutput',false)),24,ncows);
std_all_AR = mean(all_std_AR,2);
%%
t = 1:24;
meanoestrus = mean(data_ar_uh{1}.AR,2);
d = abs(meanoestrus-mean_all_AR);
[~,I] = sort(d);
%%
hours = [1:6];
for icow = 1:ncows
   cow = cows(icow);
    
   fun = @(x)(getalldist(mean(x.AR,2),x.AR,hours,"chebychev")');
   
   
   Sh = fun(data_ar_healthy{icow});
   Suh = fun(data_ar_uh{1});
   
 
    subplot(ceil(ncows/6),7,icow)
   

        ksdensity(Sh)
        hold on
        ksdensity(Suh)
        axis([0 3000 0 0.003])
   
 
   title(num2str(cow));

   
end

sgtitle(['Compute based on distance with the mean AR of each cow (whole day)'])


% Chebychev peut etre interessant mais provoque des courbes bizarres
% tester Minkowski avec moins d'heures

%% Chebyshev ??
% hours = 1:24;
% 
% distchebychev = @(X)(max(abs(mean_all_AR-X.AR)));
% [dhc,Ihc] = cellfun(distchebychev,data_ar_healthy,'UniformOutput',false);
% dh = cell2mat(reshape(dhc,1,ncows));
% Ih = cell2mat(reshape(Ihc,1,ncows));
% [duhc,Iuhc] = cellfun(distchebychev,data_ar_uh,'UniformOutput',false);
% duh = cell2mat(reshape(duhc,1,size(duhc,1)));
% Iuh = cell2mat(reshape(Iuhc,1,size(Iuhc,1)));
% figure
% for h = 1:24
%     subplot(5,5,h)
%     indexh = find(Ih==h);
%     dh_h = dh(indexh);
%     indexuh = find(Iuh==h);
%     duh_h = dh(indexuh);
%     ksdensity(dh_h);
%     hold on
%     ksdensity(duh_h);
%     title(['h = ' num2str(h)])
%    
% end
% figure 
% histogram(Ih,'Normalization','probability')
% hold on
% histogram(Iuh,'Normalization','probability')