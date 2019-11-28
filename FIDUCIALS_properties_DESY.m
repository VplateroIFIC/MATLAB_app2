%% PROPERTIES FOR FIDUCIALS CLASS: GANTRY SETUP %%

% this script generate the .mat file with all the properties needed for the FIDUCIALS class for the case of the Gantry. The class will load the .mat file in the
% constructor

% matchSURF

binaryFilterKernel=9;
adaptativeThreshold=41;
SURF_Extended=false;   %false 
SURF_HessianThreshold=300;   %300 to 500 (the larger, the less keypoints we get)
SURF_NOctaveLayers=2;       %2
SURF_NOctaves=10;    %4  increase for big features, decrease for small features
SURF_Upright=false;   % ignore the rotation check for each feature
knn_match_number=2;
filter_ratio=0.8;   %minimum distance between matches
filter_size=50;   % minimum size for the feature

% prepareImage

sizeParticles=9500;

% FROIbuilder

pixelAreaF=43765;  % aprox value of the F Area in pixels in DESY setup
deltaArea=5000;
perimeterF=1642.1;   % aprox value of the F Perimeter in pixels in DESY setup
deltaPerimeter=500;

% ROIbuilder

ROIsize=800;

% FmatchSURF

FtemplatePath=('templates\F_DESY.png');

% CirclesFinder

camCalibration=2.6698; % pixel/um 


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