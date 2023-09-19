filename = "../Data/dataset1-1.csv";
rawdata1 = readtable(filename);
Y1 = rawdata1.ACTIVITY_LEVEL;
date = rawdata1.date;
hour = rawdata1.hour;
%%
cow = 6601;
dir = 'Data/Dataprocess/';
filename = [dir num2str(cow) '.mat'];
load(filename);
%%
plot(0:23,Y1(14+24:37+24))
hold on
plot(0:23,ar(data_cow.V(:,2)))