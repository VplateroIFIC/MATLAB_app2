classdef LOADING < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        %         setup
        gantry
        fid
        cam
        
        GantryPos
        Fid_img
        Fid_IC
        Fid_GC
%         deltaCamToPickup = [-236.7839, 139.6969, nan,nan,nan,nan]
        deltaCamToPickup = [-96.4353, 26.3812, NaN, -47.0531,nan,nan]

        PickPos
        SensorMiddle
        
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
            % Constructor function this = STAGES(Nsite)
            % Arguments: setup, camera % Setup, gantry or owis object
            % Returns: object %

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
        end
        
        
        function milimeters = pixel2mm(this,pixels)
            % Function pixel2mm 
            % Arguments: pixels % Image coordinates in pixels
            % Returns: coordinates in mm %
            camcalibration=1.74             % Must be loaded from camera configuration
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
%             x = 1024;
%             y = 768;

            [x,y] = getpts;
            this.cam.DispCamOff
            this.Fid_IC{n} = [x,y];
            this.Fid_img{n} = this.cam.OneFrame;
            
            % Plot it in order to check
            this.PlotCheck (n);
            
            % Change to Gantry Coordinates
            [x,y] = this.Img2Gantry(this.Fid_IC{n});
            
            % Create the position vector for gantry
            this.Fid_GC{n} = this.gantry.GetPositionAll;
            this.GantryPos = this.gantry.GetPositionAll;
            this.Fid_GC{n}(this.gantry.vectorX) = x;
            this.Fid_GC{n}(this.gantry.vectorY) = y;
        end
        
        function [x,y] = Img2Gantry(this, Img_Coord)
            %             angle=1.5540-90;
                         angle = 89.0393;
            
            R = rotx(angle);
            R = [cosd(angle),-sind(angle);sind(angle),cosd(angle)];
            
            %R = [0.0168, -0.9999 ; 0.9999, 0.0168];
            img = this.cam.OneFrame;
            center = size(img)/2;

            %% Inverting  X-Y
            centerx = center(2);
            centery = center(1);
            center = [centerx, centery]
            
            coordenadas = Img_Coord
            CoordenadasClick(1) = Img_Coord(1) - center(1);
            CoordenadasClick(2) = -(Img_Coord(2) - center(2));
            CoordenadasPixRotados = CoordenadasClick*R;
%            xImage = this.pixel2mm(CoordenadasPixRotados(1));
%            yImage = this.pixel2mm(CoordenadasPixRotados(2));
%            Coordenadasmm = [xImage,yImage];
            Coordenadasmm = this.pixel2mm(CoordenadasPixRotados);
            
            %             xImage = xImage-xImage*cos(alfa)
            
            x = this.gantry.GetPosition(this.gantry.X) + Coordenadasmm(1);
            y = this.gantry.GetPosition(this.gantry.Y) + Coordenadasmm(2);
        end
        
        function intersection = CalculateCenter(this, F1, F2, F3, F4)
            % function CalculateCenter(this)
            % Arg: F1, F2, F3, F4
            % Return: crosspoint
            % Trace a line between F1-F3 and F2-F4 and get the crosspoint
            
            x13 = [F1(1), F3(1)];
            y13 = [F1(2), F3(2)];
            
            x24 = [F2(1), F4(1)];
            y24 = [F2(2), F4(2)];
            
            p1 = polyfit(x13,y13,1);
            p2 = polyfit(x24,y24,1);
            x_intersect = fzero(@(x) polyval(p1-p2,x),3);
            y_intersect = polyval(p1,x_intersect);
            
            Ft = [F1;F2;F3;F4];
            z = mean(Ft(1:4,4));
            intersection = [x_intersect, y_intersect, nan, z, nan, nan];
        end
        
        function PickTool (this,PickUpTool)
            load ('TablePositions.mat','PickupPosition')
            touch = TOUCHDOWN(this.gantry);
            this.PickPos = PickupPosition.(PickUpTool);
            
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
        
        function PickModule (this)
            touch = TOUCHDOWN(this.gantry);

            this.deltaCamToPickup = [-103.7998   25.4743       NaN  -23.2301       NaN       NaN]
            this.SensorMiddle = this.CalculateCenter(this.Fid_GC{1}, this.Fid_GC{2}, this.Fid_GC{3}, this.Fid_GC{4})
            ModulePickPos = this.SensorMiddle + this.deltaCamToPickup;
            
            this.gantry.Move2Fast(ModulePickPos,'Z1',ModulePickPos(this.vectorZ1)+10,'wait',true)
            this.gantry.WaitForMotionAll;
            disp(" Please, check that gantry is in the correct position ");
            pause
            contact = touch.runTouchdown(this.gantry.Z1,ModulePickPos(this.gantry.vectorZ1));
            if ~contact.contact
                disp ("Contact not reached")
                return
            end
            
            disp(" Wait until pickuptool drops ");
            pause
            this.gantry.MoveTo(this.gantry.Z1,-10,1)
            this.gantry.MoveTo(this.gantry.U, 0,1)
            
            this.gantry.Move2Fast(ModulePickPos,'Z1',ModulePickPos(this.vectorZ1)+10,'wait',true)
            this.gantry.WaitForMotionAll;
            disp(" Please, check that gantry is in the correct position ");
            pause
            contact = touch.runTouchdown(this.gantry.Z1,ModulePickPos(this.gantry.vectorZ1));
            if ~contact.contact
                disp ("Contact not reached")
                return
            end
            
            disp(" Close vaccum 2 ");
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
        
        %%  Plotting usefull information %%
        
        function PlotCheck (this, n, varargin)
            
            p = inputParser();
            p.KeepUnmatched = false;
            p.CaseSensitive = false;
            p.StructExpand  = false;
            p.PartialMatching = true;
            
            addParameter (p, 'Focus' , false)
            addParameter (p, 'Center' , true)
            addParameter (p, 'Wait' , true)
            addParameter (p, 'TakePic' , false)
            
            parse( p, varargin{:} )
            ip = p.Results;
            img = this.Fid_img{n};
            
            figure(n), imshow(img);
            
            if (ip.Focus)
                focus = FOCUS(this.gantry, this.cam,1);
                focus.AutoFocus
            end
            
            if (ip.TakePic)
                this.Fid_img{n} = this.cam.OneFrame;
            end
            
            if (ip.Center)
                this.cam.PlotCenter(n)
            end
            
            if (ip.Wait)
                pause
            end
            this.PlotCoord(n, [this.Fid_IC{n}(1), this.Fid_IC{n}(2)])
        end
        
        function PlotCoord (this, n, coordinates)
            hold on
            axis on
            figure(n), plot(coordinates(1), coordinates(2), 'go', 'MarkerSize', 200)%, 'LineWidth', 2);
            figure(n), plot(coordinates(1), coordinates(2), 'g+', 'MarkerSize', 200)%, 'LineWidth', 2);
            figure(n), plot(coordinates(1), coordinates(2), 'go', 'MarkerSize', 20)%, 'LineWidth', 2);
            figure(n), plot(coordinates(1), coordinates(2), 'go', 'MarkerSize', 50)%, 'LineWidth', 2);
            figure(n), plot(coordinates(1), coordinates(2), 'go', 'MarkerSize', 150)%, 'LineWidth', 2);
            figure(n), plot(coordinates(1), coordinates(2), 'go', 'MarkerSize', 100)%, 'LineWidth', 2);
        end
        
        function info=GetInfo(this)
            info.PickPos = this.PickPos;
            info.Fid_img = this.Fid_img;
            info.Fid_IC = this.Fid_IC;
            info.Fid_GC = this.Fid_GC;
            info.Fid_img = this.Fid_img;
            info.GantryPosition = this.GantryPos;
        end
        
        
        %         function [X,Y] = pixel2micra([PX,PY])
        %             % Converting pixel to micra
        %             X = PX/camCalibration;
        %             Y = PY/camCalibration;
        %         end
        
        
        %% Old functions to be deleted
        function info = CalcFiducial(this,n)
            % function CalcFiducial(this)
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

