clc
clear all


addpath('F:\Gantry_code\Matlab_app');
addpath('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Pictures_general\Hybrid_fiducials\O');

kernel=11;
threshold=41;
calibration=3.62483; %um/pixel


imageInC=imread('hybrid_circle_fid_contrast.png');


if size(imageInC,3)==3
imageIn = rgb2gray(imageInC);
else
    imageIn=imageInC;
end

fid=FIDUCIALS;

medianFilter=cv.medianBlur(imageIn,'KSize',kernel);


circles = cv.HoughCircles(medianFilter,'MaxRadius',0,'Param1',50,'Param2',30,'MinRadius',5*calibration,'MaxRadius',70*calibration);

% [centers,radii] = imfindcircles(imageIn,[40*calibration 60*calibration]);


[m,n]=size(circles);

for i=1:n
    X(i)=circles{i}(1);
    Y(i)=circles{i}(2);
    R(i)=circles{i}(3);
end


figure(1)
subplot(3,1,1)
imshow(imageInC)
title('original image')
subplot(3,1,2)
imshow(medianFilter)
title('Blur filter applied')
subplot(3,1,3)
imshow(medianFilter)
title('Circles detected')
hold on
plot(X,Y, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
hold on
viscircles([X' Y'],R)

figure(2)
imshow(medianFilter)
title('Circles detected')
hold on
plot(X,Y, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
hold on
viscircles([X' Y'],R)
