classdef LOADING < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    %% To be done:
    % On STAGES class, "Move2Fast" Method add option to increment or
    % decrement Z1, instead of just adding a final position.
    % Maybe add a property '+Z1', not just 'Z1'.
    % Add option to skip zsecurityHeigh
    
    % On STAGES class, "Motion cannot start because the motor is disabled"
    % error should not produce a return from program,
    % instead should wait user instructions
    
    % Touchdown object created for Module or Tool (carefully, not carefully)
    % That means, speed, deltaPrimary and deltaSecondary
    
    % Touchdown object should know estimated hightness of the module/Tool???
    
    % Introduce inputs (Yes/NO) when asking the user to open/close vacuum.
    
    % Create a Method "DropModule"
    
    % Calculate module rotation from the fiducial coordinates.
    % That should be done for initial and final module position.
    % ¿Incluide it on the "CalculateCenter" method.
    
    % Add petal object, load from "TablePositions.mat"???
    % Add method "PetalLocate", take petalLocators and create petal object
    % Save petalLocators coordinates and save it in a file as
    % "lastPetalLocators" or similar, forcing user to locate the petal
    % again
    
    % Change method "CalculateCenter" input arguments to an array of
    % coordinates. More clear to use. Return (X,Y,NaN,Z1,NaN,U).
    
    %Move2Fast method. Add Optional input (laser, Pickup, Camera).
    
    
    
    %% Properties
    properties (Access = public)
        %         setup
        gantry
        fid
        cam
        
        GantryPos
        Fid_img
        Fid_IC
        Fid_GC
        
        % Must move that to configuration file.
        %deltaCamToPickup = [-103.7998   25.4743       NaN  -23.2301       NaN       NaN]
        
        PickPos
        SensorMiddle
        petal
        tool;   % Tool we are working with
        module; % Module we are working with
        
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
        
        function loadPositions (this)
            load ('TablePositions.mat','PickupPosition')
            this.PickPos = PickupPosition;
        end
        
        function milimeters = pixel2mm(this,pixels)
            % Function pixel2mm
            % Arguments: pixels % Image coordinates in pixels
            % Returns: coordinates in mm %
            milimeters = (pixels/this.cam.camCalibration)/1000;
        end
        
        %         function PetalLocate (this, petalSide)
        %             % function PetalLocate (this, petalSide)
        %             % Arguments: petalSide, % petalSide (0 for EoS right, 1 for EoS left)
        %             % Return: none
        %             % Take the petal locators of the petal in order to update it's position
        %             % and creates petal object
        %
        %             switch nargin
        %             case 2
        %             case 1
        %                 petalSide = 0;
        %             otherwise
        %                 disp "Incorrect input arguments"
        %             end
        %
        %             % Take both Petal-locators and create petal object
        %             this.TakeFiducial(petal, 1)
        %             locators = [this.Fid_GC.petal{1}]
        %             this.TakeFiducial(petal, 2)
        %             locators = [this.Fid_GC.petal{1};this.Fid_GC.petal{2}]
        %
        %             distance = pdist([locators(1,1:2), locators(2,1:2);
        % %             if (distance >= 601 + 0.01) || (discante <= 601 - 0.01)
        % %                 warning(" Petal-locators distance is %0.3f, it should be between (%0.3f - %0.3f", distance, 601 - 0.01, 601 + 0.01)
        % %                 pause
        % %             end
        %             this.petal = PETALCS(petalSide, locators(1,:), locators(2,:);
        %         end
        %
        function loadFiducials(this,module)
            modulePosition_old = this.loadFid(module);
            save ('./Loading_config/ModulePosition.mat', 'modulePosition_old', '-append')
            this.Fid_GC = modulePosition_old;
        end
        function TakeFiducial(this, module, n)
            % function TakeFiducial(this)
            % Arg: module, n       % Module to be located, fiducial number we are taking
            % Return: none
            % Take the fiducial coordinates and get its position
            % on gantry coordinate system (GC)
            
            switch nargin
                case 2
                case 1
                    n = 4;
                otherwise
                    disp ("Incorrect input arguments")
            end
            if isnan(n)
                disp ("Input arguments error")
                return
            end
            
            switch module
                case 'R0'
                    this.tool = 'Tool0'
                case 'R1'
                    this.tool = 'Tool0'
                case 'R2'
                    this.tool = 'Tool0'
                case 'R3S0'
                    this.tool = 'Tool1'
                case 'R3S1'
                    this.tool = 'Tool2'
                case 'R4S0'
                case 'R4S1'
                case 'R5S0'
                case 'R5S1'
                otherwise
                    fprintf ('\n\t Error, "%s" is not a valid module name: ', module);
                    disp('"R0", "R1", "R2", "R3S0", "R3S1", "R4S0", "R4S1", "R5S0", "R5S1"');
                    return
            end
            %       lastPosition = this.loadFid(module);
            %       gantry.Move2Fast(lastPosition.(module){n});
            
            this.cam.DispCamOff;
            this.Fid_img.(module){n} = this.cam.OneFrame;
            this.cam.DispCam(n);
            this.cam.PlotCenter(n);
            pause
            
            % Take one fiducial position
            %             x = 1024;
            %             y = 768;
            
            [x,y] = getpts;
            this.cam.DispCamOff
            this.Fid_IC.(module){n} = [x,y];
            this.Fid_img.(module){n} = this.cam.OneFrame;
            
            % Plot it in order to check
            this.PlotCheck (module, n);
            
            answer = questdlg('¿Save data?', ...
                'Sento is asking something', ...
                'Save','Discard', 'Keep it for now', 'Keep it for now');
            % Handle response
            switch answer
                case 'Save to file'
                    saveData = true;
                    disp([answer ' coming right up'])
                case 'Discard'
                    disp([answer 'this.Fid_GC.(module){n} '])
                    return
                case 'Keep it for now'
                    saveData = false;
                    disp('Whatever we decide in the future')
            end
            
            % Change to Gantry Coordinates
            [x,y] = this.Img2Gantry(this.Fid_IC.(module){n});
            
            % Create the position vector for gantry
            this.Fid_GC.(module){n} = this.gantry.GetPositionAll;
            this.GantryPos = this.gantry.GetPositionAll;
            this.Fid_GC.(module){n}(this.gantry.vectorX) = x;
            this.Fid_GC.(module){n}(this.gantry.vectorY) = y;
            
            if saveData
                this.saveFid(module);
            end
            
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
        
        function rotation = calculateRotation(this,module)%, F1, F2, F3, F4)
            
            %Must be moved to the correct place
            PetalLocator_1 = [133.1885 -358.8875         nan   13.3203         nan         nan];
            PetalLocator_2 = [277.2484  224.5027       NaN   13.8901         nan         nan];
            this.petal = PETALCS(0, PetalLocator_1, PetalLocator_2);
            
            %Loading theorical fiducials on sensor coordinates
            for i=1:4
                x(i) = (this.petal.fiducials_sensors.R0{i}(1));
                y(i) = (this.petal.fiducials_sensors.R0{i}(2));
            end
            
            lowerLineX = [x(1),x(4)];
            lowerLineY = [y(1),y(4)];
            upperLineX = [x(2),x(3)];
            upperLineY = [y(2),y(3)];
            
            lowerLine = polyfit(lowerLineX,lowerLineY,1);
            alfa.SensorLower = atand(lowerLine(1));
            
            upperLine = polyfit(upperLineX,upperLineY,1);
            alfa.SensorUpper = atand(upperLine(1));
            
            
            for i=1:4
                x(i) = (this.petal.fiducials_gantry.R0{i}(1));
                y(i) = (this.petal.fiducials_gantry.R0{i}(2));
                %                fiducialsOnSensor{i}(4) = -28;
            end
            
            lowerLineX = [x(1),x(4)];
            lowerLineY = [y(1),y(4)];
            upperLineX = [x(2),x(3)];
            upperLineY = [y(2),y(3)];
            
            lowerLine = polyfit(lowerLineX,lowerLineY,1);
            alfa.PetalLower = atand(lowerLine(1));
            
            upperLine = polyfit(upperLineX,upperLineY,1);
            alfa.PetalUpper = atand(upperLine(1));
            
            fiducials = this.Fid_GC.(module);
            for i=1:4
                x(i) = (fiducials{i}(1));
                y(i) = (fiducials{i}(2));
                %                fiducialsOnSensor{i}(4) = -28;
            end
            
            lowerLineX = [x(1),x(4)];
            lowerLineY = [y(1),y(4)];
            upperLineX = [x(2),x(3)];
            upperLineY = [y(2),y(3)];
            
            lowerLine = polyfit(lowerLineX,lowerLineY,1);
            alfa.LowerLine = atand(lowerLine(1));
            
            upperLine = polyfit(upperLineX,upperLineY,1);
            alfa.UpperLine = atand(upperLine(1));
            
            disp (alfa)
            rotation = alfa.LowerLine;
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
            try
                z = mean(Ft(1:4,4));
            catch 'Index in position 2 exceeds array bounds (must not exceed 3).'
                z = NaN;
            end
            
            intersection = [x_intersect, y_intersect, nan, z, nan, nan];
        end
        
        function PickTool (this,Tool)
            load ('TablePositions.mat','PickupPosition')
            touch = TOUCHDOWN(this.gantry,'hard');
%             this.PickPos = PickupPosition.(PickUpTool);
            
            this.gantry.Move2Fast(PickupPosition.(Tool),'Z1',+10, 'Z2', 30,'wait',true)
            this.gantry.WaitForMotionAll;
            disp(" Please, check that gantry is in the correct position ");
            answer = questdlg('Please, check that gantry is in the correct position', ...
                'Sento is asking something', ...
                'Yes');
            disp([' Users answer ->' answer])

            % Handle response
            switch answer
                case 'Yes'

                otherwise
                    disp([answer ' -> Skip'])
                    return
            end
            
            contact = touch.runTouchdown(this.gantry.Z1,PickupPosition.(Tool)(this.gantry.vectorZ1));
            if ~contact.contact
                disp ("Contact not reached")
                return
            end
            answer = questdlg(' Please, open vaccum 2 ', ...
                'Sento is asking something', ...
                'Continue', 'Skip');
            disp([' Users answer ->' answer])

            % Handle response
            switch answer
                case 'Continue'
                otherwise
                    return
            end
            this.gantry.MoveTo(this.gantry.Z1,-10,1)
            this.gantry.WaitForMotionAll;
            answer = questdlg([' Please, check that Pickup "' Tool '" have been taken correctly  '], ...
                'Sento is asking something', ...
                'Continue', 'Skip', 'Continue');
            % Handle response
            disp([' Users answer: ' answer])
            switch answer
                case 'Continue'
                    disp([' Tool "' Tool '" has been picked correctly'])
                    this.tool = Tool;
                otherwise
                    disp(' Something is wrong ')
                    return
            end
        end
        
        function DropTool (this)
            load ('TablePositions.mat','PickupPosition')
            this.PickPos = PickupPosition.(this.tool);
            
            this.gantry.Move2Fast(this.PickPos,'Z1',this.PickPos(this.vectorZ1)+10, 'Z2', 20,'wait',true)
            this.gantry.WaitForMotionAll;
            this.gantry.MoveTo(this.gantry.Z1,this.PickPos(this.vectorZ1)+1,1)
            this.gantry.WaitForMotionAll;
            disp(' Please, close vaccum 2 and wait until pickup drops ');
            answer = questdlg(' Please, close vaccum 2 and wait until pickup drops ', ...
                'Sento is asking something', ...
                'Continue', 'Skip', 'Skip');
            disp([' Users answer ->' answer])
            % Handle response
            switch answer
                case 'Continue'
                    
                otherwise
                disp([answer ' -> Skip'])
                    return
            end
            this.gantry.MoveTo(this.gantry.Z1,this.PickPos(this.vectorZ1)+20,5)
            this.gantry.WaitForMotionAll;
            disp(" Please, check that Pickup have been dropped correctly  ");
            answer = questdlg(' Please, check that Pickup have been dropped correctly  ');
            disp([' Users answer ->' answer])
            
            % Handle response
            switch answer
                case 'Yes'
                    this.tool = 'empty';
                otherwise
                disp([' Something went wrong, tool "' this.tool '" still picked'])
                    return
            end
        end
        
        function PickModule (this,module)
            load ('TablePositions.mat','PickupPosition')
            % Create Touchdown object for module
            touch = TOUCHDOWN(this.gantry, 'sensor');
            % Calculating center and creating ModulePickCoordinates
            this.SensorMiddle = this.CalculateCenter(this.Fid_GC.(module){1}, this.Fid_GC.(module){2}, this.Fid_GC.(module){3}, this.Fid_GC.(module){4})
            ModulePickPos = this.SensorMiddle + this.cam.deltaCamToPickup;
            % Calculate rotation angle
            alfa = this.calculateRotation(module);
            rotation = alfa.LowerLine -90 + PickupPosition.(this.tool)(this.gantry.vectorU);
            ModulePickPos(this.gantry.vectorU) = rotation;

            
            % Move to ModulePickCoordinates and drop the PickupTool on the module
            this.gantry.Move2Fast(ModulePickPos,'Z1',ModulePickPos(this.vectorZ1)+10,'wait',true);
            %             this.gantry.WaitForMotionAll;

            disp(" Please, check that gantry is in the correct position ");
            answer = questdlg(' Please, check that gantry is in the correct position ');
            disp([' Users answer ->' answer])
            
            % Handle response
            switch answer
                case 'Yes'
                    
                otherwise
                disp([answer ' -> Skip'])
                    return
            end
            contact = touch.runTouchdown(this.gantry.Z1,ModulePickPos(this.gantry.vectorZ1));
            if ~contact.contact
                disp ("Contact not reached")
                return
            end
            
            disp(' Please, close vaccum 2 and wait about 15s until vacuum tube is empty');
            answer = questdlg(' Please, close vaccum 2 and wait until pickup drops ', ...
                'Sento is asking something', ...
                'Continue', 'Skip', 'Continue');
            disp([' Users answer ->' answer])
            % Handle response
            switch answer
                case 'Continue'
                    
                otherwise
                disp([answer ' -> Skip'])
                    return
            end
            % Move up Z1 axis and rotate U to align tool holes
            this.gantry.MoveTo(this.gantry.Z1,-10,1)
            this.gantry.WaitForMotionAll
            this.gantry.MoveTo(this.gantry.U, rotation,10,1)
            
            this.gantry.Move2Fast(ModulePickPos,'Z1',ModulePickPos(this.vectorZ1)+10,'U',rotation, 'wait',true)
            this.gantry.WaitForMotionAll;
            disp(" Please, check that gantry is in the correct position ");
            answer = questdlg(' Please, check that gantry is in the correct position ');
            disp([' Users answer ->' answer])
            
            % Handle response
            switch answer
                case 'Yes'
                    
                otherwise
                disp([answer ' -> Skip'])
                    return
            end
            contact = touch.runTouchdown(this.gantry.Z1,ModulePickPos(this.gantry.vectorZ1));
            if ~contact.contact
                disp ("Contact not reached")
                return
            end
            
            disp(" Open vaccum 2 and Close vaccum 1");
            disp(' Open vaccum 2 and Close vaccum 1');
            answer = questdlg(' Open vaccum 2 and Close vaccum 1', ...
                'Sento is asking something', ...
                'Continue', 'Skip', 'Skip');
            disp([' Users answer ->' answer])
            % Handle response
            switch answer
                case 'Continue'
                    
                otherwise
                disp([answer ' -> Skip'])
                    return
            end
            this.gantry.MoveTo(this.gantry.Z1,-10,1)
            this.gantry.WaitForMotionAll;
            disp([' Please, check that ' module ' have been taken correctly ']);
            answer = questdlg([' Please, check that ' module ' have been taken correctly ']);
            disp([' Users answer ->' answer])
            
            % Handle response
            switch answer
                case 'Yes'
                    
                otherwise
                disp([answer ' -> Skip'])
                    return
            end
        end
        
        function DropModule (this,module)
            % Create Touchdown object for module
            %             module = this.module;
            touch = TOUCHDOWN(this.gantry);
            %fiducialsOnPetal(1) = this.petal.fiducials_petal.(module);
            for i=1:4
                fiducialsOnPetal{i} = transpose(this.petal.fiducials_gantry.(module){i});
            end
            % Calculating center and creating ModulePickCoordinates
%             SensorOnPetal = this.petal.fiducials_gantry.(module);
            this.SensorMiddle = this.CalculateCenter(fiducialsOnPetal{1}, fiducialsOnPetal{2}, fiducialsOnPetal{3}, fiducialsOnPetal{4})
%             this.SensorMiddle = this.CalculateCenter(SensorOnPetal{1}, SensorOnPetal{2}, SensorOnPetal{3}, SensorOnPetal{4})
            rotation = this.calculateRotation(module) - 90;
            ModuleDropPos = this.SensorMiddle + this.cam.deltaCamToPickup;
            ModuleDropPos(this.gantry.vectorU) = rotation;
            
            % Move to ModulePickCoordinates and drop the PickupTool on the module
            this.gantry.Move2Fast(ModuleDropPos,'Z1',ModuleDropPos(this.vectorZ1)+10,'wait',true)
            %             this.gantry.WaitForMotionAll;
            disp(" Please, check that gantry is in the correct position ");
            pause
            contact = touch.runTouchdown(this.gantry.Z1,ModulePickPos(this.gantry.vectorZ1));
            if ~contact.contact
                disp ("Contact not reached")
                return
            end
            
            disp(" Please, wait about 15s until vacuum tube is empty ");
            answer = questdlg(' Please, wait about 15s until vacuum tube is empty ');
            disp([' Users answer ->' answer])
            
            % Handle response
            switch answer
                case 'Yes'
                    
                otherwise
                disp([answer ' -> Skip'])
                    return
            end
            pause
            % Move up Z1 axis and rotate U to align tool holes
            this.gantry.MoveTo(this.gantry.Z1,-10,1)
            this.gantry.MoveTo(this.gantry.U, 0,1)
            
            this.gantry.Move2Fast(ModulePickPos,'Z1',ModulePickPos(this.vectorZ1)+10,'wait',true)
            this.gantry.WaitForMotionAll;
            disp(" Please, check that gantry is in the correct position ");
            answer = questdlg(' Please, check that gantry is in the correct position ');
            disp([' Users answer ->' answer])
            
            % Handle response
            switch answer
                case 'Yes'
                    
                otherwise
                disp([answer ' -> Skip'])
                    return
            end
            contact = touch.runTouchdown(this.gantry.Z1,ModulePickPos(this.gantry.vectorZ1));
            if ~contact.contact
                disp ("Contact not reached")
                return
            end
            
            disp(" Open vaccum 2 and Close vaccum 1");
            answer = questdlg('Open vaccum 2 and Close vaccum 1', ...
            'Sento is asking something', ...
            'Continue', 'Skip', 'Skip');
            disp([' Users answer ->' answer])
            % Handle response
            switch answer
            case 'Continue'
                
            otherwise
            disp([answer ' -> Skip'])
                return
            end
            this.gantry.MoveTo(this.gantry.Z1,-10,1)
            this.gantry.WaitForMotionAll;
            disp(' Please, check that ' + module + ' have been dropped correctly  ');
            answer = questdlg(' Please, check that Pickup have been dropped correctly  ');
            disp([' Users answer ->' answer])
            
            % Handle response
            switch answer
                case 'Yes'
                    
                otherwise
                disp([answer ' -> Skip'])
                    return
            end
        end
        
        %%  Plotting usefull information %%
        
        function PlotCheck (this, module, n, varargin)
            
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
            img = this.Fid_img.(module){n};
            
            figure(n), imshow(img);
            
            if (ip.Focus)
                focus = FOCUS(this.gantry, this.cam,1);
                focus.AutoFocus
            end
            
            if (ip.TakePic)
                this.Fid_img.(module){n} = this.cam.OneFrame;
            end
            
            if (ip.Center)
                this.cam.PlotCenter(n)
            end
            
            if (ip.Wait)
                pause
            end
            this.PlotCoord(n, [this.Fid_IC.(module){n}(1), this.Fid_IC.(module){n}(2)])
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
        
        
        
        
        %% Old functions to be deleted
        
        %         function [X,Y] = pixel2micra([PX,PY])
        %             % Converting pixel to micra
        %             X = PX/camCalibration;
        %             Y = PY/camCalibration;
        %         end
        
        
        function info = CalcFiducial(this,n)
            % function CalcFiducial(this)
            % Arg: n       % Fiducial number we are taking
            % Return: none
            % Take the fiducial coordinates and get its position
            % on gantry coordinate system (GC)
            
            fiducial1_True = [133.1863, -358.8931, NaN, 13.3203, 0, 0];
            fidudial1_First = [133.4717, -359.2647, 0, 13.3203, 0, 0];
            
            %             this.Fid_IC{n} = [387.1, 1218];
            this.Fid_IC.(module){n} = [387.1, 1283.6];
            
            % Plot it in order to check
            %             this.PlotCheck (n);
            
            % Change to Gantry Coordinates
            [x,y] = this.Img2Gantry(this.Fid_IC{n});
            
            % Create the position vector for gantry
            this.Fid_GC.(module){n} = fidudial1_First;
            this.Fid_GC.(module){n}(this.gantry.vectorX) = x;
            this.Fid_GC.(module){n}(this.gantry.vectorY) = y;
            
            info.DespCalc = fidudial1_First - this.Fid_GC.(module){n};
            info.DespReal = fidudial1_First - fiducial1_True;
            info.fiducial1_True = fiducial1_True;
            info.fiducial1 = fidudial1_First;
        end
        function modulePosition=loadFid(this,module)
            load ('./Loading_config/ModulePosition.mat', 'modulePosition')
        end
        function saveFid(this,module)
            modulePosition.(module) = this.Fid_GC.(module);
            save ('./Loading_config/ModulePosition.mat', 'modulePosition', '-append')
        end
    end
end

