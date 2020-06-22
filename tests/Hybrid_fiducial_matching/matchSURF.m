%% this script evaluate template matching based in features detection usin ORB %%

clc
clear all

% Adding picture and opencvmex lib folder to path %


addpath('F:\Gantry_code\Matlab_app\tests\Hybrid_fiducial_matching\templates\X')
addpath('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Pictures_general\Hybrid_fiducials\X');
addpath('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Pictures_general\Hybrid_fiducials\F');
addpath('F:\Gantry_code\Matlab_app\tests\Hybrid_fiducial_matching\results');

% loading original figure and template %


% imageRGB=imread('Fiducials_C300_ABC25_1.png');
imageRGB=imread('Fiducials_F300_10.png');


% templateRGB=imread('Xtemplate_good.png');
templateRGB=imread('Ftemplate_good.png');

% passing to grayscale if needed %

if size(imageRGB,3)==3
 image = rgb2gray(imageRGB);
else
 image=imageRGB;
end

if size(templateRGB,3)==3
template = rgb2gray(templateRGB);
else
    template=templateRGB;
end

ROI=image;


kernel=9;       % for binary filter
threshold=41;        % for adaptative threshold

% preparedROI=prepareImage(ROI,kernel,threshold);
% preparedTemp=prepareImage(template,kernel,threshold);

preparedROI=ROI;
preparedTemp=template;

% appling SURF algorithm to find keypoints and compute detectors %

detector=cv.SURF('Extended',true);

detector.Extended=false;   %false 
detector.HessianThreshold=300;   %300 to 500 (the larger, the less keypoints we get)
detector.NOctaveLayers=4;       %2
detector.NOctaves=10;    %4  increase for big features, decrease for small features
detector.Upright=false;   % ignore the rotation check for each feature

[keypointsROI, descriptorsROI] = detector.detectAndCompute(preparedROI);
[keypointsTemp, descriptorsTemp] = detector.detectAndCompute(preparedTemp);

% Appling brute force cross matching %

matcher=cv.DescriptorMatcher('BruteForce');
matches12=matcher.knnMatch(descriptorsROI,descriptorsTemp,5);
matches21=matcher.knnMatch(descriptorsTemp,descriptorsROI,5);

% plotting first matches %

matchesdrawn2 = cv.drawMatches(preparedROI, keypointsROI, preparedTemp, keypointsTemp, matches12,'NotDrawSinglePoints',true,'DrawRichKeypoints',true);
figure(1)
imshow(matchesdrawn2);


% applying size filter and ratio filter to remove bad matches %

ratio=0.8;
sizeThreshold=50;
matches12good= ratioTest(matches12,keypointsROI,keypointsTemp,sizeThreshold,ratio);
matches21good= ratioTest(matches21,keypointsTemp,keypointsROI,sizeThreshold, ratio);

% plotting good matches %

matchesdrawn2 = cv.drawMatches(preparedROI, keypointsROI, preparedTemp, keypointsTemp, matches12good,'NotDrawSinglePoints',true,'DrawRichKeypoints',true);
figure(3)
imshow(matchesdrawn2);

% applying symetry filter to get the best matches %

betterMatches=matches12good;

% plotting better matches %

matchesdrawn2 = cv.drawMatches(preparedROI, keypointsROI, preparedTemp, keypointsTemp, betterMatches,'NotDrawSinglePoints',true,'DrawRichKeypoints',true);
figure(3)
imshow(matchesdrawn2);

% Bulding the final keypoints vectors (scene and object) %

objetoAll=cell(1,length(betterMatches));
sceneAll=cell(1,length(betterMatches));

for i=1:length(betterMatches)
   indxObj=betterMatches{i}.trainIdx;
   indxScene=betterMatches{i}.queryIdx;  
    
   scene{i}=[keypointsROI(indxScene+1).pt(1), keypointsROI(indxScene+1).pt(2)];
   objeto{i}=[keypointsTemp(indxObj+1).pt(1), keypointsTemp(indxObj+1).pt(2)];
end

% Performing affine transformation %

[H,inliers] = cv.estimateAffinePartial2D(objeto',scene','Method','Ransac','RefineIters',50,'RansacThreshold',3);

% plotting results %

image1=plotTempMatched (preparedROI,preparedTemp,H);
figure, imshow(image1);

% plot final matches %

image2=plotFinalMatches (scene,objeto,preparedROI,preparedTemp,H);
figure,imshow(image2);






