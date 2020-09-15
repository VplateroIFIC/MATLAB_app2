classdef FIDUCIALS
    %FIDUCIALS class dedicated to fiducial recognition
    %   Detailed explanation goes here
    
    properties (Access=private)

% matchSURF
binaryFilterKernel;
adaptativeThreshold;
SURF_Extended;    
SURF_HessianThreshold;  
SURF_NOctaveLayers;  
SURF_NOctaves;   
SURF_Upright; 
knn_match_number;
filter_ratio;   
filter_size;   

% prepareImage
sizeParticles;

% FROIbuilder
pixelAreaF;
deltaArea;
perimeterF; 
deltaPerimeter;

% ROIbuilder
ROIsize;

% FmatchSURF
FtemplatePath;
cornerF;
cameraRotationOffset;

% CirclesFinder
camCalibration; %pixel/um
binaryFilterKernel_circles;

% CalibrationFiducialROIBuilder
ROIsizeCalib; 
diameter;
deltaDiam;
NominalShortDistance;   
NominalLongDistance;    
binaryFilterKernel_calibrationPlate;

% calibrationFidFinder
binaryFilterKernel_calibration;
minDist;

% image2gantryCoordinates
angleCamera;


    end
    
    methods
        
        function this=FIDUCIALS(setup)
% Contructor
% 1--> Gantry setup
% 2--> OWIS setup
       
%             %Adding to the path the opencv library if necessary.
%             
%             addpath('F:\mexopencv');
%             addpath('F:\mexopencv\opencv_contrib');
           addpath('D:\Code\MATLAB_app\opencvCompiler\mexopencv');
           addpath('D:\Code\MATLAB_app\opencvCompiler\mexopencv\opencv_contrib');
           addpath('Fiducial_config');

% Loading corresponding properties to the class

switch setup
    case 1
        FIDUCIALS_properties_Gantry
    case 2
        FIDUCIALS_properties_OWIS
end

% initialization of the properties values

% matchSURF
this.binaryFilterKernel=binaryFilterKernel;
this.adaptativeThreshold=adaptativeThreshold;
this.SURF_Extended=SURF_Extended;    
this.SURF_HessianThreshold=SURF_HessianThreshold;   
this.SURF_NOctaveLayers=SURF_NOctaveLayers;      
this.SURF_NOctaves=SURF_NOctaves;    
this.SURF_Upright=SURF_Upright;  
this.knn_match_number=knn_match_number;
this.filter_ratio=filter_ratio;  
this.filter_size=filter_size;   

% prepareImage
this.sizeParticles=sizeParticles;

% FROIbuilder
this.pixelAreaF=pixelAreaF;  
this.deltaArea=deltaArea;
this.perimeterF=perimeterF;  
this.deltaPerimeter=deltaPerimeter;

% ROIbuilder
this.ROIsize=ROIsize;

% FmatchSURF
this.FtemplatePath=FtemplatePath;
this.cornerF=cornerF;
this.cameraRotationOffset=cameraRotationOffset;

% CirclesFinder
this.camCalibration=camCalibration; 
this.binaryFilterKernel_circles=binaryFilterKernel_circles;

% CalibrationFiducialROIBuilder
this.ROIsizeCalib=ROIsizeCalib; 
this.diameter=diameter;
this.deltaDiam=deltaDiam;
this.NominalShortDistance=NominalShortDistance; 
this.NominalLongDistance=NominalLongDistance;  
this.binaryFilterKernel_calibrationPlate=binaryFilterKernel_calibrationPlate;

% calibrationFidFinder
this.binaryFilterKernel_calibration=binaryFilterKernel_calibration;
this.minDist=minDist;

%image2gantryCoordinates
this.angleCamera=angleCamera;

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
[betterMatches,error]= this.ratioTest(matches12,keypointsROI,keypointsTemp,sizeThreshold,ratio);
if error==1
    match.error=1;
    return
end


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

%calculating center of the fiducial in image coordinate system
match.Center=H(1:2,1:2)*centerTemp'+[H(1,3),H(2,3)]';

timeElapsed=toc(totalTime);

match.time=timeElapsed;
match.matches=length(objeto);
match.transformation=H;
match.Inliers=inliers;
match.Images=images;
match.error=0;
         
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

% passing to gray image if necessary
if size(imageIn,3)==3
imageIn = rgb2gray(imageIn);
end

% Processing image
medianFilter=cv.medianBlur(imageIn,'KSize',kernel);
BinaryFilter=cv.threshold(medianFilter,'Otsu','Type','Binary','MaxValue',255);
adapLocalThres=cv.adaptiveThreshold(BinaryFilter,'MaxValue',255,'Method','Gaussian','Type','BinaryInv','BlockSize',threshold,'C',2);
particlesRemoved=bwareaopen(adapLocalThres,this.sizeParticles);
% particlesRemoved=bwareaopen(adapLocalThres,3000);
imuint8=im2uint8(particlesRemoved);
resizeIm=imresize(imuint8,1);

imageOut=resizeIm;

images{1}=medianFilter;
images{2}=BinaryFilter;
images{3}=adapLocalThres;
images{4}=particlesRemoved;
images{5}=resizeIm;

        end
        
        function [goodMatches,error] = ratioTest(this,matches,keypoints1,keypoints2,sizeThreshold, ratio)
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

error=0;
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
if exist('goodMatches')==0
    goodMatches=0;
    error=1;
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
% FROIbuilder  generate square ROI of size N around F of the image. It locate the F centroid by reading the pixel area and the perimeter of the F.
%    inputs: 
%       this: instance which calls the method
%       image: original image to extract the ROI 
%    outputs:
%       ROI: region of interest around F.
      
% passing rgb to gray if necessary
if size(image,3)==3
image = rgb2gray(image);
end

%Binarize the image
medianFilter=cv.medianBlur(image,'KSize',this.binaryFilterKernel);
Binary = imbinarize(medianFilter);
BynaryInv=imcomplement(Binary);

% Setting Area and Perimeter expected for the F
area=this.pixelAreaF;
rangeArea=[area-this.deltaArea,area+this.deltaArea];
perimeter=this.perimeterF; 
rangePerimeter=[perimeter-this.deltaPerimeter,perimeter+this.deltaPerimeter];

% Filtering by Area, perimeter and number of objects
imageF1 = bwpropfilt(BynaryInv,'area',rangeArea);   %filter by area
imageF2 = bwpropfilt(imageF1,'perimeter',rangePerimeter);   %filter by perimeter

% Calculation center of mass of the F found
prop = regionprops(imageF2,'centroid');
q=size(prop);
numberOfF=q(1);
ROI=cell(numberOfF,1);
vertex=cell(numberOfF,1);

% Cutting the ROI taking the reference the centroid
for i=1:numberOfF
[ROI{i},vertex{i}]=this.ROIbuilder(image,prop(i).Centroid,this.ROIsize);
end
end

function [ROI,ver1] = ROIbuilder(this,image,center,N)
% 
% ROIbuilder  generate square ROI of size N around given center.
%    inputs: 
%       this: instance which calls the method
%       image: original image to extract the ROI
%       center: center of the desired ROI (2x1 array)   
%    outputs:
%       ROI: region of interest around F.

% passing rgb to gray if necessary and getting dimensions of the image
if size(image,3)==3
imageGray = rgb2gray(image);
[m,n]=size(imageGray);
else
[m,n]=size(image);
end

% Locating vertex of the ROI
ver1=[center(1)-N/2,center(2)-N/2];
ver3=[center(1)+N/2,center(2)+N/2];
ver1=round(ver1);
ver3=round(ver3);

% In case vertex are out of original image, going to the edge
if ver1(1)<0, ver1(1)=1; end
if ver1(2)<0, ver1(2)=1; end
if ver3(1)>n, ver3(1)=n; end
if ver3(2)>m, ver3(2)=m; end

ROI=image(ver1(2):ver3(2),ver1(1):ver3(1),:);

end

function Fmatch = FmatchSURF(this,image,CurrentPos)
% FmatchSURF  Look for F sensor fiducial into given image
%    inputs: 
%       this: instance which calls the method
%       image: original image to find fiducial
%       CurrentPos: Current postion of gantry stages. It is associated to center of the image. [X,Y,Z1(~),Z2(~),U(~)]
%    outputs:
%     match: cell of structures with next fields. There will be 1 structure for each fiducial found in the image. 
%         Center: coordenates of the center of the located template into the image. In pixels. Image coordinate system
%         Time: time consumed
%         Matches: number of final matches
%         Transformation: Transformation matrix from knn matching
%         Inliers: Inliers matches
%         Images: Useful images of the matching
%             Image1: Matching Keypoints between query and train image. (all matches)
%             Image2: Matching Keypoints between query and train image. (Filtered matches)
%             Image3: Matching result over ROI
%             Image4: Matches selected for final match
%             Image5: Match of the current fiducial over the original image
%             Image6: Matches of all fiducials over the original image
%         Corner: coordenates of the corner of the fiducial into the image. In pixels. Image coordinate system
[m,n]=size(image);
centerImage=[round(m/2),round(n/2)];
[ROI,vertex]=this.FROIbuilder(image);
template=imread(this.FtemplatePath);

%creating transfomration matrix to pass from image reference system to center of image
transformationImage2Center=transform2D();
transformationImage2Center.translate([-centerImage(2),-centerImage(1)]);
 
% %creating transfomration matrix to pass from center of image to gantry reference systeem
% transformationGantry2Image=transform2D();
% transformationImage2Gantry=transform2D();
% transformationGantry2Image.translate([-CurrentPos(1),-CurrentPos(2)]);
% transformationGantry2Image.rotate(2*pi-(pi/2-this.cameraRotationOffset));
% % transformationGantry2Image.rotateMirrorY(2*pi-(pi/2-this.cameraRotationOffset));
% % transformationGantry2Image.rotate(2*pi-(this.cameraRotationOffset-pi/2));
% % transformationImage2Gantry.M=inv(transformationGantry2Image.M);
% transformationImage2Gantry.M=inv(transformationGantry2Image.M).*[1 1 1 ;-1 -1 1;1 1 1];
% 
% % transformationImage2Gantry.rotate(-this.cameraRotationOffset);

% how many F detected in image, k
[k,l]=size(ROI);


% loop to match the Fs of the image
for i=1:k
%matching the picture
match=this.matchSURF(ROI{i},template);
if match.error==1
    match=[];
    FmatchProvisional{i}=match;
    continue
end


%calculating the center of the fiducial in the new image, image coordinate system
match.Center(1)=match.Center(1)+vertex{i}(1);
match.Center(2)=match.Center(2)+vertex{i}(2);

% match.Center(1)=match.Center(1)+vertex{i}(1)-centerImage(2);
% match.Center(2)=match.Center(2)+vertex{i}(2)-centerImage(2);

%calculating the corner of the fiducial in the new image, image coordinate system
corner=[match.transformation;0 0 1]*[this.cornerF 1]';
match.Corner(1)=corner(1)+vertex{i}(1);
match.Corner(2)=corner(2)+vertex{i}(2);

% %calculating the position of the center and the corner fiducial in the new image (um), Origin in center of the image
% % center(1)=(match.Corner(1)-centerImage(2))*camCalibration;
% % center(2)=(m-(match.Corner(2)-centerImage(1)))*camCalibration;
% % corner(1)=(match.Corner(1)-centerImage(2))*camCalibration;
% % corner(2)=(m-(match.Corner(2)-centerImage(1)))*camCalibration;
% match.CenterImage=transformationImage2Center.M*[match.Center(1);m-match.Center(2);1]/this.camCalibration/1000;
% match.CornerImage=transformationImage2Center.M*[match.Corner(1);m-match.Corner(2);1]/this.camCalibration/1000;

%calculating the position of the center and the corner fiducial in Gantry system
% match.CenterGantry=transformationImage2Gantry.M*[match.CenterImage(1);match.CenterImage(2);1];
% match.CornerGantry=transformationImage2Gantry.M*[match.CornerImage(1);match.CornerImage(2);1];

%calculating the position of the center and the corner fiducial in Gantry system
match.CenterGantry=this.image2gantryCoordinates(match.Center,CurrentPos,[m,n]);
match.CornerGantry=this.image2gantryCoordinates(match.Corner,CurrentPos,[m,n]);

FmatchProvisional{i}=match;
clearvars match
end
cont=1;
for g=1:length(FmatchProvisional)
    if isempty(FmatchProvisional{g})
    else
       Fmatch{cont}=FmatchProvisional{g};
       cont=cont+1;
    end
end


% loop to plot the final image (each fiducial separately)
for i=1:length(Fmatch)
fig=figure('visible','off','Position', get(0, 'Screensize'));
imshow(image);
title('Final match','FontSize', 18);
hold on
plot(Fmatch{i}.Center(1),Fmatch{i}.Center(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
plot(Fmatch{i}.Corner(1),Fmatch{i}.Corner(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
fig2image=getframe(fig);
plotImage=fig2image.cdata;
Fmatch{i}.Images{5}=plotImage;
end

% loop to plot the final image (all fiducials)
fig=figure('visible','off','Position', get(0, 'Screensize'));
imshow(image);
title('Final match','FontSize', 18);
for i=1:length(Fmatch)
hold on
plot(Fmatch{i}.Center(1),Fmatch{i}.Center(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
plot(Fmatch{i}.Corner(1),Fmatch{i}.Corner(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
end
fig2image=getframe(fig);
plotImage=fig2image.cdata;
for i=1:length(Fmatch)
Fmatch{i}.Images{6}=plotImage;
end
end

function match = petalFidFinder(this,image)
% petalFidFinder  Look for 0.3mm petal fiducial into given image (Valencia setup).
%    inputs: 
%       this: instance which calls the method
%       image: original image to find circles
%    outputs:
%     match: structure with next fields
%         Center: coordenates of the center of the located circles into the image. In pixels. image coordinate system.
%         Diameter: Diameters of circles detected. in microns.
%         Images: Useful images of the matching.


% Passing to gray if necessary
if size(image,3)==3
imageIn = rgb2gray(image);
else
    imageIn=image;
end

% median filter to blur the image
medianFilter=cv.medianBlur(imageIn,'KSize',this.binaryFilterKernel);

% Detecting circles
circles = cv.HoughCircles(medianFilter,'MaxRadius',0,'Param1',50,'Param2',30,'MinRadius',130*this.camCalibration,'MaxRadius',170*this.camCalibration);

[m,n]=size(circles);

for i=1:n
    X(i)=circles{i}(1);
    Y(i)=circles{i}(2);
    R(i)=circles{i}(3);
end

% Ploting circles found
fig=figure('visible','off','Position', get(0, 'Screensize'));
subplot(2,1,1)
imshow(imageIn)
title('original image')
subplot(2,1,2)
imshow(medianFilter)
title('Circles detected')
hold on
plot(X,Y, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
hold on
viscircles([X Y],R);

fig2image=getframe(fig);
plotImage=fig2image.cdata;

match.center=[circles{1}(1) circles{1}(2)];
match.diameter=circles{1}(3)*2/this.camCalibration;

match.images{1}=plotImage;

end

function [ROI,vertex,imagesOut] = CalibrationFiducialROIBuilder(this,image)
% 
% CalibrationFiducialROIBuilder  generate square ROI around caibration plate fiducial. It locate the fiducial centroid by reading the pixel area, perimeter and
% circularity
%    inputs: 
%       this: instance which calls the method
%       image: original image to extract the ROI
%    outputs:
%       ROI: region of interest around calibration fiducial.
%       Vertex: Vertex 1 of the ROI in the original image.
%       imagesOut: useful images of the process of building the ROI.

% Passing image to gray is needed
if length(size(image))==3
imageIn = rgb2gray(image);
else
    imageIn=image;
end

% calculating area and perimeter ranges of the circles
calibration=this.camCalibration;
NominalDiameter=this.diameter;  % nominal diameter of the fiducial circles (um)
deltaDiameter=this.deltaDiam;    % range of threshold (um)
sizeROI=this.ROIsizeCalib*this.camCalibration;

rangeArea=[pi*((NominalDiameter-deltaDiameter)/2*calibration)^2,pi*((NominalDiameter+deltaDiameter)/2*calibration)^2];
rangePerimeter=[2*pi*(NominalDiameter-deltaDiameter)/2*calibration,2*pi*(NominalDiameter+deltaDiameter)/2*calibration];

% binarize image and filtering by area,perimeter and circularity
medianFilter=cv.medianBlur(imageIn,'KSize',this.binaryFilterKernel_calibrationPlate);
BinaryThreshold=cv.threshold(medianFilter,'Otsu','Type','Binary','MaxValue',255);
Binary = imbinarize(BinaryThreshold);

imageF1 = bwpropfilt(Binary,'area',rangeArea);
imageF2 = bwpropfilt(imageF1,'perimeter',rangePerimeter);
stats = regionprops(imageF2,'Circularity');
L = bwlabel(imageF2);
imageF3=imageF2;

% delete all the objects with circularity less than 0.8
for i=1:length(stats)
    if stats(i).Circularity<0.8
        imageF3(L==i)=0;
    end
end

% output images
imagesOut{1}=imageF1;
imagesOut{2}=imageF2;
imagesOut{3}=imageF3;

% info about elements (circles) found
CC=bwconncomp(imageF3);
stats = regionprops(imageF3,'Centroid');
% cases depending on elements number(circles) were found

switch CC.NumObjects
    case 1 % just 1 circle detected, no possible ROI detection
    ROI=0;
    vertex=0;
    return
    case 2 % 2 circles detected, ROI detection if circles are not consecutive
    centroid_1=stats(1).Centroid;
    centroid_2=stats(2).Centroid;
    dist=sqrt((centroid_2(1)-centroid_1(1))^2+(centroid_2(2)-centroid_1(2))^2);
    if dist >(this.NominalLongDistance-5)*this.camCalibration && dist < (this.NominalLongDistance+5)*this.camCalibration  
    center=(centroid_1+centroid_2)/2; 
    else
    ROI=0;
    vertex=0;
    return
    end
    case 3 % 3 circles detected, ROI center calculated as middle point between opposite circles 
    centroid_1=stats(1).Centroid;
    centroid_2=stats(2).Centroid;
    centroid_3=stats(3).Centroid;
    dist1=sqrt((centroid_2(1)-centroid_1(1))^2+(centroid_2(2)-centroid_1(2))^2);
    dist2=sqrt((centroid_3(1)-centroid_1(1))^2+(centroid_3(2)-centroid_1(2))^2);
    dist3=sqrt((centroid_3(1)-centroid_2(1))^2+(centroid_3(2)-centroid_2(2))^2);
    if dist1>dist2 && dist1>dist3
    center=(centroid_1+centroid_2)/2;
    elseif dist2>dist1 && dist2>dist3
    center=(centroid_1+centroid_3)/2; 
    elseif dist3>dist1 && dist3>dist2
    center=(centroid_2+centroid_3)/2; 
    end
    case 4 % 4 circles detected, ROI center calculated as the mass center of all of them
    centroid_1=stats(1).Centroid;
    centroid_2=stats(2).Centroid;
    centroid_3=stats(3).Centroid; 
    centroid_4=stats(4).Centroid;
    center=(centroid_1+centroid_2+centroid_3+centroid_4)/4;         
end

[ROI,vertex]=this.ROIbuilder(image,center,sizeROI);

end

function match = CalibrationFidFinder(this,image)
% 
% CalibrationFidFinder  Look for calibration plate fiducial into given image.
%    inputs: 
%       this: instance which calls the method
%       image: original image to find circles
%    outputs:
%     match: structure with next fields
%         Center: coordenates of the center of the fiducial.
%         Images: Useful images of the matching.

kernel=this.binaryFilterKernel_calibration;
calibration=this.camCalibration;

% Passing image to gray if it is RGB
if length(size(image))==3
imageIn = rgb2gray(image);
else
    imageIn=image;
end

% calling ROI builder
[ROI,vertex,imagesROIbuilder]=this.CalibrationFiducialROIBuilder(imageIn);
if ROI==0
    disp('matching error, error by detecting the ROI');
        match.Center=0;
return
end

% looking for circles
medianFilter=cv.medianBlur(ROI,'KSize',kernel);
circles = cv.HoughCircles(medianFilter,'MinDist',this.minDist,'Param1',100,'Param2',5,'MinRadius',10.5*calibration,'MaxRadius',12*calibration);
[m,n]=size(circles);

% calculating center of the fiducial depending on number of fiducials detected %

switch n
    case 1  % just 1 circle detected
        disp('just 1 circle detected, match failed')
        match.Center=0;
        return
    case 2 % 2 circles detected
        center_1=circles{1};
        center_2=circles{2};
        dist=sqrt((center_2(1)-center_1(1))^2+(center_2(2)-center_1(2))^2);
        if dist >65*this.camCalibration && dist < 75*this.camCalibration   % checking that circles are opposite
        match.Center=(center_1+center_2)/2; 
        else
        disp('just 2 circles detected, match failed')
        match=0;
        return
        end
    case 3  % 3 circles detected
        center_1=circles{1};
        center_2=circles{2};
        center_3=circles{3}; 
        dist1=sqrt((center_2(1)-center_1(1))^2+(center_2(2)-center_1(2))^2);
        dist2=sqrt((center_3(1)-center_1(1))^2+(center_3(2)-center_1(2))^2);
        dist3=sqrt((center_3(1)-center_2(1))^2+(center_3(2)-center_2(2))^2);
        if dist1 > dist2 && dist1 > dist3
        match.Center=(center_1+center_2)/2; 
        elseif dist2 > dist1 && dist2 > dist3
        match.Center=(center_1+center_3)/2;
        elseif dist3 > dist1 && dist3 > dist2
        match.Center=(center_2+center_3)/2;
        end
    case 4  % 4 circles detected. Applied fit. 
        fit=this.fit_square(circles);
        match.Center=fit(1:2);
        
end
match.Circles=circles;
centerFid=[match.Center(1),match.Center(2)];
match.Center=[match.Center(1)+vertex(1),match.Center(2)+vertex(2)];

for i=1:n
    X(i)=circles{i}(1);
    Y(i)=circles{i}(2);
    R(i)=circles{i}(3);
end

% plots of circles detected %
fig1=figure('visible','off','Position', get(0, 'Screensize'));
subplot(3,1,1)
imshow(image)
title('original image')
subplot(3,1,2)
imshow(medianFilter)
title('ROI')
subplot(3,1,3)
imshow(medianFilter)
title('Circles detected')
hold on
viscircles([X' Y'],R);
hold on 
plot(centerFid(1),centerFid(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);

fig2=figure('visible','off','Position', get(0, 'Screensize'));
imshow(image)
title('Calibration plate fiducial matched')
hold on
plot(match.Center(1),match.Center(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);

fig3=figure('visible','off','Position', get(0, 'Screensize'));
imshow(medianFilter)
title('Circles detected')
hold on
viscircles([X' Y'],R);
hold on 
plot(centerFid(1),centerFid(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);

fig2image=getframe(fig1);
plotImage=fig2image.cdata;
match.Images{1}=plotImage;

fig2image=getframe(fig2);
plotImage=fig2image.cdata;
match.Images{2}=plotImage;

fig2image=getframe(fig3);
plotImage=fig2image.cdata;
match.Images{3}=plotImage;

match.Images{4}=imagesROIbuilder{1};
match.Images{5}=imagesROIbuilder{2};
match.Images{6}=imagesROIbuilder{3};

end

function sol = fit_square (this,vertex)
% fit_square fit a perfect square to the 4 centers of the circles. Used with fiducial matching for calibration plate.
% input: vertex: cell array with 4 points of the circles detected
% output: sol: array with the optimum value for the 4 fitted parameters (X, Y, width, rotation)
 
X0(1)=vertex{1}(1);
X0(2)=vertex{2}(1);
X0(3)=vertex{3}(1);
X0(4)=vertex{4}(1);

Y0(1)=vertex{1}(2);
Y0(2)=vertex{2}(2);
Y0(3)=vertex{3}(2);
Y0(4)=vertex{4}(2);

% condiciones iniciales (parece que no afectan mucho a la convergencia con este solver..)
cond_t0=[0.5 0.5 0 0.4];

% Implemento funcion %
fun = @(x)(X0(1)-(x(1)-(x(4)/sqrt(2))*cos(x(3)+pi/4)))^2+(Y0(1)-(x(2)-(x(4)/sqrt(2))*sin(x(3)+pi/4)))^2 ...
    + (X0(2)-(x(1)-(x(4)/sqrt(2))*cos(pi/4-x(3))))^2+(Y0(2)-(x(2)+(x(4)/sqrt(2))*sin(pi/4-x(3))))^2 ...
    + (X0(3)-(x(1)+(x(4)/sqrt(2))*cos(pi/4+x(3))))^2+(Y0(3)-(x(2)+(x(4)/sqrt(2))*sin(pi/4+x(3))))^2 ...
    + (X0(4)-(x(1)+(x(4)/sqrt(2))*cos(pi/4-x(3))))^2+(Y0(4)-(x(2)-(x(4)/sqrt(2))*sin(pi/4-x(3))))^2;
    
% Fijo número de iteraciones %
options = optimset('MaxFunEvals',1000);

% ejecuto el solver %
sol=fminsearch(fun,cond_t0,options);

end

function [calibration,match] = calibrationCamera (this,image)
% calculate pixel/microns relation for the camera
% input: image: image of a calibration plate fiducial
% output: calibration: pixel/um relation

%defining values of the fiducials (um)
circlesDistanceMin=50;

%sending image to circles detection
match=this.CalibrationFidFinder(image);

%calculating distance between circles
n=length(match.Circles);
distance=zeros(1,n-1);
for i=1:n-1
distance(i)=point2point(match.Circles{1}(1:2),match.Circles{i+1}(1:2));
end

%removing higher distance
distance(distance==max(distance))=[];

%calculating calibration value (pixel/um)
calibration = mean(distance/circlesDistanceMin);


end

function distance = point2point(M1, M2)
% GIVEN 2 SETS OF POINTS (SAME LENGTH!), AND CALCULATE
% DISTANCE FROM THE SECOND ONE TO THE FIRST ONE POINT TO POINT
% Outcome hte vector with the distances BETWEEN THE POINTS

d1=size(M1);
d2=size(M2);
for h=1:d2(1)
    if d1(1)==3
    dis_v=[M1(h,1)-M2(h,1) M1(h,2)-M2(h,2) M1(h,3)-M2(h,3)];
    distance(h)=norm(dis_v);
    else
    dis_v=[M1(h,1)-M2(h,1) M1(h,2)-M2(h,2)];
    distance(h)=norm(dis_v);  
    end
end
end  

function pointGCS = image2gantryCoordinates(this, pointICS, imageCenter, sizeImage)
% transform point form image coordinate system to gantry coordinate systemç
%
% this function receives the coordenates of a point in image reference system (origin in top left corner) and transforms it into Gantry reference system.
%
% inputs
%   this: instance of this class
%   pointICS: point in image coordinate system ([x,y]pixels)
%   imageCenter: Coordinate of the center of the image in gantry system ([x,y]mm)
%   sizeImage: Vector with the image size. this is the image where the point is observed. ([row,columns])
% outputs
%   pointGCS: angle offset camera-gantry.




% translation from top left corner to cente of the image
centerImage=[sizeImage(2)/2,sizeImage(1)/2];
transformationImage2Center=transform2D();
transformationImage2Center.translate([-centerImage(1),-centerImage(2)]);
pointICScentro=transformationImage2Center.M*[pointICS(1);sizeImage(1)-pointICS(2);1];


% rotation from Image system to Gantry system
rotation=transform2D();
rotation.rotate(-this.angleCamera);
pointICSrotated=rotation.M*[pointICScentro(1);pointICScentro(2);1];

% rotation transformation angle 90
rotation90=transform2D();
rotation90.rotate(-pi/2);
pointICSrotated90=rotation90.M*[pointICSrotated(1);pointICSrotated(2);1];



% translation from Imge system to Gantry system
translate=transform2D();
translate.translate([imageCenter(1),imageCenter(2)]);
pointGCS(:)=translate.M*[pointICSrotated90(1)/this.camCalibration/1000;pointICSrotated90(2)/this.camCalibration/1000;1];

end
end

end
