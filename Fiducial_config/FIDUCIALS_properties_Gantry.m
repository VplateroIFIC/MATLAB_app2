%% PROPERTIES FOR FIDUCIALS CLASS: GANTRY SETUP %%

% this script generate the properties needed for the FIDUCIALS class for the Gantry Setup. It is launched in the constructor of the class. 

% matchSURF

binaryFilterKernel=9;
adaptativeThreshold=31;
SURF_Extended=false;   %false 
SURF_HessianThreshold=300;   %300 to 500 (the larger, the less keypoints we get)
SURF_NOctaveLayers=2;       %2
SURF_NOctaves=10;    %4  increase for big features, decrease for small features
SURF_Upright=false;   % ignore the rotation check for each feature
knn_match_number=2;
filter_ratio=0.8;   %minimum distance between matches
filter_size=50;   % minimum size for the feature

% prepareImage

sizeParticles=5000;

% FROIbuilder

pixelAreaF=17000;  % nominal value of the F Area in pixels in IFIC setup
deltaArea=4000;
perimeterF=900;   % nominal value of the F Perimeter in pixels in IFIC setup
deltaPerimeter=150;

% ROIbuilder

ROIsize=500;

% FmatchSURF

FtemplatePath=('templates\F_gantry.jpg');
cornerF=[76.0043,240.0685];
cameraRotationOffset=0.018844464640319;

% CirclesFinder

camCalibration=1.74; %p/um % calibration fiducial
% camCalibration=3.5739; %p/um % sensor CNM
% camCalibration=3.5739; %p/um % sensor CNM


binaryFilterKernel_circles=81;

% CalibrationFiducialROIBuilder

ROIsizeCalib=150; % size of the ROI (um)
diameter=22;
deltaDiam=2.5;
NominalShortDistance=49;   % distance between consecutive circles in um
NominalLongDistance=69;    % Distance between opposite circles
binaryFilterKernel_calibrationPlate=9;

% calibrationFidFinder

binaryFilterKernel_calibration=5;
minDist=50;

% Calibration rotation camera (rad)

angleCamera=0.019374900026389;