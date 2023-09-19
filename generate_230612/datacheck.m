clear all
%% Lecture donnees
filename = "Data/dataset1-1.csv";
data = readtable(filename,'TreatAsMissing','NA');
filename = "Data/mainActivity_filtered.csv";
rawdata = readtable(filename,'TreatAsMissing','NA'); % Donnees brutes
%%
cows = unique(data.cow);
cowlist= [4];
E = zeros(length(cowlist),12);
eating_hour = zeros(1,length(cowlist));
k=0;
for icow = cowlist
    k=k+1;
    cow = cows(icow);
    Dcow_hour = data(ismember(data.cow,cow),:);
    Dcow_hour.date = datetime(Dcow_hour.date,'InputFormat','dd.MM.yyyy');
    Dcow_minute = rawdata(ismember(rawdata.CowId,cow),:);
    Dcow_minute.date = datetime(Dcow_minute.date,'InputFormat','dd.MM.yyyy');
    dates = unique(Dcow_minute.date);
    isvalid = @(date)(sum(isnan(Dcow_minute(ismember(Dcow_minute.date,date),:).mainActivity)) < 1 ...
        && height(Dcow_hour(ismember(Dcow_hour.date,date),:)) == 24);
    validdates = dates(arrayfun(isvalid,dates));
    Dcow_hour = Dcow_hour(ismember(Dcow_hour.date,validdates),:);
    Dcow_minute = Dcow_minute(ismember(Dcow_minute.date,validdates),:);
    %%
    oestrus = sum(Dcow_hour.oestrus==1)/height(Dcow_hour);
    calving = sum(Dcow_hour.calving==1)/height(Dcow_hour);
    lameness = sum(Dcow_hour.lameness==1)/height(Dcow_hour);
    mastitis = sum(Dcow_hour.mastitis==1)/height(Dcow_hour);
    LPS = sum(Dcow_hour.LPS==1)/height(Dcow_hour);
    acidosis = sum(Dcow_hour.acidosis==1)/height(Dcow_hour);
    other_disease = sum(Dcow_hour.other_disease==1)/height(Dcow_hour);
    accidents = sum(Dcow_hour.accidents==1)/height(Dcow_hour);
    disturbance = sum(Dcow_hour.disturbance==1)/height(Dcow_hour);
    mixing = sum(Dcow_hour.mixing==1)/height(Dcow_hour);
    management_changes = sum(Dcow_hour.management_changes==1)/height(Dcow_hour);
    OK = sum(Dcow_hour.OK==1)/height(Dcow_hour);
    E(k,:)=[oestrus,calving,lameness,mastitis,LPS,acidosis,other_disease,accidents,disturbance,mixing,management_changes,OK];
    eating = reshape(Dcow_hour.EAT,24,height(Dcow_hour)/24);
    eating_hour(k)=mean(sum(eating)/3600);
  
    %%
    ndates = length(validdates);
    b = zeros(ndates,24);
    c = reshape(Dcow_hour.EAT,24,height(Dcow_hour)/24)';
    for idate = 1:ndates
        date = validdates(idate);
        Dcow_minute_date = Dcow_minute(ismember(Dcow_minute.date,date),:);
        for ihour = 0:23
            b(idate,ihour+1) = sum(Dcow_minute_date(60*ihour+1:60*ihour+60,:).mainActivity>=4);
        end
    end
    b_inf = 20*b;
    b_sup = 30*b+1800;
    bres = b_inf <= c & c <= b_sup;
end
%%
