function setStaticFocus(gantry,cam,range,Nimages)
%setStaticFocus taking static images around optimal focus to characterize focus
% Gantry and camera objects have to be created and the devices have to be connected
%   gantry: gantry instance. It has to be connected
%   cam: Cam instance. It has to be connected
%   range: window where characterization will take place
%   Nimages: number of images to be taken
outputPathResults='C:\Users\Pablo\Desktop\output_images_results_Gantry\';
velocity=1;
Zaxis=4;
delta=range/Nimages;
Z0=gantry.GetPosition(Zaxis);

% movin Z stage to the starting point %
gantry.MoveBy(Zaxis,-range/2,velocity);
gantry.WaitForMotion(Zaxis,-1);

% starting data adquisition %
cam.startAdquisition;

% Starting the measure loop %
Z=zeros(Nimages);
images=zeros(2048,1536,1,Nimages);
for i=1:Nimages
    [data,time,medatada]=cam.retrieveData;
    [resx,resy,color,frame]=size(data);
    images(:,:,Nimages)=data(:,:,1,frame);
    Z(i)=gantry.GetPosition(Zaxis);
    gantry.MoveBy(Zaxis,delta,velocity);
    gantry.WaitForMotion(Zaxis,-1);
end
 gantry.MoveTo(Zaxis,Z0,velocity);
 gantry.WaitForMotion(Zaxis,-1);
 
 % saving results %
 results.Images=images;
 results.Zvalues=Z;
 namePath=strcat(outputPathResults,'results.mat');
 save(namePath,'results')
 
end

