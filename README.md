# MVNXSync
Proper post-synchronization of different (inertial) measurement systems without any hardware or software sync capability provided is often an issue. In our scenario, both systems (Xsens Awinda and Envisible/IEE smart insoles) were equipped with IMUs and therefore gyroscopes.
In this cases, the fact that two sensors attachted to the same segment should measure very similar gyrsocope norms, can be exploited in order to align their measurements using gyro norm cross-correlation.
This script parses and synchronizes Xsens MVNX data (IMU data + tracked skeleton kinematics) of a wireless Xsens Awinda system and smart insole data (IMU Data + pressure).
Should be easily adaptable for different systems and any time series containing gyroscope measurements (as long as measurements are synced internally per device).
