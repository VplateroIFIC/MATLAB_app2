clc
clear all

% finding transformation matrix to find fiducial in Gantry system %

addpath('D:\Usuarios\Leon\ATLAS_general\3-Petals\Assembly\Tests_results\calibration_rotation_camera\gantry\measure_2\displacement_X')
addpath('D:\Usuarios\Leon\ATLAS_general\3-Petals\Assembly\Tests_results\calibration_rotation_camera\gantry\measure_2\displacement_Y')
addpath('C:\Users\Leon\Documents\Matlap_app')

%Loading data

gantryCoord=load('coordenatesX.txt');
imageCoord=load('coordenatesXImage.txt');

% Calculating angle

%fitting the line
P = polyfit(imageCoord(:,1),imageCoord(:,2),1);

% calculating the angle
angle=atan(P(1));

% creating roation matrix
rotation=transform2D();
rotation.rotate(-angle)

%rotating points
n=length(imageCoord(:,1));
for i=1:n
    rotatedImage(i,:)=rotation.M*imageCoord(i,:)';
end
