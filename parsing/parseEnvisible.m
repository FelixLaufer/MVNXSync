function EnvisibleData = parseEnvisible(envisibleFile)
disp(['Parsing ' envisibleFile '...']);

data = dlmread(envisibleFile, '\t', 17, 0); 

EnvisibleData.sampleRate = 100;
EnvisibleData.AngularVelocity = data(:, 14:16);
EnvisibleData.Channels = data(:, 1:8);

disp('done!');
end