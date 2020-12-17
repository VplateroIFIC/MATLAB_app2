
% A_Open_OWIS

% eje.HomeAll
% eje.Home(eje.Z1)

StartPosition = [150, 100, 51 , 0, 0]
eje.GetPositionAll
eje.MoveTo(eje.X,StartPosition(1),5)
eje.MoveTo(eje.Y,StartPosition(2),10)
eje.MoveTo(eje.Z1,StartPosition(3),10)
eje.GetPositionAll

% eje.MoveToFast(StartPosition);

focus.AutoFocus

figure, imshow(image)

match = frameMatcher(fid,cam,eje)

return

match = fid.CalibrationFidFinder(image)
%Debería buscar los fiduciales circulares


[ROI,vertex,imagesOut] = CalibrationFiducialROIBuilder(fid,image)
generate square ROI around caibration plate fiducial. It locate the fiducial centroid by reading the pixel area, perimeter and
figure, imshow (imagesOut{1})
figure, imshow (imagesOut{2})
figure, imshow (imagesOut{3})

% A_Close_OWIS

