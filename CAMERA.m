classdef CAMERA
    %CAMERA Class that manage different cameras of out setup (input constructor required)
%     old camera Gantry high resolution --> 1
%     camera Gantry visual inspection --> 2
%     camera OWIS high resolution --> 3
%     camera OWIS visual inspection --> 4
%     camera Gantry high resolution --> 5
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

           addpath('cameras_config')
        switch cameraType
            case 1
                CAMERA_properties_Gantry_old_camera        %Imaging source DFK
                this.ReturnedColor=ReturnedColor; 
                this.ROIPos=ROIPos;     
                this.ExposureM =ExposureM;        
                this.ImageOutput=ImageOutput;  
                this.calibration=calibration; 
                this.trigger=trigger;      
                this.videoAdaptor=videoAdaptor;
            case 2
                CAMERA_properties_visual_inspection     % 050-IR
                this.ROIPos=ROIPos;
                this.ImageOutput=ImageOutput;
                this.triggerConfig=triggerConfig;
                this.videoAdaptor=videoAdaptor;
                this.ExposureAuto=ExposureAuto;
                this.GainAuto=GainAuto;
            case 3
                CAMERA_properties_OWIS              % Net gige cam
                this.ROIPos=ROIPos;
                this.ImageOutput=ImageOutput;
                this.triggerConfig=triggerConfig;
                this.videoAdaptor=videoAdaptor;
                this.ExposureAuto=ExposureAuto;
            case 4
                CAMERA_properties_visual_inspection         % 050-IR
                this.ROIPos=ROIPos;
                this.ImageOutput=ImageOutput;
                this.triggerConfig=triggerConfig;
                this.videoAdaptor=videoAdaptor;
                this.ExposureAuto=ExposureAuto;
                this.GainAuto=GainAuto;
            case 5
                CAMERA_properties_Gantry        % 040-IR
                this.ROIPos=ROIPos;
                this.ImageOutput=ImageOutput;
                this.triggerConfig=triggerConfig;
                this.videoAdaptor=videoAdaptor;
                this.ExposureAuto=ExposureAuto;
                this.GainAuto=GainAuto;

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
               this.IsConnected=1;
               case 3
               this.cam = videoinput(this.videoAdaptor,1); 
               triggerconfig(this.cam, this.triggerConfig);
               src = getselectedsource(this.cam);
               src.ExposureAuto = this.ExposureAuto;
%                src.GainAuto = this.GainAuto;
               this.IsConnected=1;
               case 4
               this.cam = videoinput(this.videoAdaptor, 2, 'RGB8Packed');
%               this.cam = videoinput(this.videoAdaptor,2); 
               triggerconfig(this.cam, this.triggerConfig);
               src = getselectedsource(this.cam);
               src.ExposureAuto = this.ExposureAuto;
               src.GainAuto = this.GainAuto; 
               this.IsConnected=1;
               case 5
               this.cam = videoinput(this.videoAdaptor, 2);
               this.cam.ROIPosition=this.ROIPos;
               triggerconfig(this.cam, this.triggerConfig);
               src = getselectedsource(this.cam);
               src.ExposureAuto = this.ExposureAuto;
               src.GainAuto = this.GainAuto; 
               set(this.cam, 'TriggerFrameDelay', 25);
               set(this.cam, 'FramesPerTrigger', 1);
               set(this.cam, 'TriggerRepeat', Inf);
               src.TriggerDelay = 15;
               
                this.IsConnected=1;
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
            start(this.cam);
            Image=getdata(this.cam);
            stop(this.cam);
        end
        
%%  DispFrame Display current frame in a figure   %%  
        function DispFrame(this)
            start(this.cam);
            pic=getdata(this.cam);
            stop(this.cam);
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
            pic=this.OneFrame;
            fullname=strcat(this.ImageOutput,name,extension);
            imwrite(pic,fullname);
            disp('frame saved')
        end

%%  startAdquisition start the camera adquisition with infinite number of frames   %%           
        function startAdquisition(this)
            set(this.cam, 'FramesPerTrigger', Inf);
            start(this.cam);
        end
        
%%  stopAdquisition stop the camera adquisition  %%           
        function stopAdquisition(this)
        stop(this.cam);
        end
   
%%  retrieveData retrieve the current logged data. Used during adquisition is ON  %%           
        function data=retrieveData(this)
        data=getdata(this.cam);
        end        
        
        end      
 end       
        
        

