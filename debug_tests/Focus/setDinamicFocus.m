function [resultsImages] = setDinamicFocus(gantry,cam,range,velocity)
%setDinamicFocus taking dinamic images around optimal focus to characterize focus
%   gantry: gantry instance. It has to be connected
%   cam: Cam instance. It has to be connected
%   range: window where characterization will take place
%   Velocity: Z velocity during images capturing(positive value!!) 
tic
Zaxis=4;
% starting Z
origin=gantry.GetPosition(Zaxis);
%  general constants %
outputPathResults='C:\Users\Pablo\Desktop\output_images_results_Gantry\';   % save the txt results files

cont=1;
resultsFile=strcat(outputPathResults,'DinamicFocus.txt');
% setting size of the slots for incoming data %
data=cell(100);
ImageTime=cell(100);
metadata=cell(100);
Z=zeros(100,1);
ZtimeBefore=zeros(100,6);
ZtimeAfter=zeros(100,6);
% fileID = fopen(resultsFile,'w');

% movin Z stage to the starting point %
gantry.MoveBy(Zaxis,-range/2,velocity);
gantry.WaitForMotion(Zaxis,-1);

% setting initial Z
Z0=gantry.GetPosition(Zaxis);

% starting video adquisition.
cam.startAdquisition;

    

% starting movement %
gantry.FreeRunZ1(velocity)
currentPosition=gantry.GetPosition(Zaxis);

% starting measurement loop %
while(abs(currentPosition-Z0)<range)
% [data{cont},ImageTime{cont},metadata{cont}]=cam.RetrieveData;
ZtimeBefore(cont,:)=clock;        % time before get position
Z(cont)=gantry.GetPosition(Zaxis);
ZtimeAfter(cont,:)=clock;        % time After get position
currentPosition=Z(cont);
cont=cont+1;
end

% stopping gantry %
gantry.MotionStop(Zaxis);

% stoping cam adquisition %
cam.stopAdquisition
toc

% taking final camera data %
[dataF,imageTimeF,metadataF]=cam.retrieveData;

resultsImages.images=dataF;
resultsImages.time=imageTimeF;
resultsImages.metadata=metadataF;
resultsImages.Z=Z;
resultsImages.ZtimeBefore=ZtimeBefore;
resultsImages.ZtimeAfter=ZtimeAfter;

namePath=strcat(outputPathResults,'results.mat');
save(namePath,'resultsImages')


% taking Gantry to the starting point
gantry.MoveTo(Zaxis,origin,0.1);
gantry.WaitForMotion(Zaxis,-1);
Zfinal=gantry.GetPosition(Zaxis);

[resX,resY,rgb,frames]=size(dataF);


% saving images in outup folder
for i=1:frames
   image=dataF(:,:,1,i);
   nameImageFile=strcat(outputPathResults,'DinamicFocus_',num2str(i),'.png');
   imwrite(image,nameImageFile);
end



end