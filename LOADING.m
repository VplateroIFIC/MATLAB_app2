classdef LOADING < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
%         setup
        gantry
        fid
        cam
        
        Fid_img
        Fid_IC
        Fid_GC
        
        PickPos
        
        vectorX;
        vectorY;
        vectorZ1;
        vectorZ2;
        vectorU;
    end
    
    methods
        
%         FIDUCIALS_properties_Gantry.m
%         addpath('Fiducial_config');
        
        function this = LOADING(setup,camera)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
%             addpath("./Loading_config/")
            this.fid=FIDUCIALS(1);
            this.gantry = setup;
            this.cam = camera;
            
            if ~this.gantry.IsConnected
                this.gantry.Connect;
            end
            
            this.vectorX = this.gantry.vectorX;
            this.vectorY = this.gantry.vectorY;
            this.vectorZ1 = this.gantry.vectorZ1;
            this.vectorZ2 = this.gantry.vectorZ2;
            this.vectorU = this.gantry.vectorU;
            
            addpath('Loading_config');
%             load ('TablePositions.mat','PickupPosition')
% %             load ('.\Loading_config\TablePositions.mat','PickupPosition');
%             this.PickupPosition = PickupPosition;
%             disp(this.PickupPosition.R0)
        end
        
        
        function milimeters = pixel2mm(this,pixels)
            camcalibration=1.74
%             camcalibration=1.7319
            milimeters = (pixels/camcalibration)/1000;
        end
        
        function TakeFiducial(this,n)
            % function TakeFiducial(this)
            % Arg: n       % Fiducial number we are taking
            % Return: none
            % Take the fiducial coordinates and get its position
            % on gantry coordinate system (GC)
            
            this.cam.DispCamOff;
            this.Fid_img{n} = this.cam.OneFrame;
            this.cam.DispCam(n);
            this.cam.PlotCenter(n);
            pause
            
            % Take one fiducial position
            [x,y] = getpts;
%             x = 1.7120e+03;
%             y = 674.6825;
%             x = 1.0e+03 * 1.5840 
%             y = 1.0e+03 * 0.6942
%             x = 470.5000;
%             y = 875.5000;
            this.cam.DispCamOff
            this.Fid_IC{n} = [x,y];
            this.Fid_img{n} = this.cam.OneFrame;
            
            % Plot it in order to check
            this.PlotCheck (n);
            
            % Change to Gantry Coordinates
            [x,y] = this.Img2Gantry(this.Fid_IC{n});  
            
            % Create the position vector for gantry
            this.Fid_GC{n} = this.gantry.GetPositionAll;
            this.Fid_GC{n}(this.gantry.vectorX) = x;
            this.Fid_GC{n}(this.gantry.vectorY) = y;
        end
        
        function [x,y] = Img2Gantry(this, Img_Coord)
%             angle=1.5540-90;
            angle = 89.0393;
%             R = rotx(angle);
%             R = [cosd(angle),-sind(angle);sind(angle),cosd(angle)];
            
            R = [0.0168, -0.9999 ; 0.9999, 0.0168];
            img = this.cam.OneFrame;
            center = size(img)/2;
%             center = size(this.Fid_img{1})/2;
            %%Invertimos X-Y
            centerx = center(2);
            centery = center(1);
            center =[centerx, centery]
            
            coordenadas = Img_Coord
            CoordenadasClick(1) = Img_Coord(1) - center(1)
            CoordenadasClick(2) = -(Img_Coord(2) - center(2))
            CoordenadasPixRotados = CoordenadasClick*R
            xImage = this.pixel2mm(CoordenadasPixRotados(1));
            yImage = this.pixel2mm(CoordenadasPixRotados(2));
            Coordenadasmm = [xImage,yImage]
            
%             xImage = xImage-xImage*cos(alfa)
            
            x = this.gantry.GetPosition(this.gantry.X) + Coordenadasmm(1);
            y = this.gantry.GetPosition(this.gantry.Y) + Coordenadasmm(2);
        end
        
        function intersection = CalculateCenter(this, F1, F2, F3, F4)
            % function CalculateCenter(this)
            % Arg: F1, F2, F3, F4
            % Return: crosspoint
            % Trace a line between F1-F3 and F2-F4 and get the crosspoint

            x13 = [F1(1), F2(1)];
            y13 = [F1(2), F2(2)];
            
            x24 = [F2(1), F4(1)];
            y24 = [F2(2), F4(2)];
            
            p1 = polyfit(x13,y13,1);
            p2 = polyfit(x24,y24,1);
            x_intersect = fzero(@(x) polyval(p1-p2,x),3);
            y_intersect = polyval(p1,x_intersect);
            
            intersection = [x_intersect, y_intersect];
        end
        
        function Pick (this,module)
            load ('TablePositions.mat','PickupPosition')
            touch = TOUCHDOWN(this.gantry);
            this.PickPos = PickupPosition.(module)
%             switch module
%                 case 'R0'
%                     this.PickPos = PickupPosition.R0;
%                 case 'R1'
%                     this.PickPos = PickupPosition.R1;
%                 case 'R2'
%                     this.PickPos = PickupPosition.R2;
%                 case 'Jig1'
%                     this.PickPos = PickupPosition.Jig1;
%                 otherwise
%                     disp("La cagaste") 
%             end
            this.gantry.Move2Fast(this.PickPos,'Z1',+10, 'Z2', 30,'wait',true)
            this.gantry.WaitForMotionAll;
            disp(" Please, check that gantry is in the correct position ");
            pause
            contact = touch.runTouchdown(this.gantry.Z1,this.PickPos(this.gantry.vectorZ1));
            if ~contact.contact
                disp ("Contact not reached")
                return
            end
            disp(" Open vaccum 2 ");
            pause
            this.gantry.MoveTo(this.gantry.Z1,-10,1)
            this.gantry.WaitForMotionAll;
            disp(" Please, check that Pickup R0 have been taken correctly  ");
            pause
        end
        
        
        function DropPickup (this,module)
            load ('TablePositions.mat','PickupPosition')
            this.PickPos = PickupPosition.(module);
%             switch module
%                 case 'R0'
%                     PicPos = this.PickupPosition.R0;
%                 case 'R1'
%                     PicPos = this.PickupPosition.R1;
%                 otherwise
%                     disp("La cagaste")
%             end

            this.gantry.Move2Fast(this.PickPos,'Z1',this.PickPos(this.vectorZ1)+10, 'Z2', 20,'wait',true)
            this.gantry.WaitForMotionAll;
            this.gantry.MoveTo(this.gantry.Z1,this.PickPos(this.vectorZ1)+1,1)
            this.gantry.WaitForMotionAll;
            disp(" Please, close vaccum 2 and wait until pickup drops ");
            pause
            this.gantry.MoveTo(this.gantry.Z1,this.PickPos(this.vectorZ1)+20,5)
            this.gantry.WaitForMotionAll;
            disp(" Please, check that Pickup have been dropped correctly  ");
            pause
%             this.PickPos = nan;
        end
        
        function PlotCenter (this, n, imagen)
            switch nargin
                case '2'
                    imagen = this.cam.OneFrame;
%                     break;
                case '3'
                    figure(n), imshow(imagen);
%                     break;
                otherwise
                    imagen = this.cam.OneFrame;
                    disp ("No hay imagen")
            end
                hold on
                axis on
                [x,y]=size(imagen);
                center = [y/2, x/2];
                center(1)
                center(2)
                
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 200)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'r+', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 50)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 150)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 100)%, 'LineWidth', 2);
                pause
        end
        function PlotCheck (this, n, varargin)
            
            p = inputParser();
            p.KeepUnmatched = false;
            p.CaseSensitive = false;
            p.StructExpand  = false;
            p.PartialMatching = true;
            
            addParameter (p, 'Focus' , false)
            addParameter (p, 'Center' , true)
            addParameter (p, 'Wait' , false)
            addParameter (p, 'TakePic' , false)
            addParameter (p, 'TakeClick' , false)
            
            parse( p, varargin{:} )
            ip = p.Results;
            
            if (ip.Focus)
                focus = FOCUS(this.gantry, this.cam,1);
                focus.AutoFocus
            end
            
            if (ip.TakePic)
                this.Fid_img{n} = this.cam.OneFrame;
            end
            
            if (ip.TakeClick)
                                
                this.cam.DispCam(n)

                hold on
                axis on
                [x,y]=size(this.Fid_img{n});
                center = [y/2, x/2];
                center(1)
                center(2)
                
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 200)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'r+', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 50)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 150)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 100)%, 'LineWidth', 2);
                pause
                [x,y] = getpts;
                this.Fid_IC{n} = [x,y];
                this.cam.DispCamOff;
            end
            
            if (ip.Center)
                                
                figure(n), imshow(this.Fid_img{n});
                hold on
                axis on
                [x,y]=size(this.Fid_img{n});
%                 center(1) = n/2;
%                 center(2) = m/2;
                center = [y/2, x/2];
                center(1)
                center(2)
                
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 200)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'r+', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 50)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 150)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 100)%, 'LineWidth', 2);
                pause
            else 
                figure(n), imshow(this.Fid_img{n});
                hold on
                axis on
            end

            if (ip.Wait)
                pause
            end
            
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'go', 'MarkerSize', 200)%, 'LineWidth', 2);
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'g+', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'go', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'go', 'MarkerSize', 50)%, 'LineWidth', 2);
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'go', 'MarkerSize', 150)%, 'LineWidth', 2);
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'go', 'MarkerSize', 100)%, 'LineWidth', 2);
        end
        
        
          function PlotCoord (this, n, coordinates, varargin)
            
            p = inputParser();
            p.KeepUnmatched = false;
            p.CaseSensitive = false;
            p.StructExpand  = false;
            p.PartialMatching = true;
            
            addParameter (p, 'Focus' , false)
            addParameter (p, 'Center' , true)
            addParameter (p, 'Wait' , false)
            addParameter (p, 'TakePic' , false)
            addParameter (p, 'TakeClick' , false)
            
            parse( p, varargin{:} )
            ip = p.Results;
            
            if (ip.Focus)
                focus = FOCUS(this.gantry, this.cam,1);
                focus.AutoFocus
            end
            
            if (ip.TakePic)
                this.Fid_img{n} = this.cam.OneFrame;
            end
            
                this.cam.DispCamOff;                
                this.cam.DispCam(n)

                hold on
                axis on
                img = this.cam.OneFrame;
                [x,y]=size(img);
                center = [y/2, x/2];
                center(1)
                center(2)
                
                figure(n), plot(coordinates(1), coordinates(2), 'ro', 'MarkerSize', 200)%, 'LineWidth', 2);
                figure(n), plot(coordinates(1), coordinates(2), 'r+', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(coordinates(1), coordinates(2), 'ro', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(coordinates(1), coordinates(2), 'ro', 'MarkerSize', 50)%, 'LineWidth', 2);
                figure(n), plot(coordinates(1), coordinates(2), 'ro', 'MarkerSize', 150)%, 'LineWidth', 2);
                figure(n), plot(coordinates(1), coordinates(2), 'ro', 'MarkerSize', 100)%, 'LineWidth', 2);
                pause
                [x,y] = getpts;
                this.Fid_IC{n} = [x,y];
                this.cam.DispCamOff;
            
            if (ip.Center)
                                
                figure(n), imshow(this.Fid_img{n});
                hold on
                axis on
                [x,y]=size(this.Fid_img{n});
%                 center(1) = n/2;
%                 center(2) = m/2;
                center = [y/2, x/2];
                center(1)
                center(2)
                
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 200)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'r+', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 20)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 50)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 150)%, 'LineWidth', 2);
                figure(n), plot(center(1), center(2), 'ro', 'MarkerSize', 100)%, 'LineWidth', 2);
                pause
            else 
                figure(n), imshow(this.Fid_img{n});
                hold on
                axis on
            end

            if (ip.Wait)
                pause
            end
            
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'go', 'MarkerSize', 200)%, 'LineWidth', 2);
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'g+', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'go', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'go', 'MarkerSize', 50)%, 'LineWidth', 2);
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'go', 'MarkerSize', 150)%, 'LineWidth', 2);
            figure(n), plot(this.Fid_IC{n}(1), this.Fid_IC{n}(2), 'go', 'MarkerSize', 100)%, 'LineWidth', 2);
        end
        
        function info=GetInfo(this)
        info.PickPos = this.PickPos;
        info.Fid_img = this.Fid_img;
        info.Fid_IC = this.Fid_IC;
        info.Fid_GC = this.Fid_GC;
        info.Fid_img = this.Fid_img;
%         
%         PickPos
        end
        
        
%         function [X,Y] = pixel2micra([PX,PY])
%             % Converting pixel to micra
%             X = PX/camCalibration;
%             Y = PY/camCalibration;
%         end
        

%% To delete
 function info = CalcFiducial(this,n)
            % function TakeFiducial(this)
            % Arg: n       % Fiducial number we are taking
            % Return: none
            % Take the fiducial coordinates and get its position
            % on gantry coordinate system (GC)
            
            fiducial1_True = [133.1863, -358.8931, NaN, 13.3203, 0, 0];
            fidudial1_First = [133.4717, -359.2647, 0, 13.3203, 0, 0];
 
%             this.Fid_IC{n} = [387.1, 1218];
            this.Fid_IC{n} = [387.1, 1283.6];
            
            % Plot it in order to check
%             this.PlotCheck (n);
            
            % Change to Gantry Coordinates
            [x,y] = this.Img2Gantry(this.Fid_IC{n});  
            
            % Create the position vector for gantry
            this.Fid_GC{n} = fidudial1_First;
            this.Fid_GC{n}(this.gantry.vectorX) = x;
            this.Fid_GC{n}(this.gantry.vectorY) = y;
            
            info.DespCalc = fidudial1_First - this.Fid_GC{n};
            info.DespReal = fidudial1_First - fiducial1_True;
            info.fiducial1_True = fiducial1_True;
            info.fiducial1 = fidudial1_First;
        end
        
    end
end

