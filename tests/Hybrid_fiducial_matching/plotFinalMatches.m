function plotImage = plotFinalMatches (scene,objeto,ROI,Temp,Affine2d)
% 
% plotFinalMatches plot a figure with the corresponding final matches for the object and the scene
% 
% input1: matches1 correspond to the final matches struct (as it is from symTest function)
% input2: keypoints from query image (ROI from original image)
% input3: keypoints from train image (template)
% input4: affine 2d tranformation matrix 
%       [cos(theta)*s, -sin(theta)*s, tx;
%        sin(theta)*s,  cos(theta)*s, ty])

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


% plotImage=fig;
fig2image=getframe(fig);
plotImage=fig2image.cdata;

end



