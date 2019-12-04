function results=setStaticFocus(gantry,cam,range,Nimages)
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
Z=zeros(Nimages,1);
images=zeros(1536,2048,Nimages);
for i=1:Nimages
    cam.ResetAdquisitionBuffer;
    [data,time,medatada]=cam.retrieveDataAllFrames;
    if length(size(data))==4
    [resx,resy,color,frame]=size(data);
    else
    frame=1;
    end
    images(:,:,i)=data(:,:,1,frame);
    Z(i)=gantry.GetPosition(Zaxis);
    gantry.MoveBy(Zaxis,delta,velocity);
    gantry.WaitForMotion(Zaxis,-1);
    
    message=(['frame number ',int2str(i),' was taken']);
    disp(message)
end
cam.stopAdquisition

gantry.MoveTo(Zaxis,Z0,velocity);
 gantry.WaitForMotion(Zaxis,-1);
 
 % saving results %
 results.Images=images;
 results.Zvalues=Z;
 
%  for i=1:length(Z)
%      imOut=images(:,:,i);
%      imOutGray=mat2gray(imOut);
%      imOut_uint8=uint8(imOutGray);
%      namePic=([])
%      imwrite()
 
 namePath=strcat(outputPathResults,'results.mat');
 save(namePath,'results','-v7.3')
 
end

