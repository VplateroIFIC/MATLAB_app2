function [center,images,Info] = matchSURFfunc (imageIn,templateIn)
%[center,images,resultInfo] = matchSURFfunc (image,template)
% 
% center: coordenates of the center of the located template into the image. In pixels. image coordinate system. (origin is in the top left corner!!)
% images: useful images to understand how was the match
% info: struct with information about the process:
%     - time: time consumed
%     - matches: number of final matches
% 
% image: query image. RGB uint8.
% template: train image. RGB uint8.
% 
% this functions works with opencv methods. mexopencv folder and subfolders have to be added to the path

totalTime=tic;
[m,n,k]=size(templateIn);
centerTemp=[n/2,m/2];


% passing to grayscale %


if size(imageIn,3)==3
image = rgb2gray(imageIn);
else
    image=imageIn;
end

if size(templateIn,3)==3
template = rgb2gray(templateIn);
else
    template=templateIn;
end


% processing images %

kernel=9;       %9 for binary filter
threshold=41;        %7  for adaptative threshold

preparedROI=prepareImage(image,kernel,threshold);
preparedTemp=prepareImage(template,kernel,threshold);

 % appling SURF algorithm to find keypoints and compute detectors %

detector=cv.SURF('Extended',true);

detector.Extended=false;   %false 
detector.HessianThreshold=300;   %300 to 500 (the larger, the less keypoints we get)
detector.NOctaveLayers=2;       %2
detector.NOctaves=10;    %4  increase for big features, decrease for small features
detector.Upright=false;   % ignore the rotation check for each feature

[keypointsROI, descriptorsROI] = detector.detectAndCompute(preparedROI);
[keypointsTemp, descriptorsTemp] = detector.detectAndCompute(preparedTemp);

% Appling brute force cross matching %

matcher=cv.DescriptorMatcher('BruteForce');
matches12=matcher.knnMatch(descriptorsROI,descriptorsTemp,2);
matches21=matcher.knnMatch(descriptorsTemp,descriptorsROI,2);

% plotting initial matches %

images{1} = cv.drawMatches(preparedROI, keypointsROI, preparedTemp, keypointsTemp, matches12,'NotDrawSinglePoints',true,'DrawRichKeypoints',true);

% applying size filter and ratio filter to remove bad matches %

ratio=0.8;
sizeThreshold=50;
matches12good= ratioTest(matches12,keypointsROI,keypointsTemp,sizeThreshold,ratio);
matches21good= ratioTest(matches21,keypointsTemp,keypointsROI,sizeThreshold, ratio);

% applying symetry filter to get the best matches %

% betterMatches=symTest(matches12good, matches21good);
betterMatches=matches12good;

% Bulding the final keypoints vectors (scene and object) %

objeto=cell(1,length(betterMatches));
scene=cell(1,length(betterMatches));

for i=1:length(betterMatches)
   indxObj=betterMatches{i}.trainIdx;
   indxScene=betterMatches{i}.queryIdx;  
    
   scene{i}=[keypointsROI(indxScene+1).pt(1), keypointsROI(indxScene+1).pt(2)];
   objeto{i}=[keypointsTemp(indxObj+1).pt(1), keypointsTemp(indxObj+1).pt(2)];
end

% Performing affine transformation %

[H,inliers] = cv.estimateAffinePartial2D(objeto',scene','Method','Ransac','RefineIters',50);

% plotting better matches %

images{2} = cv.drawMatches(preparedROI, keypointsROI, preparedTemp, keypointsTemp, betterMatches,'NotDrawSinglePoints',true,'DrawRichKeypoints',true);

% plotting results %

images{3} = plotTempMatched (preparedROI,preparedTemp,H);

% plot final matches %

images{4} = plotFinalMatches (scene,objeto,preparedROI,preparedTemp,H);

center=H(1:2,1:2)*centerTemp'+[H(1,3),H(2,3)]';
timeElapsed=toc(totalTime);

Info.time=timeElapsed;
Info.matches=length(objeto);
Info.transformation=H;
Info.Inliers=inliers;


end