%% PROPERTIES FOR CAMERA CLASS: GANTRY SETUP %%

% this script generate the properties needed for the CAMERA class for the Gantry Setup. It is launched in the constructor of the class. 

ReturnedColor='grayscale'; % we take gayscale images from camera
ROIPos=[0 0 3856 2764];     % resolution of the camera
ExposureM = 'auto';         % auto tuning for the exposure
ImageOutput='D:\Gantry\cernbox\GANTRY-IFIC\Pictures_general\F_images_newLighting\';  % folder to save the images    
calibration=3.62483;  %um/pixel calibration of the camera
trigger='manual';       % manual trigger for taking images
videoAdaptor='winvideo';    % Matlab video adaptor used