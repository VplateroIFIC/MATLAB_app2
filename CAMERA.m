classdef CAMERA
    %UNTITLED Summary of this class goes here
    properties (Access=private)  
% setting the properties of the object %        
ReturnedColor='grayscale';
ROIPos=[0 0 3856 2764];
ExposureM = 'manual';
ImageOutput='tests\images\';
cam;
CamStatus;
IsConnected=0;
    end
    
    methods
 %% Connect Camera connection, setting all properties %%      
        function this=Connect(this)
           % creating camera object, opening preview % 
           imaqreset
           this.cam = videoinput('winvideo',1);
           % settting properties of camera object %
           src = getselectedsource(this.cam);
           this.cam.ReturnedColorSpace=this.ReturnedColor;
           this.cam.ROIPosition=this.ROIPos;
           src.ExposureMode = this.ExposureM;
           % seting manual trigger (better performance %)
           triggerconfig(this.cam, 'manual');
           start(this.cam)
           this.IsConnected=1;
           disp('connection done')
           
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
    


