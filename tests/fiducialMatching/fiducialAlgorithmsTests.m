%% TESING FIDUCIAL FINDING ALGORITHMS %%

% clc
clear all

show='off';

% Adding picture folder to path %

addpath('FiducialsPictures');
addpath('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Fiducial_images\Fiducial_chip_images_NewOptics_20190306')


% loading original figure and template %

image0=imread('Image_0_1_7.jpg');
template=imread('ATLAS_F.jpg');

sizeImage=size(image0);  % WHATCH OUT! size returns inverted coordinated respect to image processing standard rows-->Y  columns-->Y
sizeTemplate=size(template);

% converting to grayscale %

I1 = rgb2gray(image0);
temp = rgb2gray(template);

       %%%%% creating ROI from original figure %%%%%

[Nrow,Ncol]=size(I1);
roiSize=1000;   %define size of the ROI nxn pixels
offset=[0,-150];  %displacement of the ROI respect to the center of the image
roiCenter=[Ncol/2+offset(1),Nrow/2+offset(2)]; %define center of my ROI
ver1=[roiCenter(1)-roiSize/2,roiCenter(2)-roiSize/2]; %define Vertex of my ROI [pixel x,pixel y];
ver2=[roiCenter(1)+roiSize/2,roiCenter(2)-roiSize/2];
ver3=[roiCenter(1)+roiSize/2,roiCenter(2)+roiSize/2];
ver4=[roiCenter(1)-roiSize/2,roiCenter(2)+roiSize/2];

xlim=[ver1(1) ver2(1) ver3(1) ver4(1)];
ylim=[ver1(2) ver2(2) ver3(2) ver4(2)];

BW = roipoly(I1,xlim,ylim);  % creating binary mask
Imask=I1;
Imask(BW == 0) = 0;

v=reshape(Imask,1,[]);
v (v==0)=[];

% extracting the ROI %

ROI=I1(ver1(2):ver3(2),ver1(1):ver3(1));


      %%% Apply proccessing to ROI and template (general features+threshold+cleaning) %%%

% median blur (median filter): clean the image %

kernel=[3,3];
ROI_median = medfilt2(ROI,[kernel(1),kernel(2)]);
temp_median=medfilt2(temp,[kernel(1),kernel(2)]);

% binary filter %

filter=2;  % choosing filter type [binary filter, OTSU threshold, adaptative filter]

switch filter
    case 1
      ROI_bin = imbinarize(ROI_median);
      temp_bin = imbinarize(temp_median);
    case 2
      level_1 = graythresh(ROI_median);
      level_2 = graythresh(temp);
      ROI_bin = imbinarize(ROI_median,level_1);
      temp_bin = imbinarize(temp_median,level_2);
    case 3
      level_1 = adaptthresh(ROI_median);
      level_2 = adaptthresh(temp_median);
      ROI_bin = imbinarize(ROI_median,level_1);
      temp_bin = imbinarize(temp_median,level_2);
end




% appling adaptative local threshold %

%   level_1 = adaptthresh(ROI_bin);
%   level_2 = adaptthresh(temp_bin);
%   ROI_thr = imbinarize(ROI_bin,level_1);
%   temp_thr = imbinarize(temp_bin,level_2);


% invert the binary image, cleaning small particles, and invert again %

ROI_inv = imcomplement(ROI_bin);
temp_inv = imcomplement(temp_bin);

particleSize=800;
ROI_clean = bwareaopen(ROI_inv,particleSize);
temp_clean = bwareaopen(temp_inv,particleSize);

ROI_final = imcomplement(ROI_clean);
temp_final = imcomplement(temp_clean);


% appling edge detection %

ROI_final=edge(ROI_final);
temp_final=edge(temp_final);

         %%%% applying pattern recognition algorithm (SURF) %%%%

% Find the SURF features. Saving plots %

points1 = detectSURFFeatures(ROI_final,'MetricThreshold',1000,'NumOctaves',4);
points2 = detectSURFFeatures(temp_final,'MetricThreshold',1000,'NumOctaves',4);

roiPoints=figure('visible',show);
imshow(ROI_final); hold on;
plot(points1.selectStrongest(100));
saveas(roiPoints,'FiducialsPictures\roiFeatures.jpg');

tempPoints=figure('visible',show);
imshow(temp_final); hold on;
plot(points2.selectStrongest(100));
saveas(tempPoints,'FiducialsPictures\tempFeatures.jpg');


% Extract the features %

[f1,vpts1] = extractFeatures(ROI_final,points1);
[f2,vpts2] = extractFeatures(temp_final,points2);

% Retrieve the locations of matched points %

method='Exhaustive'; % default
MatchThreshold=15; % increase quality of matches
MaxRatio=0.5; % rejecting ambiguous matches
Unique=false; % one feature can match with one feature


[indexPairs,matchMetric] = matchFeatures(f1,f2,'Method',method,'MatchThreshold',MatchThreshold,'MaxRatio',MaxRatio,'Unique',Unique);
matchedPoints1 = vpts1(indexPairs(:,1));
matchedPoints2 = vpts2(indexPairs(:,2));

% Display the matching points %

matched=figure('visible',show,'Position', get(0,'Screensize'));
hold on
showMatchedFeatures(ROI_final,temp_final,matchedPoints1,matchedPoints2);
legend('matched points 1','matched points 2');
saveas(matched, 'FiducialsPictures\matched.jpg');



%% PLOTING %%


matchImg=imread('matched.jpg');
roiFeatures=imread('roiFeatures.jpg');
tempFeatures=imread('tempFeatures.jpg');
ypos=0.09;

map=figure('visible',show,'Position', get(0,'Screensize'));
s(1)=subplot(2,9,1); imshow(image0); s(1).Position=s(1).Position+[-0.12 -0.04 0.1 0.1]+[0 -ypos 0 0 ]; title('Original Image processing -->')
s(2)=subplot(2,9,2); imshow(ROI);  s(2).Position=s(2).Position+[-0.04 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Extracting ROI')
s(3)=subplot(2,9,3); imshow(ROI_median);  s(3).Position=s(3).Position+[-0.038 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Median filter')
s(4)=subplot(2,9,4); imshow(ROI_bin);  s(4).Position=s(4).Position+[-0.035 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Binary filter')
% s(18)=subplot(2,9,5); imshow(ROI_thr);  s(4).Position=s(4).Position+[-0.035 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Binary filter')
s(5)=subplot(2,9,5); imshow(ROI_inv);  s(5).Position=s(5).Position+[-0.033 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Local Adaptative threshold')
s(6)=subplot(2,9,6); imshow(ROI_clean);  s(6).Position=s(6).Position+[-0.033 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Removing particles')
s(7)=subplot(2,9,7); imshow(ROI_final);  s(7).Position=s(7).Position+[-0.031 0 0.021 0.021]+[0 -ypos 0 0 ]; title('Inverting')
s(8)=subplot(2,9,8); imshow(roiFeatures);  s(8).Position=s(8).Position+[-0.014 0 0.035 0.035]+[0 -ypos 0 0 ]; title('Finding Features (SURF)')
s(9)=subplot(2,9,9); imshow(matchImg);  s(9).Position=s(9).Position+[0.01 -0.22 0.08 0.08]+[0 -ypos 0 0 ]; title('Matching both features maps')

s(10)=subplot(2,9,10); imshow(template);  s(10).Position=s(10).Position+[-0.12 -0.04 0.1 0.1]; title('Template processing -->')
s(11)=subplot(2,9,11); imshow(temp);  s(11).Position=s(11).Position+[-0.04 0 0.021 0.021];
s(12)=subplot(2,9,12); imshow(temp_median);  s(12).Position=s(12).Position+[-0.038 0 0.021 0.021];
s(13)=subplot(2,9,13); imshow(temp_bin);  s(13).Position=s(13).Position+[-0.035 0 0.021 0.021];
% s(19)=subplot(2,9,15); imshow(temp_thr);  s(19).Position=s(19).Position+[-0.035 0 0.021 0.021];
s(14)=subplot(2,9,14); imshow(temp_inv);  s(14).Position=s(14).Position+[-0.033 0 0.021 0.021];
s(15)=subplot(2,9,15); imshow(temp_clean);  s(15).Position=s(15).Position+[-0.033 0 0.021 0.021];
s(16)=subplot(2,9,16); imshow(temp_final);  s(16).Position=s(16).Position+[-0.031 0 0.021 0.021];
s(17)=subplot(2,9,17); imshow(tempFeatures);  s(17).Position=s(17).Position+[-0.016 0 0.04 0.04];
saveas(map, 'FiducialsPictures\fullProcess.fig');

%% GETTING TRANSROTATION SCALED (procustes function) %%

X=matchedPoints1.Location;
Y=matchedPoints2.Location;
[d,Z,transform] = procrustes(X,Y,'scaling',false);
xDelta=mean(transform.c(:,1));
yDelta=mean(transform.c(:,2));
c = transform.c;
T = transform.T;
b = transform.b;

% Z = b*Y*T + c;

%% Display ROI figure with the located area %%

figure,
imshow(ROI);
axis on
hold on;
% Plot cross at row 100, column 50
plot(xDelta,yDelta, 'r+', 'MarkerSize', 30, 'LineWidth', 2);

%% getting distance target to origin of the original image (image coordenates) and ploting %%

centerF=[(xDelta+ver1(1)),(yDelta+ver1(2))];
figure,
imshow(image0);
axis on
hold on;
plot(centerF(1),centerF(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);

%% getting distance target to center of the original image (image coordenates) and ploting %%

calibrationCamera=3.62483;
centerFfromCenter=[(xDelta+ver1(1))-sizeImage(2)/2,(yDelta+ver1(2))-sizeImage(1)/2];
dist_um=centerFfromCenter/calibrationCamera





