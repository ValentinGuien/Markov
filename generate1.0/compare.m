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
discrete = 0;
ntype = 'probability';
% NO : hamming, jaccard
measures = {"euclidean",@dtw,"cityblock","cosine","minkowski",...
    "chebychev","correlation","spearman"};
measuresnames = ["euclidean","dtw","manhattan","cosine","minkowski, p=3",...
    "chebychev","correlation","spearman"];
measureslen = size(measures,2);

for nhours = [3,5,7,10,15,20,24]
hours = sort(I(end-nhours+1:end))
hours = [1:6];
figure;

for im = 1:measureslen
   measure = measures{im};
   measurename = measuresnames(im);
    
   fun = @(x)(getalldist(mean_all_AR,x.AR,hours,measure)');
   cellfunmat = @(C)(cell2mat(cellfun(fun,C,'UniformOutput',false)));
   
   Sh = cellfunmat(data_ar_healthy);
   Suh = fun(data_ar_uh{1});
   
   
   subplot(ceil(measureslen/2),2,im)
   
   if discrete
       [N1,edges1] = histcounts(Sh,'Normalization', ntype);
        width1 = edges1(2)-edges1(1);
        centres1 = edges1(2:end)-width1/2;
        plot(centres1,N1);
        hold on
        [N2,edges2] = histcounts(Suh,'Normalization', ntype);
        width2 = edges2(2)-edges2(1);
        centres2 = edges2(2:end)-width2/2;
        plot(centres2,N2);
   else
        ksdensity(Sh)
        hold on
        ksdensity(Suh)
   end
 
   title(measurename);
   legend("sane","oestrus")
   xlabel('distance')
   ylabel('density')
   
end

sgtitle(['Top ' num2str(nhours) 'hours'])

end
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
