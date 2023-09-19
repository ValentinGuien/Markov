clear all
%%
filename = "../Data/dataset1-1.csv";
data = readtable(filename,'TreatAsMissing','NA');
cows = unique(data.cow);
ncows = length(cows);

data_ar_healthy = cell(ncows,1);
%%

%%
rules = struct;
rules.oestrus = [-1;1];
rules.calving = [-2;1];
rules.lameness = [-2;1];
rules.mastitis = [-2;1];
rules.LPS = [0;1];
rules.acidosis = [-1;2];
rules.other_disease = [-2;1];
%rules.accidents = [NaN,NaN,NaN];
rules.disturbance = [0;1];
rules.mixing = [0;1];
%%
data.date = datetime(data.date,'InputFormat','yyyy-MM-dd');
%% DEFINE FUZZY DAYS
abn_data = data(data.OK~=1,:);
fuzzy_data = getfuzzytable(abn_data,rules);
%% HEALTHY STATE
for icow = 1:ncows
  cow = cows(icow);
  Dcow = data(ismember(data.cow,cow),:); 
  Dcowfuzzy = fuzzy_data(ismember(fuzzy_data.cow,cow),:);
  Dcowabn = abn_data(ismember(abn_data.cow,cow),:);
  dates = unique(Dcow.date);
  isvalid = @(date)(height(Dcow(ismember(Dcow.date,date),:)) == 24);
  validdates = dates(arrayfun(isvalid,dates)); % Pas de donnees manquante sur les 24 heures
  validdates = setdiff(validdates,Dcowabn.date); % Pas de donnees de vache non saines
  validdates = setdiff(validdates,Dcowfuzzy.date); % Pas de donnees floues
  Dcowfiltered = Dcow(ismember(Dcow.date,validdates),:);
  AR_healthy = reshape(Dcowfiltered.ACTIVITY_LEVEL,24,length(validdates));
  

  data_ar_healthy{icow}.cow = cow;
  data_ar_healthy{icow}.AR_healthy = AR_healthy;
  data_ar_healthy{icow}.validdates = validdates;
  data_ar_healthy{icow}.rules = rules;
end

%%
force=1

dirwrite = 'Dataprocess/AR/Healthy/';
if not(exist(dirwrite))
    mkdir(dirwrite);
end
for i=1:ncows
    filenamewrite = [dirwrite num2str(data_ar_healthy{i}.cow) '.mat'];
    if not(exist(filenamewrite)) || force==1
        ar_cow_healthy = data_ar_healthy{i};
        save(filenamewrite,'ar_cow_healthy','-v7.3');
    else
        disp(['File already exist'])
    end
end
%% UNHEALTHY COWS
cows_uh = unique(abn_data.cow);
ncows_uh = length(cows_uh);
abn_states = ["oestrus","calving",...
        "lameness","mastitis","LPS","other_disease",...
        "accidents","mixing"];
abn_states_num = [8:12,14:15,17];
nabnstates = length(abn_states);
data_ar_uh = cell(nabnstates,1);

for i=1:nabnstates
    state = abn_states(i);
    numstate = abn_states_num(i);
    Dstate = abn_data(table2array(abn_data(:,abn_data.Properties.VariableNames{numstate}))==1,:);
    AR_uh = reshape(Dstate.ACTIVITY_LEVEL,24,height(Dstate)/24);
    
    data_ar_uh{i}.state = state;
    data_ar_uh{i}.AR_uh = AR_uh;
end
%%
force=1

dirwrite = 'Dataprocess/AR/Unhealthy/';
if not(exist(dirwrite))
    mkdir(dirwrite);
end
for i=1:nabnstates
    filenamewrite = [dirwrite char(data_ar_uh{i}.state) '.mat'];
    if not(exist(filenamewrite)) || force==1
        ar_uh = data_ar_uh{i};
        save(filenamewrite,'ar_uh','-v7.3');
    else
        disp(['File already exist'])
    end
end