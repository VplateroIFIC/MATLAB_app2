clc
clear all

% finding transformation matrix to find fiducial in Gantry system %

addpath('D:\Usuarios\Leon\ATLAS_general\3-Petals\Assembly\Tests_results\calibration_rotation_camera\gantry\measure_2\displacement_X')
addpath('D:\Usuarios\Leon\ATLAS_general\3-Petals\Assembly\Tests_results\calibration_rotation_camera\gantry\measure_2\displacement_Y')
addpath('C:\Users\Leon\Documents\Matlap_app')


calibration=1.74; %pixel/um
%axis X or Y (1 o 2)
axis=1;

%Loading data

switch axis
    case 1
gantryCoord=load('coordenatesX.txt');
imageCoord=load('coordenatesXImage.txt');
image=imread('imageX_1.png');
    case 2
gantryCoord=load('coordenatesY.txt');
imageCoord=load('coordenatesYImage.txt');  
image=imread('imageY_1.png');
end

gantryCoord=load('coordenates.txt');


% Calculating angle

%fitting the line
P = polyfit(imageCoord(:,1),imageCoord(:,2),1);

% calculating the angle
angle=atan(P(1));

switch axis
    case 1  
    case 2
        if angle<0
            angle=-(pi/2-(angle+pi));
        else
            angle=pi/2-angle;
        end
end

% creating roation matrix
rotation=transform2D();
rotation.rotate(-angle)

%rotating points
n=length(imageCoord(:,1));
for i=1:n
    rotatedImage(i,:)=rotation.M*imageCoord(i,:)';
end

%translating points
n=length(rotatedImage(:,1));
for i=1:n
   translation=transform2D();
   translation.translate([gantryCoord(i,1),gantryCoord(i,2)])
   gantryCoordenate(i,:)=translation.M*[-rotatedImage(i,2);-rotatedImage(i,1);1];
end

%changing the reference system to image coordinate system
[n1,n2,n3]=size(image);
imageCoord(:,4)=imageCoord(:,1)*calibration*1000+n2/2;
imageCoord(:,5)=n1/2-imageCoord(:,2)*calibration*1000;

figure(1)
imshow(image)
hold on
plot(imageCoord(:,4),imageCoord(:,5),'*','Color','r')
hold on
plot(imageCoord(:,4),imageCoord(:,5),'-','Color','r')
hold on
plot([imageCoord(1,4) n2],[imageCoord(1,5),imageCoord(1,5)],'-','Color','k')
hold on
plot([imageCoord(1,4) imageCoord(1,4)],[imageCoord(1,5),0],'-','Color','k')
title('POSITIONS OF MATCHED FIDUCIALS')



figure (2)
plot(gantryCoordenate(:,1),gantryCoordenate(:,2),'*','MarkerSize', 10)
hold on
circle(mean(gantryCoordenate(:,1)),mean(gantryCoordenate(:,2)),0.0015)
xlim([mean(gantryCoordenate(:,1))-0.002 mean(gantryCoordenate(:,1))+0.002])
ylim([mean(gantryCoordenate(:,2))-0.002 mean(gantryCoordenate(:,2))+0.002])
title('Error in F position','FontSize', 25)


