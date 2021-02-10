%This is a executable file to keep track of what we did for processing the
%data

load('Data\FirstLaserSensorPoints.mat');
load('Data\MitutoyoSensorPoints.mat');      

%The data we have loaded here is already processed data. This come from
%..\Measuring\Results\15Velocity200Lines28minutes.mat and from
%..\Measuring\Results\mitutoyoMeasurements respectively, and processed with
%SensorPointsGetter to extract the points that belonged to the silicon
%sensor

%Obtain the COM, the inertia matrix and the points centered
%at COM.

[LaserCOM,LaserI,LaserFromCOM]=InertiaTensorAndCOM(LaserSensorPoints);
[MitutoyoCOM,MitutoyoI,MitutoyoFromCOM]=InertiaTensorAndCOM(MitutoyoSensorPoints);

%Orient the points (first sort the eigenvectors of the inertia matrix so
%that the axis coincide and the postmultiply by the eigenvectors matrix)

[V,~] = eig(LaserI);
V=sortrows(V','descend')';
LaserOrientedPoints = LaserFromCOM*V;
[V,~] = eig(MitutoyoI);
V=sortrows(V','descend')';
MitutoyoOrientedPoints = MitutoyoFromCOM*V;

%Interpolate the Mitutoyo's data to the Laser grid and substract both
%surfaces to obtain the difference and some interesting parameters
%(standard deviation and the fraction of the points under it 

MitutoyoZAsLaserGrid = griddata(MitutoyoOrientedPoints(:,1),MitutoyoOrientedPoints(:,2),MitutoyoOrientedPoints(:,3),LaserOrientedPoints(:,1),LaserOrientedPoints(:,2),'v4');
Difference = [LaserOrientedPoints(:,1),LaserOrientedPoints(:,2),LaserOrientedPoints(:,3)-MitutoyoZAsLaserGrid];
LaserStandardDeviation = std(Difference(:,3));
FractionBelowStd = sum(Difference(:,3)<LaserStandardDeviation)/size(Difference,1);

%Stablish thresholds and make cuts to get rid of the noise

ZTopTolerance = 0.005;
ZBottomTolerance = -0.0062;
DifNoNoise = GetRidOfNoise(Difference,ZTopTolerance,ZBottomTolerance);
LaserNoNoiseStd = std(DifNoNoise(:,3));
FractionNoNoiseBelowStd = sum(DifNoNoise(:,3)<LaserNoNoiseStd)/size(DifNoNoise,1);

LaserNoNoise = SumScatteredSurfaces(MitutoyoOrientedPoints,DifNoNoise);

LaserNoNoiseFlatness = flatness_conhull(LaserNoNoise);