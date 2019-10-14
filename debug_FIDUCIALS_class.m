clc
clear all

addpath('FiducialsPictures');
addpath('F:\Gantry_code\Matlab_app\tests\fiducialMatching\FiducialsPictures');
addpath('F:\Users\leon\Documents\MoC_CernBox\GANTRY-IFIC\Tests_results\Fiducial_images\Fiducial_chip_images_NewOptics_20190306')
addpath('F:\mexopencv');
addpath('F:\mexopencv\opencv_contrib');
fid=FIDUCIALS;

%% testing ROIBuilder %%


image=imread('Image_3_1_2.jpg');
[m,n,p]=size(image);
center=[n/2,m/2];

ROI=fid.ROIbuilder(image,center);

% figure(1)
% subplot(1,2,1)
% imshow(image)
% subplot(1,2,2)
% imshow(ROI)


%% testing FROIBuilder %%

image=imread('Image_3_1_2.jpg');
ROI=fid.FROIbuilder(image);

% figure(2)
% subplot(1,2,1)
% imshow(image)
% subplot(1,2,2)
% imshow(ROI)


%% testing prepareImage %%

image=imread('Image_3_1_2.jpg');
kernel=9;
threshold=41;
[prepared,images]=fid.prepareImage(image,kernel,threshold);

% figure(3)
% subplot(1,2,1)
% imshow(image)
% subplot(1,2,2)
% imshow(prepared)


%% testing matchSURF %%

% image=imread('Image_3_1_2.jpg');
% temp=imread('FinFidGray.jpg');
% match=fid.matchSURF(image,temp);

%% testin FmatchSURF %%


image=imread('Image_3_1_2.jpg');
match=fid.FmatchSURF(image);



