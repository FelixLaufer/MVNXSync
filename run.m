clear all
clearvars
clc

path = 'data';
file = 'Test'; % Unzip /data/Test.zip

pathFile = [path '/' file];

MVNXData = parseMVNX(strcat(pathFile, '.mvnx'));
envisibleLeftData = parseEnvisible(strcat(pathFile, '_left.envisible'));
envisibleRightData = parseEnvisible(strcat(pathFile, '_right.envisible'));

Data = syncEnvisible2MVNX(MVNXData, envisibleLeftData, envisibleRightData, 1000);

save(strcat(file, '.mat'), 'Data');
