%%%%% CAMERA EXAMPLE %%%%%
clc
clear all

imaqreset;
cam = videoinput('winvideo',1);
triggerconfig(cam, 'manual');
cam.FramesPerTrigger = inf;
cam.FrameGrabInterval = 1;
src = getselectedsource(cam);
src.ExposureMode = 'manual';
% src.Exposure = exp;
start(cam);
trigger(cam);
preview(cam);
% pause(0.25);
% Collect(app,1);