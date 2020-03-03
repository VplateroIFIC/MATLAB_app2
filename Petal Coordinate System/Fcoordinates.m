% Position of the F fiducials with respect to the petal coordinate system %
%
% The petal coordinate system is given by PETAL_SensorFiducial file (folder petalSensorFiducial) Origin in the lowest petal fiducial. Xaxis
% 12.6 degrees from the line that connect 2 petal fiducials (roughly a line which slice the petal by the center) 
%
% The position of the F fiducials given by the top left corner of the F mark (PETAL_SensorFiducial file)


nSensors=9;
nFiducialsPerSensor=5;
Fmark=cell(nSensors,nFiducialsPerSensor);


% R0 %
Fmark{1,1}=[0.5443,36.1266];
Fmark{1,2}=[104.4131,48.1923];
Fmark{1,3}=[104.2903,-49.4147];
Fmark{1,4}=[0.076,-40.7815];
Fmark{1,5}='R0';

% R1 %
Fmark{2,1}=[105.3628,46.4297];
Fmark{2,2}=[189.8058,56.2472];
Fmark{2,3}=[189.5841,-58.4561];
Fmark{2,4}=[104.5605,-51.4292];
Fmark{2,5}='R1';

% R2 %
Fmark{3,1}=[190.715,54.902];
Fmark{3,2}=[252.5496,62.0955];
Fmark{3,3}=[252.2384,-65.1963];
Fmark{3,4}=[190.1984,-60.0459];
Fmark{3,5}='R2';

% R3 S0 %
Fmark{4,1}=[256.3445,-3.7285];
Fmark{4,2}=[373.8951,-1.9344];
Fmark{4,3}=[369.9648,-77.0068];
Fmark{4,4}=[252.8036,-67.2455];
Fmark{4,5}='R3S0';

% R3 S1 %
Fmark{5,1}=[253.4761,60.5627];
Fmark{5,2}=[370.2486,74.1834];
Fmark{5,3}=[373.897,-0.9033];
Fmark{5,4}=[256.3484,-2.981];
Fmark{5,5}='R3S1';

% R4 S0 %
Fmark{6,1}=[374.6615,-4.0646];
Fmark{6,2}=[484.4853,-2.3673];
Fmark{6,3}=[479.9477,-88.5923];
Fmark{6,4}=[370.489,-79.4569];
Fmark{6,5}='R4S0';

% R4 S1 %
Fmark{7,1}=[371.2292,72.1035];
Fmark{7,2}=[480.3247,84.8443];
Fmark{7,3}=[484.4874,-1.3996];
Fmark{7,4}=[374.6651,-3.326];
Fmark{7,5}='R4S1';

% R5 S0 %
Fmark{8,1}=[485.2525,-4.362];
Fmark{8,2}=[586.2386,-2.7881];
Fmark{8,3}=[581.1372,-99.2994];
Fmark{8,4}=[480.4879,-90.8867];
Fmark{8,5}='R5S0';

% R5 S1 %
Fmark{9,1}=[481.2886,82.9384];
Fmark{9,2}=[581.6035,94.6673];
Fmark{9,3}=[586.2407,-1.8874];
Fmark{9,4}=[485.2558,-3.6265];
Fmark{9,5}='R5S1';
