function Data = syncEnvisible2MVNX(MVNXData, EnvisibleDataLeft, EnvisibleDataRight, plotFrames)
disp('Synchronizing Envisible data against MVNX data...');

% Get gyro data from feet IMUs
xsensGyrLeft = MVNXData.sensorAngularVelocity(:, 49:51);
xsensGyrRight = MVNXData.sensorAngularVelocity(:, 40:42);

% Convert IMU angular velocity into deg/s
xsensGyrLeft = rad2deg(xsensGyrLeft);
xsensGyrRight = rad2deg(xsensGyrRight);

% Allocate space
xsensGyrNormLeft = zeros(size(xsensGyrLeft,1),1);
xsensGyrNormRight = zeros(size(xsensGyrRight,1),1);

% Calculate norm of IMU gyro data
for j = 1:size(xsensGyrNormLeft,1)
    xsensGyrNormLeft(j) = norm(xsensGyrLeft(j, :));
    xsensGyrNormRight(j) = norm(xsensGyrRight(j, :));
end

% Allocate space
envisibleNormLeft = zeros(size(EnvisibleDataLeft.AngularVelocity,1),1);
envisibleNormRight = zeros(size(EnvisibleDataRight.AngularVelocity,1),1);

% Calculate norm of Envisible gyro data
for j = 1:size(envisibleNormLeft,1)
    envisibleNormLeft(j) = norm(EnvisibleDataLeft.AngularVelocity(j, :));
end
for j = 1:size(envisibleNormRight,1)
    envisibleNormRight(j) = norm(EnvisibleDataRight.AngularVelocity (j, :));
end

% Left lag
xsensGyrNormLeft = interp1(1:length(xsensGyrNormLeft), xsensGyrNormLeft, linspace(1, length(xsensGyrNormLeft), length(xsensGyrNormLeft) * (1000/MVNXData.sampleRate)));
envisibleNormLeft = interp1(1:length(envisibleNormLeft), envisibleNormLeft, linspace(1, length(envisibleNormLeft), length(envisibleNormLeft)*(1000/EnvisibleDataLeft.sampleRate)));
[acor, lag] = xcorr(xsensGyrNormLeft, envisibleNormLeft);
[~, I] = max(abs(acor));
left_lagDiff = lag(I);

% Right lag
xsensGyrNormRight = interp1(1:length(xsensGyrNormRight), xsensGyrNormRight, linspace(1, length(xsensGyrNormRight), length(xsensGyrNormRight) * (1000/MVNXData.sampleRate)));
envisibleNormRight = interp1(1:length(envisibleNormRight), envisibleNormRight, linspace(1, length(envisibleNormRight), length(envisibleNormRight)*(1000/EnvisibleDataRight.sampleRate)));
[acor, lag] = xcorr(xsensGyrNormRight, envisibleNormRight);
[~, I] = max(abs(acor));
right_lagDiff = lag(I);

if abs(abs(left_lagDiff)-abs(right_lagDiff)) >= 100
    if abs(left_lagDiff) < abs(right_lagDiff)
        right_lagDiff = left_lagDiff;
    else
        left_lagDiff = right_lagDiff;
    end
end

% Lag correction
envisibleNormLeft = envisibleNormLeft(-left_lagDiff+1:end);
envisibleNormRight = envisibleNormRight(-right_lagDiff+1:end);
envisibleNormLeft = interp1(envisibleNormLeft, linspace(1,length(envisibleNormLeft),length(envisibleNormLeft) * (MVNXData.sampleRate/1000)));
envisibleNormRight = interp1(envisibleNormRight, linspace(1,length(envisibleNormRight),length(envisibleNormRight) * (MVNXData.sampleRate/1000)));

% Downsample Xsens norm back to MVNXData.sampleRate
xsensGyrNormRight = interp1(1:length(xsensGyrNormRight), xsensGyrNormRight, linspace(1, length(xsensGyrNormRight), length(xsensGyrNormRight) * (MVNXData.sampleRate/1000)));
xsensGyrNormLeft = interp1(1:length(xsensGyrNormLeft), xsensGyrNormLeft, linspace(1, length(xsensGyrNormLeft), length(xsensGyrNormLeft) * (MVNXData.sampleRate/1000)));

% Plot lag correction 
figure,
subplot(2,1,2)
plot(xsensGyrNormLeft(1:plotFrames))
hold on 
plot(envisibleNormLeft(1:plotFrames))
legend('IMU', 'Insole');
title('Left');
subplot(2, 1, 1)
plot(xsensGyrNormRight(1:plotFrames))
hold on 
plot(envisibleNormRight(1:plotFrames))
legend('IMU', 'Insole');
title('Right');

envisiblePressureLeft = EnvisibleDataLeft.Channels;
envisiblePressureRight = EnvisibleDataRight.Channels;

% Sample up to 1000Hz
envisiblePressureLeft = interp1(envisiblePressureLeft, linspace(1,length(envisiblePressureLeft),length(envisiblePressureLeft) * (1000/EnvisibleDataLeft.sampleRate)));
envisiblePressureRight = interp1(envisiblePressureRight, linspace(1,length(envisiblePressureRight),length(envisiblePressureRight) * (1000/EnvisibleDataRight.sampleRate)));

% Synchronize with lag
envisiblePressureLeft = envisiblePressureLeft(-left_lagDiff+1:end, :);
envisiblePressureRight = envisiblePressureRight(-right_lagDiff+1:end, :);

% Sample down to MVNXData.sampleRate
envisiblePressureLeft = interp1(envisiblePressureLeft, linspace(1,length(envisiblePressureLeft),length(envisiblePressureLeft) * (MVNXData.sampleRate/1000)));
envisiblePressureRight = interp1(envisiblePressureRight, linspace(1,length(envisiblePressureRight),length(envisiblePressureRight) * (MVNXData.sampleRate/1000)));
if size(envisiblePressureLeft,1) < size(envisiblePressureRight,1)
    envisiblePressureRight = envisiblePressureRight(1:size(envisiblePressureLeft,1), :);
elseif size(envisiblePressureLeft,1) > size(envisiblePressureRight,1)
    envisiblePressureLeft = envisiblePressureLeft(1:size(envisiblePressureRight,1), :);
end

% Cut to the same length
nF = size(MVNXData.time,1);
envisiblePressureLeftTmp = zeros(nF,8);
envisiblePressureRightTmp = zeros(nF,8);
for f = 1:min(nF, min(length(envisiblePressureLeft), length(envisiblePressureRight)))
	envisiblePressureLeftTmp(f,:) = envisiblePressureLeft(f,:);
	envisiblePressureRightTmp(f,:) = envisiblePressureRight(f,:);
end

Data.MVNX = MVNXData;
Data.Envisible.sampleRate = EnvisibleDataLeft.sampleRate;
Data.Envisible.time = MVNXData.time;
Data.Envisible.leftPressures = envisiblePressureLeftTmp;
Data.Envisible.rightPressures = envisiblePressureRightTmp;

disp('done!');
end