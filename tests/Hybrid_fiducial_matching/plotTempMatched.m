function plotImage=plotTempMatched (image,temp,Affine2D)

% this function plot the centre an the edges of the template over the query image
% input 1: query image (usually this is the ROI!)
% input 2: template (train)
% input3: Affine transformation matrix (output from AffinePartial2d 
%       [cos(theta)*s, -sin(theta)*s, tx;
%        sin(theta)*s,  cos(theta)*s, ty])
%    
% Output: plot the original image with the matched template over it

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


imageSize=size(image);
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


% plotImage=fig;
fig2image=getframe(fig);
plotImage=fig2image.cdata;

end

