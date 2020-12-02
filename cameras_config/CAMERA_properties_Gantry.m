%% PROPERTIES FOR CAMERA CLASS: GANTRY SETUP %%

% this script generate the properties needed for the CAMERA class for the Gantry Setup. It is launched in the constructor of the class. 

resolution=[2048,1536];
ROIwidth=resolution(1)/2;
ROIheight=resolution(2)/2;
center=resolution/2;
ROIPos=[0 0 2048 1536];     % resolution of the camera
% ROIPos=[ resolution(1)/4 resolution(2)/4  ROIwidth ROIheight];     % resolution of the camera [ XOffset YOffset Width Height]
ImageOutput='C:\Users\Pablo\Desktop\output_images_results_Gantry\';  % folder to save the images    
% calibration=1.8947;  %um/pixel calibration of the camera
% calibration = 1.7319;  % Sento calculation
calibration = 1.7400; %Last Pablo calculation
videoAdaptor='gentl';    % Matlab video adaptor used
triggerConfig='hardware';
ExposureAuto='Continuous';
GainAuto='Continuous';
