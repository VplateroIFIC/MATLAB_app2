classdef CAMERA
    %UNTITLED Summary of this class goes here
    properties   
% setting the properties of the object %        
ReturnedColor='grayscale';
ROIPos=[0 0 3856 2764];
ExposureM = 'manual';
ImageOutput='tests\images_CAMERA_class\';
cam;
CamStatus;
    end
    
    methods
        
        function Connect(this)
            %METHOD1 Camera connection, setting all properties
           % creating camera object, opening preview % 
           imaqreset
           this.cam = videoinput('winvideo',1);
           % settting properties of camera object %
           this.cam.src = getselectedsource(this);
           this.cam.ReturnedColorSpace=this.ReturnedColor;
           this.cam.ROIPosition=this.ROIPos;
           this.cam.src.ExposureMode = this.ExposureM; 
           
        end
        function Disconnect(this)
           % deleting camera object%
            delete(this.cam);
            imaqreset
        end
        function Image = OneFrame(this)
            %OneFrame return current frame of the camera (image)%
            Image=getsnapshot(this);
        end
        function DispFrame(this)
            % DispFrame Display current frame in a figure %
            pic=getsnapshot(this);
            imshow(pic);
        end
        function this=DispCam(this)
            %DispCam display camera video in a independent windows
            numFrame=0;
            this.CamStatus=1;
        while (this.CamStatus==1)
            numFrame = numFrame+1;
            [frame,ts] = snapshot(this);
            frameRate = 1./(ts-ts1);
            ts1 = ts;

            showText = sprintf('frameRate:%d\n  Frame:%d\n',round(frameRate),numFrame);
            draw = insertText(frame,[10,20],showText,'FontSize',20);
            imshow(draw);
            drawnow;
        end
        close;
        end
        
        function this=DispCamOff(this)
            % DispCamOff close the display of the camera
            this.CamStatus=0;
        end
        function StopDispCam(this)
            %DispCam stop display camera
            closepreview(this.cam);
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
            pic=getsnapshot(this);
            fullname=strcat(this.ImageOutput,name,extension);
            imwrite(pic,fullname);
        end
        end
end
    


