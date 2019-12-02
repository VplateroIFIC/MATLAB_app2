%% PROPERTIES FOR CAMERA CLASS: GANTRY SETUP %%

% this script generate the properties needed for the CAMERA class for the Gantry Setup. It is launched in the constructor of the class. 

ROIPos=[0 0 2048 1536];     % resolution of the camera
ImageOutput='C:\Users\Pablo\Desktop\output images Gantry\';  % folder to save the images    
calibration=3.62483;  %um/pixel calibration of the camera
videoAdaptor='gentl';    % Matlab video adaptor used
triggerConfig='hardware';
ExposureAuto='Continuous';
GainAuto='Continuous';