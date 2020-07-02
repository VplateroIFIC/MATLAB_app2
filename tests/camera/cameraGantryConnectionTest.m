%%%%% CAMERA EXAMPLE %%%%%
clc
clear all

% creating camera object %
imaqreset;
dev_info = imaqhwinfo('winvideo',1);
cam = videoinput('winvideo',1);

% preview of the camera %
preview(cam)
% closepreview(vid)

% properties of camera object %

get(cam);
set(cam); % what I can change
src = getselectedsource(cam);

% setting the properties of the object %

cam.ReturnedColorSpace='grayscale';
cam.ROIPosition=[0 0 3856 2764];
cam.ReturnedColorSpace=grayscale;
src.ExposureMode = 'manual';
% src.Exposure = exp;

% setting properties of the logging to take 1 frame %%

triggerconfig(cam, 'manual');
cam.FramesPerTrigger = Inf;
cam.FrameGrabInterval = 1;

% getting 1 frame! %

frame=getsnapshot(cam);

%% sacar por pantalla frame %%

imshow(frame);


% start(cam);
% frame=trigger(cam);
% preview(cam);
