function setStaticFocus(gantry,cam,range,Nimages)
%setStaticFocus taking static images around optimal focus to characterize focus
% Gantry and camera objects have to be created and the devices have to be connected
%   gantry: gantry instance. It has to be connected
%   cam: Cam instance. It has to be connected
%   range: window where characterization will take place
%   Nimages: number of images to be taken
outputPathResults='';
velocity=1;
zaxis=4;
delta=range/Nimages;

resultsFile=strcat(outputPathResults,'staticFocus.txt');
fileID = fopen(resultsFile,'w');

% movin Z stage to the starting point %
gantry.moveBy(zaxis,-range/2,velocity);
gantry.WaitForMotion(zAxis,-1);

% Starting the measure loop %
Z=zeros(Nimages);
for i=1:Nimages
    name=strcat('StaticFocusImage_',num2str(i));
    cam.SaveFrame(name,2);
    Z(i)=gantry.GetPosition(zaxis);
    gantry.moveBy(zaxis,delta,velocity);
    gantry.WaitForMotion(zAxis,-1);
    fprintf(fileID,'%6.5f\r\n',Z(i)); 
end
 fclose(fileID);
end

