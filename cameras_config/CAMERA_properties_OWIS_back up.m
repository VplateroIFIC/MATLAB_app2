%% PROPERTIES FOR CAMERA CLASS: HIGH RESOLUTIOP OWIS SETUP %%

% this script generate the properties needed for the CAMERA class for the OWIS Setup. It is launched in the constructor of the class. 


ROIPos=[0 0 2048 1536];     % resolution of the camera
ImageOutput='D:\Gantry\cernbox\GANTRY-IFIC\Pictures_general\F_images_newLighting\';  % folder to save the images    
calibration=3.62483;  %um/pixel calibration of the camera
videoAdaptor='gentl';    % Matlab video adaptor used
triggerConfig='hardware';
ExposureAuto='Continuous';
GainAuto='Continuous';