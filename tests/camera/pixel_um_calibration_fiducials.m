%% calibration um/px using fiducials of calibration plate %%

%Loading fiducial image

addpath('F:\Users\leon\Documents\SilicioGeneral\Petals\Assembly\Tests_results\Fiducial_images\OWIS_calibration\'); 
templateGrey=imread('Calibration_Fiducials_2.png'); 

%display image
fig=figure('visible','off');
imshow(templateGrey)

%getting points from image manually (points from the perimeter of any circle)
[P1x,P1y]=getpts(fig);

% fitting circle (using add on: https://es.mathworks.com/matlabcentral/fileexchange/44219-fast-circle-fitting-using-landau-method)
[Xcenter,Ycenter,R]=Landau_Smith(P1x,P1y);

%ploting circle fitted
viscircles([Xcenter,Ycenter],R);


%Calculating pixel/um value
realDiameter=22;
pixelDiameter=2*R;
um_pixel=realDiameter/pixelDiameter;
