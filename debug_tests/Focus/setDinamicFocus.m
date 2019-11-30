function [data, ImageTime, metadata, Z, Ztime, dataF, ImageTimeF, metadataF] = setDinamicFocus(gantry,cam,range,velocity)
%setDinamicFocus taking dinamic images around optimal focus to characterize focus
%   gantry: gantry instance. It has to be connected
%   cam: Cam instance. It has to be connected
%   range: window where characterization will take place
%   Velocity: Z velocity during images capturing(positive value!!) 

%  general constants %
outputPathResults='';   % save the txt results files
zaxis=4;
cont=1;
resultsFile=strcat(outputPathResults,'DinamicFocus.txt');
% setting size of the slots for incoming data %
data=cell(100);
ImageTime=cell(100);
metadata=cell(100);
Z=zeros(100);
Ztime=zeros(100);
% fileID = fopen(resultsFile,'w');

% movin Z stage to the starting point %
gantry.moveBy(zaxis,-range/2,velocity);
gantry.WaitForMotion(zAxis,-1);

% setting initial Z
Z0=gantry.GetPosition(zaxis);

% starting video adquisition %
cam.startAdquisition;

% starting movement %
gantry.FreeRunZ1(velocity)
currentPosition=gantry.GetPosition(zaxis);

% starting measurement loop %
while(abs(currentPosition-Z0)<range)
[data{cont},ImageTime{cont},metadata{cont}]=cam.RetrieveData;
Z(cont)=gantry.GetPosition(zaxis);
Ztime(cont)=clock;
currentPosition=Z(cont);
dimension=size(data(cont));
Image=data{cont}(:,:,1,dimension(4));
nameImage=strcat('nameImage_',num2str(cont));
cam.saveFrame(Image,nameImage,2);
cont=cont+1;
end

% stopping gantry %
gantry.MotionStop(zaxis);

% taking final camera data %
[dataF,ImageTimeF,metadataF]=cam.RetrieveData;

% stoping cam adquisition %
cam.stopAdquisition

end