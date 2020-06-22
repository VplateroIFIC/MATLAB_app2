clc
clear all

% Determine where your m-file's folder is.
folder = fileparts(which(mfilename)); 
% Add that folder plus all subfolders to the path.
addpath(genpath(folder));

addpath('F:\Gantry_code\Matlab_app');
result_path=('F:\Gantry_code\Matlab_app\tests\CirclesMatching\ImagesResults\');


kernel=3;      %81
threshold=41;
calibration=3.62483; %um/pixel

% imageInC=imread('circles_3.png');
%  imageInC=imread('fiducial 2.tif');
% imageInC=imread('fid_petal_gantrySetup_1.jpg');

for j=2:14
    
    imageLoaded=['fiducial ',int2str(j),'.tif'];
    imageInC=imread(imageLoaded);
    

if size(imageInC,3)==3
imageIn = rgb2gray(imageInC);
else
    imageIn=imageInC;
end

fid=FIDUCIALS;

medianFilter=cv.medianBlur(imageIn,'KSize',kernel);
BinaryFilter=cv.threshold(medianFilter,'Otsu','Type','Binary','MaxValue',150);
adapLocalThres=cv.adaptiveThreshold(BinaryFilter,'MaxValue',255,'Method','Gaussian','Type','BinaryInv','BlockSize',threshold,'C',2);
particlesRemoved=bwareaopen(adapLocalThres,200);
imuint8=im2uint8(particlesRemoved);
resizeIm=imresize(imuint8,1);

circles = cv.HoughCircles(medianFilter,'MaxRadius',0,'Param1',50,'Param2',30,'MinRadius',130,'MaxRadius',170);

% [centers,radii] = imfindcircles(imageIn,[140 160]);


[m,n]=size(circles);

for i=1:n
    X(i)=circles{i}(1);
    Y(i)=circles{i}(2);
    R(i)=circles{i}(3);
end


fig=figure('visible','off','Position', get(0, 'Screensize'));
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
viscircles([X Y],R)


name=strcat('with_no_blur_',int2str(j),'.png');
filename=strcat(result_path,name);
saveas(fig,filename)

end


