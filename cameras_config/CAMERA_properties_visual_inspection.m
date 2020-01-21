%% PROPERTIES FOR CAMERA CLASS: VISUAL INSPECTION %%

% this script generate the properties needed for the CAMERA class for the visual inspection cameras. It is launched in the constructor of the class. 


ROIPos=[0 0 1920 1200];     % resolution of the camera
ImageOutput='C:\Users\leon0\Desktop\test_output\';  % folder to save the images    
calibration=3.62483;  %um/pixel calibration of the camera
videoAdaptor='gentl';    % Matlab video adaptor used
triggerConfig='hardware';
ExposureAuto='Continuous';
GainAuto='Continuous';