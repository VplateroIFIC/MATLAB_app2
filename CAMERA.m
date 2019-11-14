classdef CAMERA
    %UNTITLED Summary of this class goes here
properties (Access=private)  
          
ReturnedColor;
ROIPos;
ExposureM;
ImageOutput;
cam;
calibration; 
trigger;
videoAdaptor;
end
properties (Access=public)
IsConnected=0; 
end
    
    methods
        function this=CAMERA(setup)
 %% CAMERA constructor %%
 % generates instance and load properties script %
        switch setup
            case 1
                CAMERA_properties_Gantry
            case 2
                CAMERA_properties_OWIS
        end
        
        this.ReturnedColor=ReturnedColor; % we take gayscale images from camera
        this.ROIPos=ROIPos;     % resolution of the camera
        this.ExposureM =ExposureM;         % auto tuning for the exposure
        this.ImageOutput=ImageOutput;  % folder to save the images
        this.calibration=calibration;  %um/pixel calibration of the camera
        this.trigger=trigger;       % manual trigger for taking images
        this.videoAdaptor=videoAdaptor;    %
        end
        
 %% Connect Camera connection, setting all properties %%      
        function this=Connect(this)
           % creating camera object, opening preview % 
           imaqreset
           this.cam = videoinput(this.videoAdaptor,1);
           % settting properties of camera object %
           src = getselectedsource(this.cam);
           this.cam.ReturnedColorSpace=this.ReturnedColor;
           this.cam.ROIPosition=this.ROIPos;
           src.ExposureMode = this.ExposureM;
           % seting manual trigger (better performance %)
           triggerconfig(this.cam, this.trigger);
           start(this.cam)
           this.IsConnected=1;
           disp('Camera connection done');
        end
        
 %%  Disconnect Camera  %%   
        function this=Disconnect(this)
            stop(this.cam)
            delete(this.cam);
            this.IsConnected=0;
            imaqreset
        end
        
%%  OneFrame return current frame of the camera (image)   %%   
        function Image = OneFrame(this)
            Image=getsnapshot(this.cam);
        end
        
%%  DispFrame Display current frame in a figure   %%  
        function DispFrame(this)
            pic=getsnapshot(this.cam);
            imshow(pic);
        end
       
%%  DispCam display camera video in a independent windows   %%             
        function DispCam(this)
        figure('Name', 'Camera Display'); 
        uicontrol('String', 'Close', 'Callback', 'close(gcf)'); 
        vidRes = this.cam.VideoResolution; 
        nBands = this.cam.NumberOfBands; 
        hImage = image( zeros(vidRes(2), vidRes(1), nBands) ); 
        preview(this.cam, hImage); 
        end
 
%%  DispCamOff close the display of the camera   %%           
        function DispCamOff(this)
        close;
        end
        
%%  SaveFrame Save one frame in the ImagePath folder in the specified format   %%   
        function SaveFrame(this,name,format)
            switch format
                case 1
                    extension='.tif';
                case 2
                    extension='.png';
                case 3
                    extension='.jpg';
            end
            pic=getsnapshot(this.cam);
            fullname=strcat(this.ImageOutput,name,extension);
            imwrite(pic,fullname);
            disp('frame saved')
        end
        end
end
    


