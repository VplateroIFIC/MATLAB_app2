% preparing new template to avoid offset between center of the F and center of the offset. I'll get a prepared image ready to SURF detection %

clc
clear all

addpath('F:\Gantry_code\Matlab_app\tests\Hybrid_fiducial_matching\templates\X');
addpath('F:\Gantry_code\Matlab_app\tests\Hybrid_fiducial_matching\templates\F');

templateGrey=imread('Fiducials_F300_22.png'); % reading image taken with 6x optics and high res camera
% templateGrey=rgb2gray(templateRGB);



fig=figure('visible','off');
imshow(templateGrey)

[P1x,P1y]=getpts(fig);

% P1x=[1490.5, 2918.5, 2150.5, 2258.5];
% P1y=[1398.5, 1298.5, 654.5, 2098.5];

center(1)=sum(P1x)/4;      %center of the fiducial
center(2)=sum(P1y)/4;

fig3=figure('visible','on');
imshow(templateGrey)
hold on
plot(P1x,P1y, 'r+', 'MarkerSize', 30, 'LineWidth', 2);
plot(center(1),center(2), 'r+', 'MarkerSize', 30, 'LineWidth', 2);
saveas(fig3,'F:\Gantry_code\Matlab_app\tests\Hybrid_fiducial_matching\templates\X\geomCenter.jpg' )

widthROI=2500;
heigthROI=1800;
columns=round(center(1))-widthROI/2:round(center(1))+widthROI/2;
rows=round(center(2))-heigthROI/2:round(center(2))+heigthROI/2;


finalTemplate=templateGrey(rows,columns);
finaltemplateGray=templateGrey(rows,columns);

figure('visible','off')
imshow(finalTemplate)
imwrite(finalTemplate,'F:\Gantry_code\Matlab_app\tests\Hybrid_fiducial_matching\templates\F\FinFid.png' );
% imwrite(finaltemplateGray,'F:\Gantry_code\Matlab_app\tests\Hybrid_fiducial_matching\templates\X\FinFidGray.png' );



