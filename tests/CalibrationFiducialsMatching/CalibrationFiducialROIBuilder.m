function [ROI,center]=CalibrationFiducialROIBuilder(imageIn)

% 
% CalibrationFiducialROIBuilder  generate square ROI around caibration plate fiducial. It locate the fiducial centroid by reading the pixel area
%    inputs: 
%       this: instance which calls the method
%       image: original image to extract the ROI

     
%    outputs:
%       ROI: region of interest around calibration fiducial.

calibration=3.62483;
NominalDiameter=22;  % nominal diameter of the circles
deltaDiameter=2.5;    % range of threshold
size=500;

area=pi*(NominalDiameter/2*calibration)^2;
perimeter=2*pi*(10*calibration);

rangeArea=[pi*((NominalDiameter-deltaDiameter)/2*calibration)^2,pi*((NominalDiameter+deltaDiameter)/2*calibration)^2];
rangePerimeter=[2*pi*(NominalDiameter-deltaDiameter)/2*calibration,2*pi*(NominalDiameter+deltaDiameter)/2*calibration];

% if size(imageIn,3)==3
% imageIn = rgb2gray(imageIn);
% end

Binary = imbinarize(imageIn);
% BynaryInv=imcomplement(Binary);

imageF1 = bwpropfilt(Binary,'area',rangeArea);
imageF2 = bwpropfilt(imageF1,'perimeter',rangePerimeter);
CC=bwconncomp(imageF2);

if CC.NumObjects >4
stats = regionprops(imageF2,'Circularity');
L = bwlabel(imageF2);
imageF3=imageF2;
for i=1:length(stats)
    if stats(i).Circularity<0.8
        imageF3(L==i)=0;
    end
end
else
    imageF3=imageF2;
end

prop = regionprops(imageF3,'centroid');

center=(prop(1).Centroid+prop(2).Centroid+prop(3).Centroid+prop(4).Centroid)/4;

% fig=figure, imshow(Binary);
% hold on
% plot(center(1),center(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);

% fig2image=getframe(fig);
% plotImage=fig2image.cdata;
% image=plotImage;

ver1=[center(1)-size/2,center(2)-size/2];
ver2=[center(1)+size/2,center(2)-size/2];
ver3=[center(1)+size/2,center(2)+size/2];
ver4=[center(1)-size/2,center(2)+size/2];

ROI=imageIn(ver1(2):ver3(2),ver1(1):ver3(1),:);

