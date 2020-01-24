%% PROPERTIES FOR CAMERA CLASS: HIGH RESOLUTIOP OWIS SETUP %%

% this script generate the properties needed for the CAMERA class for the OWIS Setup. It is launched in the constructor of the class. 


resolution=[1920 1024];    % resolution of the camera
ROIwidth=resolution(1)/2;
ROIheight=resolution(1)/2;
center=resolution/2;
% ROIPos=[0 0 2048 1536];     % resolution of the camera
ROIPos=[center(1)-ROIwidth/2 center(2)-ROIheight/2   ROIheight ROIwidth]; 

ImageOutput='D:\Gantry\cernbox\GANTRY-IFIC\Pictures_general\F_images_newLighting\';  % folder to save the images    
calibration=3.62483;  %um/pixel calibration of the camera
videoAdaptor='gentl';    % Matlab video adaptor used
triggerConfig='hardware';
ExposureAuto='Continuous';
GainAuto='Continuous';