classdef FIDUCIALS
    %FIDUCIALS class dedicated to fiducial recognition
    %   Detailed explanation goes here
    
    properties (Access=private)

% matchSURF

binaryFilterKernel=9;
adaptativeThreshold=41;
SURF_Extended=false;   %false 
SURF_HessianThreshold=300;   %300 to 500 (the larger, the less keypoints we get)
SURF_NOctaveLayers=2;       %2
SURF_NOctaves=10;    %4  increase for big features, decrease for small features
SURF_Upright=false;   % ignore the rotation check for each feature
knn_match_number=2;
filter_ratio=0.8;   %minimum distance between matches
filter_size=50;   % minimum size for the feature

% prepareImage

sizeParticles=9500;


% FROIbuilder

pixelAreaF=74000;  % aprox value of the F Area in pixels in IFIC setup
deltaArea=3000;
perimeterF=2000;   % aprox value of the F Perimeter in pixels in IFIC setup
deltaPerimeter=500;
ROIsize=1000;

% FmatchSURF

% FtemplatePath=('F:\Gantry_code\Matlab_app\tests\fiducialMatching\FiducialsPictures\FinFidGray.jpg');
FtemplatePath=('D:\Gantry\cernbox\GANTRY-IFIC\Pictures_general\FiducialsPictures\FinFidGray.jpg');

    end
    
    methods
        
        function fid=FIDUCIALS
%             addpath('F:\mexopencv');
%             addpath('F:\mexopencv\opencv_contrib');
            addpath('D:\Code\MATLAB_app\opencvCompiler\mexopencv');
            addpath('D:\Code\MATLAB_app\opencvCompiler\mexopencv\opencv_contrib');
            
        end
     
        function match = matchSURF(this,imageIn,tempIn)
% matchSURF match template on given image using SURF method
% this method and submethods work with opencv lib. mexopencv folder and subfolders have to be added to the path
%    inputs: 
%         this: instance which call the method
%         imageIn: reference image where I want to find the fiducial (preferible ROI)
%         tempIn: template image
%    outputs:
%         match: structure with next fields
%             Center: coordenates of the center of the located template into the image. In pixels. image coordinate system.
%             Time: time consumed
%             Matches: number of final matches
%             Transformation: Transformation matrix from knn matching
%             Inliers: Inliers matches
%             Images: Useful images of the matching
              
totalTime=tic;
[m,n,k]=size(tempIn);
centerTemp=[n/2,m/2];

% passing to grayscale if needed %

if size(imageIn,3)==3
image = rgb2gray(imageIn);
else
    image=imageIn;
end

if size(tempIn,3)==3
template = rgb2gray(tempIn);
else
    template=tempIn;
end

% processing images %

kernel=this.binaryFilterKernel; 
threshold=this.adaptativeThreshold;      

preparedROI=this.prepareImage(image,kernel,threshold);
preparedTemp=this.prepareImage(template,kernel,threshold);

 % appling SURF algorithm to find keypoints and compute detectors %

detector=cv.SURF('Extended',true);

detector.Extended=this.SURF_Extended; 
detector.HessianThreshold=this.SURF_HessianThreshold; 
detector.NOctaveLayers=this.SURF_NOctaveLayers;  
detector.NOctaves=this.SURF_NOctaves; 
detector.Upright=this.SURF_Upright;   

[keypointsROI, descriptorsROI] = detector.detectAndCompute(preparedROI);
[keypointsTemp, descriptorsTemp] = detector.detectAndCompute(preparedTemp);

% Appling brute force cross matching %

matcher=cv.DescriptorMatcher('BruteForce');
matches12=matcher.knnMatch(descriptorsROI,descriptorsTemp,this.knn_match_number);

% plotting initial matches %

images{1} = cv.drawMatches(preparedROI, keypointsROI, preparedTemp, keypointsTemp, matches12,'NotDrawSinglePoints',true,'DrawRichKeypoints',true);

% applying size filter and ratio filter to remove bad matches %

ratio=this.filter_ratio;
sizeThreshold=this.filter_size;
betterMatches= this.ratioTest(matches12,keypointsROI,keypointsTemp,sizeThreshold,ratio);

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

images{3} = this.plotTempMatched (preparedROI,preparedTemp,H);

% plot final matches %

images{4} = this.plotFinalMatches (scene,objeto,preparedROI,preparedTemp,H);

match.Center=H(1:2,1:2)*centerTemp'+[H(1,3),H(2,3)]';
timeElapsed=toc(totalTime);

match.time=timeElapsed;
match.matches=length(objeto);
match.transformation=H;
match.Inliers=inliers;
match.Images=images;
         
        end
        
        function [imageOut,images] = prepareImage(this,imageIn,kernel,threshold)
% prepareImage pre processing image before matching
%    inputs: 
%         this: instance which calls the method
%         imageIn: reference image to preprocess
% 
%    outputs:
%         imageOut: preprocessed image
%         images: cell array with all steps of processing

if size(imageIn,3)==3
imageIn = rgb2gray(imageIn);
end
medianFilter=cv.medianBlur(imageIn,'KSize',kernel);
BinaryFilter=cv.threshold(medianFilter,'Otsu','Type','Binary','MaxValue',150);
adapLocalThres=cv.adaptiveThreshold(BinaryFilter,'MaxValue',255,'Method','Gaussian','Type','BinaryInv','BlockSize',threshold,'C',2);
particlesRemoved=bwareaopen(adapLocalThres,this.sizeParticles);
imuint8=im2uint8(particlesRemoved);
resizeIm=imresize(imuint8,1);

imageOut=resizeIm;

images{1}=medianFilter;
images{2}=BinaryFilter;
images{3}=adapLocalThres;
images{4}=particlesRemoved;
images{5}=resizeIm;

        end
        
        function goodMatches = ratioTest(this,matches,keypoints1,keypoints2,sizeThreshold, ratio)
% ratioTest filtering matches by particle size and distance 
%    inputs: 
%       this: instance which calls the method
%       matches: matches from knn. img-->temp
%       keypoints1: Keypoints of reference image
%       keypoints2: reference image to preprocess
%       sizeThreshold: reference image to preprocess
%       ratio: distance threshold           
%    outputs:
%       imageOut: preprocessed image
%       images: cell array with all steps of processing


n=length(matches);
lowRatio=ratio;
cont=1;
for i=1:n
    indexQuery=matches{i}(1).queryIdx+1;
    indexTrain=matches{i}(1).trainIdx+1;
if (matches{i}(1).distance < matches{i}(2).distance*lowRatio) && (keypoints1(indexQuery).size>sizeThreshold) && (keypoints2(indexTrain).size>sizeThreshold)
    goodMatches{cont}(1).queryIdx=matches{i}.queryIdx;
    goodMatches{cont}(1).trainIdx=matches{i}.trainIdx;
    goodMatches{cont}(1).imgIdx=matches{i}.imgIdx;
    goodMatches{cont}(1).distance=matches{i}.distance;
    cont=cont+1;
end
end
        end
        
        function plotImage = plotTempMatched(this,image,temp,Affine2D)
% this function plot the centre an the edges of the template over the query image
%    inputs: 
%       this: instance which calls the method
%       image: query image (usually ROI)
%       temp: template (train)
%       Affine2D: Affine transformation matrix (output from AffinePartial2d)
%           [cos(theta)*s, -sin(theta)*s, tx;
%            sin(theta)*s,  cos(theta)*s, ty])       
%    outputs:
%       plotImage: plot the original image with the matched template over it

 
ScaRot=Affine2D(1:2,1:2);
xDelta=Affine2D(1,3);
yDelta=Affine2D(2,3);
[n,m]=size(temp);

centerTemp=[m/2,n/2];
centerTempTransformed=ScaRot*[centerTemp(1),centerTemp(2)]'+[xDelta,yDelta]';

vertexTemp{1}=[0 0];
vertexTemp{2}=[m 0];
vertexTemp{3}=[m n];
vertexTemp{4}=[0 n];


vertexTrans{1}=ScaRot*vertexTemp{1}'+[xDelta,yDelta]';
vertexTrans{2}=ScaRot*vertexTemp{2}'+[xDelta,yDelta]';
vertexTrans{3}=ScaRot*vertexTemp{3}'+[xDelta,yDelta]';
vertexTrans{4}=ScaRot*vertexTemp{4}'+[xDelta,yDelta]';


% imageSize=size(image);
fig=figure('visible','off','Position', get(0, 'Screensize'));
subplot(1,2,2)
imshow(image);
axis on
hold on;
plot(centerTempTransformed(1),centerTempTransformed(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
hold on 
line([vertexTrans{1}(1),vertexTrans{2}(1)],[vertexTrans{1}(2),vertexTrans{2}(2)],'LineWidth', 2);
line([vertexTrans{2}(1),vertexTrans{3}(1)],[vertexTrans{2}(2),vertexTrans{3}(2)],'LineWidth', 2);
line([vertexTrans{3}(1),vertexTrans{4}(1)],[vertexTrans{3}(2),vertexTrans{4}(2)],'LineWidth', 2);
line([vertexTrans{4}(1),vertexTrans{1}(1)],[vertexTrans{4}(2),vertexTrans{1}(2)],'LineWidth', 2);
title('Query image: Center point of the templated matched in query image','FontSize', 18);
subplot(1,2,1)
imshow(temp);
hold on
plot(centerTemp(1),centerTemp(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
title('Template: center point','FontSize', 18);

fig2image=getframe(fig);
plotImage=fig2image.cdata;

        end
        

function plotImage = plotFinalMatches (this,scene,objeto,ROI,Temp,Affine2d)
% 
% plotFinalMatches  this function plot the matches over query and train images
%    inputs: 
%       this: instance which calls the method
%       scene: matches in scene(original image)
%       objeto: matches in objeto (template image)
%       ROI: ROI image
%       Temp: template image
%       Affine2d: Affine transformation matrix (output from AffinePartial2d)
%           [cos(theta)*s, -sin(theta)*s, tx;
%            sin(theta)*s,  cos(theta)*s, ty])      
%    outputs:
%       plotImage: plot the original image with the matched template over it


ScaRot=Affine2d(1:2,1:2);
xDelta=Affine2d(1,3);
yDelta=Affine2d(2,3);
[n,m]=size(Temp);

centerTemp=[m/2,n/2];
centerTempTransformed=ScaRot*[centerTemp(1),centerTemp(2)]'+[xDelta,yDelta]';

fig=figure('visible','off','Position', get(0, 'Screensize'));
subplot(1,3,1)
imshow(Temp)
hold on
plot(centerTemp(1),centerTemp(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
subplot(1,3,2)
imshow(ROI)
subplot(1,3,3)
imshow(ROI)
hold on
plot(centerTempTransformed(1),centerTempTransformed(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
for i=1:length(objeto)
subplot(1,3,1)
hold on
scatter (objeto{i}(1),objeto{i}(2))
subplot(1,3,2)
hold on
scatter(scene{i}(1),scene{i}(2))
subplot(1,3,3)
hold on
obj=ScaRot*[objeto{i}(1),objeto{i}(2)]'+[xDelta,yDelta]';
scatter(obj(1),obj(2))
end

subplot(1,3,1)
title('Keypoints in Temp')
subplot(1,3,2)
title('keypoints in ROI')
subplot(1,3,3)
title('keypoints transformed')

fig2image=getframe(fig);
plotImage=fig2image.cdata;

end


function [ROI,vertex] = FROIbuilder(this,image)
% 
% FROIbuilder  generate square ROI of size N around F of the image. It locate the F centroid by reading the pixel area of the F High res camera!.
%    inputs: 
%       this: instance which calls the method
%       image: original image to extract the ROI

     
%    outputs:
%       ROI: region of interest around F.
      
if size(image,3)==3
image = rgb2gray(image);
end

Binary = imbinarize(image);
BynaryInv=imcomplement(Binary);
    
area=this.pixelAreaF;
rangeArea=[area-this.deltaArea,area+this.deltaArea];
perimeter=this.perimeterF; 
rangePerimeter=[perimeter-this.deltaPerimeter,perimeter+this.deltaPerimeter];

imageF1 = bwpropfilt(BynaryInv,'area',rangeArea);   %filter by area
imageF2 = bwpropfilt(imageF1,'perimeter',rangePerimeter);   %filter by perimeter
CC=bwconncomp(imageF2);
if CC.NumObjects>1
    imageF3=bwpropfilt(BynaryInv,'area',1);
else
    imageF3=imageF2;
end

prop = regionprops(imageF3,'centroid');

[ROI,vertex]=this.ROIbuilder(image,prop.Centroid);

end

function [ROI,ver1] = ROIbuilder(this,image,center)
% 
% ROIbuilder  generate square ROI of size N around given center. 
%    inputs: 
%       this: instance which calls the method
%       image: original image to extract the ROI
%       center: center of the desired ROI (2x1 array)   
%    outputs:
%       ROI: region of interest around F.
        
ver1=[center(1)-this.ROIsize/2,center(2)-this.ROIsize/2];
ver2=[center(1)+this.ROIsize/2,center(2)-this.ROIsize/2];
ver3=[center(1)+this.ROIsize/2,center(2)+this.ROIsize/2];
ver4=[center(1)-this.ROIsize/2,center(2)+this.ROIsize/2];

ROI=image(ver1(2):ver3(2),ver1(1):ver3(1),:);
end

function match = FmatchSURF(this,image)
% 
% FmatchSURF  Look for F sensor fiducial into given image
%    inputs: 
%       this: instance which calls the method
%       image: original image to find fiducial

%    outputs:
%     match: structure with next fields
%         Center: coordenates of the center of the located template into the image. In pixels. image coordinate system.
%         Time: time consumed
%         Matches: number of final matches
%         Transformation: Transformation matrix from knn matching
%         Inliers: Inliers matches
%         Images: Useful images of the matching
        
[ROI,vertex]=this.FROIbuilder(image);
template=imread(this.FtemplatePath);


match=this.matchSURF(ROI,template);
match.Center(1)=match.Center(1)+vertex(1);
match.Center(2)=match.Center(2)+vertex(2);
fig=figure('visible','off','Position', get(0, 'Screensize'));
imshow(image);
hold on
plot(match.Center(1),match.Center(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
title('Final match','FontSize', 18);

fig2image=getframe(fig);
plotImage=fig2image.cdata;

match.Images{5}=plotImage;

end
end
end
