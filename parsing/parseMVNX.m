function MVNXData = parseMVNX(mvnxFile)
disp(['Parsing ' mvnxFile '...']);

% Parse XML into struct
xmlStruct = XML2Struct(mvnxFile);

% Sample rate
MVNXData.sampleRate = str2double(xmlStruct.mvnx.subject.Attributes.frameRate);

% Segments
segments = xmlStruct.mvnx.subject.segments.segment;
MVNXData.segments(1:numel(segments)) = struct('id',[], 'name', [], 'points', []);
for s = 1:numel(segments)
   points(1:numel(segments{s}.points.point)) = struct('id', [], 'name', [], 'pos', []);
   for p = 1:numel(segments{s}.points.point)
       points(p) = struct('id', p, 'name', segments{s}.points.point{p}.Attributes.label, 'pos', textscan(segments{s}.points.point{p}.pos_b.Text, '%f', 'Delimiter', ' '));
   end
   MVNXData.segments(s) = struct('id', s, 'name', segments{s}.Attributes.label, 'points', points);
end

% Sensors
sensors = xmlStruct.mvnx.subject.sensors.sensor;
MVNXData.sensors(1:numel(sensors)) = struct('id',[], 'name', []);
for s = 1:numel(sensors)
   MVNXData.sensors(s) = struct('id', s, 'name', sensors{s}.Attributes.label); 
end

% Joints
joints = xmlStruct.mvnx.subject.joints.joint;
MVNXData.joints(1:numel(joints)) = struct('id',[], 'name', [], 'connection', []);
for j = 1:numel(joints)
    connection(1:2) = struct('segment', [], 'point', []);
    con1 = strsplit(joints{j}.connector1.Text, '/');
    connection(1) = struct('segment', con1(1), 'point', con1(2));
    con2 = strsplit(joints{j}.connector2.Text, '/');
    connection(2) = struct('segment', con2(1), 'point', con2(2));
	MVNXData.joints(j) = struct('id', j, 'name', joints{j}.Attributes.label, 'connection', connection);
end

% Frames
frames = xmlStruct.mvnx.subject.frames.frame;
framesTmp(1:numel(frames)-3) = struct('time', [], 'orientation', [], 'position', [], 'velocity', [], 'acceleration', [], 'angularVelocity', [] , 'angularAcceleration', [], 'sensorAcceleration', [], 'sensorAngularVelocity', [], 'sensorMagneticField', [], 'sensorOrientation', [], 'jointAngle', [], 'jointAngleXZY', [], 'centerOfMass', []);
for f = 1:numel(frames)
    if (strcmp(frames{f}.Attributes.type, 'normal'))       
        framesTmp(f-3) = struct('time', str2double(frames{f}.Attributes.time), 'orientation', textscan(frames{f}.orientation.Text, '%f', 'Delimiter', ' '), 'position', textscan(frames{f}.position.Text, '%f', 'Delimiter', ' '), 'velocity', textscan(frames{f}.velocity.Text, '%f', 'Delimiter', ' '), 'acceleration', textscan(frames{f}.acceleration.Text, '%f', 'Delimiter', ' '), 'angularVelocity', textscan(frames{f}.angularVelocity.Text, '%f', 'Delimiter', ' '), 'angularAcceleration', textscan(frames{f}.angularAcceleration.Text, '%f', 'Delimiter', ' '), 'sensorAcceleration', textscan(frames{f}.sensorAcceleration.Text, '%f', 'Delimiter', ' '), 'sensorAngularVelocity', textscan(frames{f}.sensorAngularVelocity.Text, '%f', 'Delimiter', ' '), 'sensorMagneticField', textscan(frames{f}.sensorMagneticField.Text, '%f', 'Delimiter', ' '), 'sensorOrientation', textscan(frames{f}.sensorOrientation.Text, '%f', 'Delimiter', ' '), 'jointAngle', textscan(frames{f}.jointAngle.Text, '%f', 'Delimiter', ' '), 'jointAngleXZY', textscan(frames{f}.jointAngleXZY.Text, '%f', 'Delimiter', ' '), 'centerOfMass', textscan(frames{f}.centerOfMass.Text, '%f', 'Delimiter', ' '));      
    end
end

% Frame matrices
nF = numel(framesTmp);
MVNXData.time = zeros(nF, 1);
MVNXData.orientation = zeros(nF, numel(framesTmp(1).orientation));
MVNXData.position = zeros(nF, numel(framesTmp(1).position));
MVNXData.velocity = zeros(nF, numel(framesTmp(1).velocity));
MVNXData.acceleration = zeros(nF, numel(framesTmp(1).acceleration));
MVNXData.angularVelocity = zeros(nF, numel(framesTmp(1).angularVelocity));
MVNXData.angularAcceleration = zeros(nF, numel(framesTmp(1).angularAcceleration));
MVNXData.sensorAcceleration = zeros(nF, numel(framesTmp(1).sensorAcceleration));
MVNXData.sensorAngularVelocity = zeros(nF, numel(framesTmp(1).sensorAngularVelocity));
MVNXData.sensorMagneticField = zeros(nF, numel(framesTmp(1).sensorMagneticField));
MVNXData.sensorOrientation = zeros(nF, numel(framesTmp(1).sensorOrientation));
MVNXData.jointAngle = zeros(nF, numel(framesTmp(1).jointAngle));
MVNXData.jointAngleXZY = zeros(nF, numel(framesTmp(1).jointAngleXZY));
MVNXData.centerOfMass = zeros(nF, numel(framesTmp(1).centerOfMass));

t = 0;
for f = 1:nF
    MVNXData.time(f) = t;
	t = t + 1.0 / MVNXData.sampleRate;
    MVNXData.orientation(f,:) = framesTmp(f).orientation;
    MVNXData.position(f,:) = framesTmp(f).position;
    MVNXData.velocity(f,:) = framesTmp(f).velocity;
    MVNXData.acceleration(f,:) = framesTmp(f).acceleration;
    MVNXData.angularVelocity(f,:) = framesTmp(f).angularVelocity;
    MVNXData.angularAcceleration(f,:) = framesTmp(f).angularAcceleration;
    MVNXData.sensorAcceleration(f,:) = framesTmp(f).sensorAcceleration;
    MVNXData.sensorAngularVelocity(f,:) = framesTmp(f).sensorAngularVelocity;
    MVNXData.sensorMagneticField(f,:) = framesTmp(f).sensorMagneticField;
    MVNXData.sensorOrientation(f,:) =  framesTmp(f).sensorOrientation;
    MVNXData.jointAngle(f,:) = framesTmp(f).jointAngle;
    MVNXData.jointAngleXZY(f,:) = framesTmp(f).jointAngleXZY;
    MVNXData.centerOfMass(f,:) = framesTmp(f).centerOfMass;
end

disp('done!');
end
