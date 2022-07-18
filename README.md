# MVNXSync
Proper time series synchronization of different measurement systems is always an issue. In this case, both systems (Xsens Awinda and Envisible/IEE smart insoles) werhe equipped with inertial measurement units.
The fact, that two IMUs at the same segment should measure highy correlated gyrsocope norms, can be exploited to synchronize the systems using cross-correlation.
This script parses and synchronizes Xsens MVNX data (IMU data + tracked skeleton kinematics) of a wireless Xsens Awinda system and smart insole data (IMU Data + pressure).
Should be easily adaptable for any time series containing gyroscope measurements (as long as IMUs are internally synced with the other sensors of interest).
