%%%%% CAMERA EXAMPLE %%%%%
clc
clear all

% creating camera object %
imaqreset;
dev_info = imaqhwinfo('gentl',1);
cam = videoinput('gentl',1);
triggerconfig(cam, 'hardware')  % configurando trigger por hardware

% properties of camera object %

src = getselectedsource(cam);
src.ExposureAuto = 'Continuous';
src.GainAuto = 'Continuous';
preview(cam)
