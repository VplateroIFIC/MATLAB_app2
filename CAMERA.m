classdef CAMERA < handle
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
%                     src.GainAuto = this.GainAuto;
                    this.IsConnected=1;
                    set(this.cam, 'TriggerFrameDelay', 25);
                    set(this.cam, 'FramesPerTrigger', 1);
                    set(this.cam, 'TriggerRepeat', Inf);
                    src.TriggerDelay = 15;
%                     src.TriggerMode = 'On';
                case 4
                    this.cam = videoinput(this.videoAdaptor, 1, 'RGB8Packed');
                    triggerconfig(this.cam, this.triggerConfig);
                    src = getselectedsource(this.cam);
                    src.ExposureAuto = this.ExposureAuto;
                    src.GainAuto = this.GainAuto;
                    this.cam.ReturnedColorspace = 'grayscale';
                    set(this.cam, 'TriggerFrameDelay', 25);
                    set(this.cam, 'FramesPerTrigger', 1);
                    set(this.cam, 'TriggerRepeat', Inf);
                    warning('off','imaq:gentl:hardwareTriggerTriggerModeOff');
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
%                     src.ExposureTime = 1200;
                    
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
            this.startAdquisition;
            [data, ~, ~]=this.retrieveDataOneFrame;
            this.stopAdquisition;
            Image=data;
        end
        
        %%  DispFrame Display current frame in a figure   %%
        function DispFrame(this)
            this.startAdquisition;
            [data, ~, ~]=this.retrieveDataOneFrame;
            this.stopAdquisition;
            pic=data;
            imshow(pic);
        end
        
        %%  DispCam display camera video in a independent windows   %%
        function DispCam(this,n)% plotcenter)
%             switch (nargin)
%                 case 3
%                     %center = true;
%                 case 2
%             
%                 case 1
%                     n=1;
%                 otherwise
%             end
            if nargin == 2
%                 figure(n)
%                 pause
            else
%                 figure(1)
                    n = 1;
            end
            fig2=figure(n);
            fig2.Name='Camera Display';
            fig2.Position = [1355 577 560 420];
%             figure('Name', 'Camera Display');
%             uicontrol('String', 'Close', 'Callback', 'close(gcf)');
            uicontrol('Parent', fig2, 'String', 'Close', 'Callback', 'close(gcf)');
            vidRes = [this.ROIPos(3),this.ROIPos(4)];
            nBands = this.cam.NumberOfBands;
            hImage = image( zeros(vidRes(2), vidRes(1), nBands) );
            preview(this.cam, hImage);
            
%             if center
%                 this.PlotCenter(n)
%             end
        end
        
        function PlotCenter (this, n)
            switch nargin
                case '1'
                    n = 1;
% %                     break;
                otherwise
                    imagen = this.OneFrame;
                    disp ("No hay imagen")
            end
                hold on
                axis on
                [x,y]=size(imagen);
                center = [y/2, x/2];
                center(1);
                center(2);
                
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 200)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'r+', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 50)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 150)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 100)%, 'LineWidth', 2);
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
        
        %%  retrieveDataAllFrames retrieve the current logged data. Used during adquisition is ON  %%
        function [data, time, metadata]=retrieveDataAllFrames(this)
            [data, time, metadata] =getdata(this.cam);
            while isempty(data)==1
                [data, time, metadata] =getdata(this.cam);
            end
        end
        
        %%  retrieveDataOneFrame retrieve the current logged data. Used during adquisition is ON  %%
        function [data, time, metadata]=retrieveDataOneFrame(this)
            [data, time, metadata] =getdata(this.cam,1);
            while isempty(data)==1
                [data, time, metadata] =getdata(this.cam,1);
            end
        end
        
        %%  retrieveDataNFrames retrieve the current logged data. Used during adquisition is ON  %%
        function [data, time, metadata]=retrieveDataNFrames(this,N)
            [data, time, metadata] =getdata(this.cam,N);
            while isempty(data)==1
                [data, time, metadata] =getdata(this.cam,N);
            end
        end
        
        %%  ResetAdquisitionBuffer Remove data from memory buffer used to store acquired image frames  %%
        function ResetAdquisitionBuffer(this)
            flushdata(this.cam);
        end
        
        
    end
end



