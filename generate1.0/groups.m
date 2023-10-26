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
removedatesbool = 1;

 startremovedate = datetime('18-Jan-2019');
 endremovedate = datetime('16-Mar-2019');

hours = [1:5,24];
fun = @(x)(getalldist(mean_all_AR,x.AR,hours,"chebychev")');
cellfunmat = @(C)(cell2mat(cellfun(fun,C,'UniformOutput',false)));

Sh = cellfunmat(data_ar_healthy);
Suh = fun(data_ar_uh{1});

   if removedatesbool
       removedates = @(x)(startremovedate > x.validdates | ...
       x.validdates > endremovedate);
       Idate = cell2mat(cellfun(removedates,data_ar_healthy,'UniformOutput',false));
       Sh = Sh(Idate);
   end
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
figure
plot(xi,f,[threshold,threshold],[0,f(TF)],'r--')

groupA = tab(tab.d < threshold,(1:2));
groupB = tab(tab.d > threshold,(1:2));
proportion = size(groupA,1)/size(tab,1);
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
[~,I2] = sort(pcows(:,:,1));
h = plotBarStackGroups(pcows(I2,:,:),labels(I2))
hold on
plot([h(1).XData(1)-1 h(1).XData(end)+1],[0.5 0.5],'--')
plot([h(1).XData(1)-1 h(1).XData(end)+1],[proportion proportion],'--')
legend("Group A","Group B")
title("Proportion of membership group A/B for each cow")

%% Date period ?

%%

%% Date weekend ?

nA = sum(isweekend(groupA.date));
nB = sum(isweekend(groupB.date));
pA = nA/size(groupA,1);
pB = nB/size(groupB,1);
disp([num2str(pA*100) '% of cow/day in group A are weekends'])
disp([num2str(pB*100) '% of cow/day in group A are weekends'])
%%
weekends = tab(isweekend(tab.date),(1:2));
weekendsA = intersect(weekends,groupA(:,(1:2)));
weekendsB = intersect(weekends,groupB(:,(1:2)));
pA = size(weekendsA,1)/size(weekends,1);
pB = size(weekendsB,1)/size(weekends,1);
disp([num2str(pA*100) '% of weekends are in group A'])
disp([num2str(pB*100) '% of weekends are in group B'])
%% Daylight ?
alldays = unique(tab.date);
nalldays = size(alldays,1);

s = zeros(nalldays,1);
for i = 1:nalldays
    s(i) = sum(tab.date==alldays(i));
end

alldays = alldays(s>=10);
nalldays = size(alldays,1);

pdays = zeros(nalldays,1,2);
labels = cell(nalldays,1);
for iday = 1:nalldays
    day = alldays(iday);
    labels{iday} = iday;
    nA = sum(groupA.date==day);
    nB = sum(groupB.date==day);
    pA = nA/(nA+nB);
    pB = nB/(nA+nB);
    pdays(iday,1,:) = [pA,pB];
end
h = plotBarStackGroups(pdays)
h(2).FaceColor = [1 1 1];
h(2).EdgeColor = [1 1 1];
h(1).FaceColor = [0 0 0];
ax = gca;

title("Proportion of membership group A/B for each date")
hold on
plot([h(1).XData(1) h(1).XData(end)],[0.5 0.5],'--')
plot([h(1).XData(1) h(1).XData(end)],[proportion proportion],'--')
plot([78 78],[0 1],'--r')
plot([124 124],[0 1],'--r')
ax.XTick = [1 39 78 124 149];
ax.XTickLabel = {'26 Oct','07 Dec','18 Jan','16 Mar','17 Apr'};
legend("Group A","Group B" )
%%
