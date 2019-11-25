classdef CAMERA
    %UNTITLED Class that manage different cameras of out setup (input constructor required)
%     camera Gantry high resolution --> 1
%     camera Gantry visual inspection --> 2
%     camera OWIS high resolution --> 3
%     camera OWIS visual inspection --> 4
% CHECK WHICH IS THE CHANNEL THAT THE HENTL ADAPTOR GIVES TO EACH CAMERA AND UPDATE THE CLASS!!    
    
properties (Access=private)  
          
% camera gantry props %
ReturnedColor;
ROIPos;
ExposureM;
ImageOutput;
cam;
calibration; 
trigger;
videoAdaptor;
triggerConfig;
cameraType;
ExposureAuto;
GainAuto;


end
properties (Access=public)
IsConnected=0; 
end
    
    methods
        function this=CAMERA(cameraType)
 %% CAMERA constructor %%
 % generates instance and load properties script %
        switch cameraType
            case 1
                CAMERA_properties_Gantry
                this.ReturnedColor=ReturnedColor; 
                this.ROIPos=ROIPos;     
                this.ExposureM =ExposureM;        
                this.ImageOutput=ImageOutput;  
                this.calibration=calibration; 
                this.trigger=trigger;      
                this.videoAdaptor=videoAdaptor;
            case 2
                CAMERA_properties_visual_inspection
                this.ROIPos=ROIPos;
                this.ImageOutput=ImageOutput;
                this.triggerConfig=triggerConfig;
                this.videoAdaptor=videoAdaptor;
                this.ExposureAuto=exposureAuto;
                this.GainAuto=gainAuto;
            case 3
                CAMERA_properties_OWIS
                this.ROIPos=ROIPos;
                this.ImageOutput=ImageOutput;
                this.triggerConfig=triggerConfig;
                this.videoAdaptor=videoAdaptor;
                this.ExposureAuto=exposureAuto;
                this.GainAuto=gainAuto;
            case 4
                CAMERA_properties_visual_inspection
                this.ROIPos=ROIPos;
                this.ImageOutput=ImageOutput;
                this.triggerConfig=triggerConfig;
                this.videoAdaptor=videoAdaptor;
                this.ExposureAuto=exposureAuto;
                this.GainAuto=gainAuto;
        end
        this.cameraType=cameraType;
            
        end
        
 %% Connect Camera connection, setting all properties %%      
        function this=Connect(this)
            imaqreset
            switch this.cameraType
               case 1
               % creating camera object, opening preview %
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
               case 2
               this.cam = videoinput(this.videoAdaptor,2); 
               triggerconfig(this.cam, this.triggerConfig);
               src = getselectedsource(this.cam);
               src.ExposureAuto = this.ExposureAuto;
               src.GainAuto = this.GainAuto;
               case 3
               this.cam = videoinput(this.videoAdaptor,1); 
               triggerconfig(this.cam, this.triggerConfig);
               src = getselectedsource(this.cam);
               src.ExposureAuto = this.ExposureAuto;
               src.GainAuto = this.GainAuto;

               case 4
               this.cam = videoinput(this.videoAdaptor,2); 
               triggerconfig(this.cam, this.triggerConfig);
               src = getselectedsource(this.cam);
               src.ExposureAuto = this.ExposureAuto;
               src.GainAuto = this.GainAuto;  

            end
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
    


