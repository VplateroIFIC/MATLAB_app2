classdef CAMERA
    %UNTITLED Summary of this class goes here
    properties   
% setting the properties of the object %        
ReturnedColor='grayscale';
ROIPos=[0 0 3856 2764];
ExposureM = 'manual';
ImageOutput='tests\images\';
cam;
CamStatus;
    end
    
    methods
        
        function this=Connect(this)
            %METHOD1 Camera connection, setting all properties
           % creating camera object, opening preview % 
           imaqreset
           this.cam = videoinput('winvideo',1);
           % settting properties of camera object %
           src = getselectedsource(this.cam);
           this.cam.ReturnedColorSpace=this.ReturnedColor;
           this.cam.ROIPosition=this.ROIPos;
           src.ExposureMode = this.ExposureM; 
           disp('connection done')
        end
        function Disconnect(this)
           % deleting camera object%
            delete(this.cam);
            imaqreset
        end
        function Image = OneFrame(this)
            %OneFrame return current frame of the camera (image)%
            Image=getsnapshot(this.cam);
        end
        function DispFrame(this)
            % DispFrame Display current frame in a figure %
            pic=getsnapshot(this.cam);
            imshow(pic);
        end
        function DispCam(this)
            %DispCam display camera video in a independent windows
        figure('Name', 'Camera Display'); 
        uicontrol('String', 'Close', 'Callback', 'close(gcf)'); 
        vidRes = this.cam.VideoResolution; 
        nBands = this.cam.NumberOfBands; 
        hImage = image( zeros(vidRes(2), vidRes(1), nBands) ); 
        preview(this.cam, hImage); 
        end
        
        function DispCamOff(this)
            % DispCamOff close the display of the camera
        close;
        end
        function SaveFrame(this,name,format)
            %SaveFrame Save one frame in the ImagePath folder in the specified format%
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
            disp('done')
        end
        end
end
    


