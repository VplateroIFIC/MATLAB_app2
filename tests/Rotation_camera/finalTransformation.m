% this script takes the position of one point WRT the center of the image, and takes the coordenate of the image. The output is the position of 
% the point WRT the Gantry system
clc
clear all

% working path 
addpath('F:\Users\leon\Documents\SilicioGeneral\3-Petals\Assembly\Tests_results\calibration_rotation_camera\gantry\second measures\Horizontal')
% addpath('F:\Gantry_code\Matlab_app')

% loading image coordinates WRT gantry system (mm)
positionImages=importdata('coordenates.txt');

% loading points coordinates WRT the center of the image (mm)
positionPoints=importdata('fiducialsWRTcenter.txt');

% loading the angle to be corrected (rad)
angle=importdata('angle.txt');

% rotation transformation angle offset
rotation=transform2D();
rotation.rotate(-angle);
[n,m]=size(positionPoints);
for j=1:n
    rotatedPoints(j,:)=rotation.M*[positionPoints(j,1);positionPoints(j,2);1];
end

% rotation transformation angle 90
rotation90=transform2D();
rotation90.rotate(-pi/2);
[n,m]=size(positionPoints);
for j=1:n
    fullyRotatedPoints(j,:)=rotation90.M*[rotatedPoints(j,1);rotatedPoints(j,2);1];
end

% translation transformation for final result
translate=transform2D();

for j=1:n
clearvars translate
translate=transform2D();
translate.translate([positionImages(j,1),positionImages(j,2)]);
translatedPoints(j,:)=translate.M*[fullyRotatedPoints(j,1);fullyRotatedPoints(j,2);1];
end