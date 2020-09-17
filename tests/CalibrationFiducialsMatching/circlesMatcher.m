clc
clear all

% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));
addpath('F:\Gantry_code\Matlab_app');
addpath('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Calibration\Extensive_calibration_measures_EndMarch\Calibration_plate_WithWeights_20190326_X0_Y0_Row_P0');
fid=FIDUCIALS;
kernel=5;

calibration=3.62483; %um/pixel



% imageInC=imread('circles_3.png');
imageInC=imread('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Fiducial_images\fiducial_calibration_plate\original_images\set_3\Circles_ORIGINAL_0_9_0.jpg');
% imageInC=imread('fid_petal_gantrySetup_1.jpg');

if size(imageInC,3)==3
imageIn = rgb2gray(imageInC);
else
    imageIn=imageInC;
end

[ROI,vertex,imagesROIbuilder]=fid.CalibrationFiducialROIBuilder(imageIn);

fid=FIDUCIALS;

medianFilter=cv.medianBlur(ROI,'KSize',kernel);
% BinaryFilter=cv.threshold(medianFilter,'Otsu','Type','Binary','MaxValue',150);
% adapLocalThres=cv.adaptiveThreshold(BinaryFilter,'MaxValue',255,'Method','Gaussian','Type','BinaryInv','BlockSize',threshold,'C',2);
% particlesRemoved=bwareaopen(adapLocalThres,200);
% imuint8=im2uint8(particlesRemoved);
% resizeIm=imresize(imuint8,1);

% circles = cv.HoughCircles(medianFilter,'MaxRadius',0,'Param1',50,'Param2',30,'MinRadius',130,'MaxRadius',170);
circles = cv.HoughCircles(medianFilter,'MinDist',100,'Param1',100,'Param2',5,'MinRadius',8*calibration,'MaxRadius',12*calibration);

% [centers,radii] = imfindcircles(imageIn,[140 160]);


[m,n]=size(circles);

% if n~=4
%     disp('matching error, number of circles fitted different from 4')
% end

for i=1:n
    X(i)=circles{i}(1);
    Y(i)=circles{i}(2);
    R(i)=circles{i}(3);
end

fit=fit_square(circles);


centerFitted=fit(1:2);
centerFid=[sum(X)/n,sum(Y)/n];

figure(1)
subplot(3,1,1)
imshow(imageInC)
title('original image')
subplot(3,1,2)
imshow(medianFilter)
title('ROI')
subplot(3,1,3)
imshow(medianFilter)
title('Circles detected')
% hold on
% plot(X,Y, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
hold on
viscircles([X' Y'],R)
hold on 
plot(centerFid(1),centerFid(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);



