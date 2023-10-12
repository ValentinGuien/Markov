clear all
%%
%% Donnees reelles
cows = [6601,6610,6612,6613,6621,6629,6633,6634,6637,6638,6643,6646,6656,6664,6674,6675,6683,6686,6689,6690,6693,6695,6699,6701,6714,6721,6750,7600]; % Choix des vaches a simuler
ncows = length(cows);
%% RA SAIN
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
meanar = @(x)(mean(x.AR,2));
all_mean_AR = reshape(cell2mat(cellfun(meanar,data_ar_healthy,'UniformOutput',false)),24,ncows);
mean_all_AR = mean(all_mean_AR,2);
%%
t = 1:24;
meanoestrus = mean(data_ar_uh{1}.AR,2);
d = abs(meanoestrus-mean_all_AR);
[~,I] = sort(d);
%%
hours = [24,1:5];
fun = @(x)(getalldist(mean_all_AR,x.AR,hours,"chebychev")');
cellfunmat = @(C)(cell2mat(cellfun(fun,C,'UniformOutput',false)));

Sh = cellfunmat(data_ar_healthy);
Suh = fun(data_ar_uh{1});
%%
tab = table('Size',[length(Sh),3],'VariableType',["double","datetime","double"],'VariableNames',["cow","date","d"]);
tab.d = Sh;
k=1;
for icow = 1:ncows
    cow = cows(icow);
    ndays = length(data_ar_healthy{icow}.validdates);
    tab.cow(k:k+ndays-1) = cow;
    tab.date(k:k+ndays-1) = data_ar_healthy{icow}.validdates;
    k = k+ndays;
end
%% Separation
[f,xi] = ksdensity(Sh,'NumPoints',300);
TF = islocalmin(f);
threshold = xi(TF);
plot(xi,f,[threshold,threshold],[0,f(TF)],'r--')

groupA = tab(tab.d < threshold,(1:2));
groupB = tab(tab.d > threshold,(1:2));
%% Cow ?
pcows = zeros(ncows,1,2);
labels = cell(ncows,1);
for icow = 1:ncows
    cow = cows(icow);
    labels{icow} = num2str(cow);
    nA = sum(groupA.cow==cow);
    nB = sum(groupB.cow==cow);
    pA = nA/(nA+nB);
    pB = nB/(nA+nB);
    pcows(icow,1,:) = [pA,pB];
end
plotBarStackGroups(pcows,labels)
legend("Group A","Group B")

%% Date period ?

%% Date weekend ?
