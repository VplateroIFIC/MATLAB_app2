classdef PetalDispensing < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        gantry;
        petal1;
        petal2;
        dispenser;
        ready = 0;
        zWaitingHeigh = 10;            % Z Position prepared to dispense
        zDispensingHeigh = 5;             % Z Position while glue dispensing
    end
    
    properties (Access = public)
        Xf1;
        Yf1;
        Xf2;
        Yf2;
        Xf3;
        Yf3;
        Xf4;
        Yf4;
        f1;
        f2;
        f3;
        f4;
        
        mLine12;
        qLine12;
        mLine34;
        qLine34;
        
        xAxis;
        yAxis;
        z1Axis;
        z2Axis;
    end
    
    properties (Constant, Access = public)
        % All units in mm
        Pitch = 3.4;
        OffGlueStartX = 5;   % Distance from the sensor edge
        OffGlueStartY = 5;
        OffGlueStart = [5,5]
        glueOffX = 0;       %Offset Between camera and syrenge
        glueoffY = 0;
        TestingZone = [-100, -100, 0, 0]; % X,Y,Z1,Z2
        
        zHighSpeed = 10;
        zLowSpeed = 5;
        
        xyHighSpeed = 20;
        xyLowSpeed = 5;
        
        dispSpeed = 15;
        
    end
    
    
    methods
        
        %% Constructor %%
        function this = PetalDispensing(dispenser_obj, gantry_obj, petal_obj)
            % Constructor function.
            % Arguments: dispense_obj, gantry_obj (Gantry or OWIS)
            % present on the setup.
            % Returns: this object
            
            % Preparing dispenser object
            this.dispenser = dispenser_obj;
            this.dispenser.Connect;
            if this.dispenser.IsConnected == 1
                disp('Dispenser connected succesfully')
            else
                disp('Dispenser connecting FAIL');
            end
            error = this.DispenserDefaults();
            if error ~= 0
                fprintf ('Error -> Could not set Dispenser');
            end
            
            % Preparing gantry object
            if gantry_obj.IsConnected == 1
                this.gantry = gantry_obj;
                disp('Gantry connected succesfully')
                this.xAxis = this.gantry.X;
                this.yAxis = this.gantry.Y;
                this.z1Axis = this.gantry.Z1;
                this.z2Axis = this.gantry.Z2;
            else
                disp('Gantry connecting FAIL');
            end
            
            % Preparing petal object
            this.petal1 = petal_obj;
        end
        
        %% Macros Dispenser%%
        
        function error = DispenserDefaults(this)
            % DispenserDefaults(this)
            % Arguments: none
            % Returns: 0 if communication was OK
            % Set default dispenser setting
            
            error = 0;
            cmd = sprintf ('E6--01');      % Set dispenser units in BAR
            error = error + this.dispenser.SetUltimus(cmd);
            
            cmd = sprintf('E7--01');      % Set dispenser Vacuum unit "H2O
            error = error + this.dispenser.SetUltimus(cmd);
            
            cmd = sprintf('PS--4000');    % Set dispenser pressure to 40 KPA = 0.4 BAR
            error = error + this.dispenser.SetUltimus(cmd);
            
            cmd = sprintf('VS--0005');    % Set dispenser vacuum to 0.12 KPA = 0.5 "H2O
            error = error + this.dispenser.SetUltimus(cmd);
            
            error = error + this.SetTime(1000);    % Dispenser in timing mode and t=1000 msec
        end
        
        function error = SetTime(this, time)
            % SetTime function (time)
            % Arguments: time -> Dispensing time (mseconds)
            % Returns: 0 if communication was OK
            % Set dispenser in timing mode and preset the desired time
            
            error = 0;
            cmd = sprintf('TT--');           %Setting timing mode
            error = error + this.dispenser.SetUltimus(cmd);
            
            cmd = sprintf('DS-T%04d',time); %Setting time in ms
            error = error + this.dispenser.SetUltimus(cmd);
            pause(0.1);
        end
        
        function error = StartDispensing(this)
            % StartDispensing function
            % Arguments: none
            % Return Error (0 -> No error)
            % 1- Z2 axis go to dispensing Heigh and wait
            % 2- Send "dispense" command to the dispenser.
            
            cmd = sprintf('DI--');
            error = this.dispenser.SetUltimus(cmd);
        end
        
        function ReadDispenserStatus(this)
            % function ReadDispenserStatus (this)
            % Arguments: none
            % Return Error (0 -> No error)
            % Read and print settings from dispenser:
            % -Pressure
            % -Vacuum
            % -Time
            
            cmd = 'E4--';
            FeedBack = this.dispenser.GetUltimus(cmd);
            pause(0.1);
            c = strcat(FeedBack(5), FeedBack(6));
            switch c
                case '00'
                    unitsP = 'PSI';
                case '01'
                    unitsP = 'BAR';
                case '02'
                    unitsP = 'KPA';
            end
            
            cmd = 'E5--';
            FeedBack = this.dispenser.GetUltimus(cmd);
            pause(0.1);
            c = strcat(FeedBack(5), FeedBack(6));
            switch c
                case '00'
                    unitsV = 'KPA';
                case '01'
                    unitsV = '"H2O';
                case '02'
                    unitsV = '"Hg';
                case '03'
                    unitsV = 'mmHg';
                case '04'
                    unitsV = 'TORR';
            end
            
            cmd = 'E8ccc';
            FeedBack = this.dispenser.GetUltimus(cmd)
            pause(0.1);
            c = strcat(FeedBack(5), FeedBack(6), FeedBack(7), FeedBack(8));
            value = str2double(c);
            value = value/1000;
            fprintf('Dispensing Pressure: %2.2f %s\n',value, unitsP);
            
            c = strcat(FeedBack(11), FeedBack(12), FeedBack(13), FeedBack(14), FeedBack(15));
            value = str2double(c)/10;
            fprintf('Dispensing Time: %d ms\n',value);
            
            c = strcat(FeedBack(18), FeedBack(19), FeedBack(20), FeedBack(21));
            value = str2double(c)/10;
            fprintf('Vacuum: %2.2f %s\n',value, unitsV);
        end
        
        %% Macros Gantry %%
        
        function GPositionDispensing(this)
            % function GPositionDispensing(this)
            % Arguments: none
            % Return Error (0 -> No error)
            % 1- Wait until all movements finished
            % 2- Move syringe to dispensing position and wait to arrive
            this.gantry.WaitForMotionAll();
            this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh, this.zLowSpeed,1);
        end
        
        function GPositionWaiting (this)
            % function GPositionDispensing(this)
            % Arguments: none
            % Return NONE
            % Move syringe to the waiting position
            this.gantry.MoveTo(this.z2Axis,this.zWaitingHeigh, this.zLowSpeed,1);
        end
        
        function GFiducial_1(this)
            % function GFiducial_1(this)
            % Arguments: none
            % Return NONE
            % Wait until all movements finished
            
            this.gantry.MoveToFast(this.fiducial_1(1),this.fiducial_1(2),1);
        end
        function GFiducial_2(this)
            % function GFiducial_1(this)
            % Arguments: none
            % Return NONE
            % Wait until all movements finished
            
            this.gantry.MoveToFast(this.fiducial_2(1),this.fiducial_2(2),1);
        end
        
        %% Testing %%
        
        function DispenseTest1(this)
            % DispenseTest function
            % Dispense 4 dropplets
            % Arguments: none
            %
            t1 = 1000;  %mseg
            
            error = 0;
            
            %             error = error + this.DispenserDefaults();
            disp('Move to test zone')
            this.gantry.MoveToFast(this.TestingZone(1), this.TestingZone(2), 1);
            
            if error ~= 0
                %                 fprintf ('\n ERROR \n');
                return
            else
                
                % 1st Dropplet
                disp('')
                disp('1st dropplet')
                disp('')
                error = error + this.SetTime(t1);
                this.GPositionDispensing();
                this.StartDispensing();
                t = t1/1000 + 0.2;
                pause(t);
                this.GPositionWaiting();
                % 2nd Dropplet
                disp('')
                disp('2nd dropplet')
                disp('')
                this.gantry.MoveBy(this.xAxis,10,5,1);
                this.GPositionDispensing();
                this.StartDispensing();
                t = t1/1000 + 0.2;
                pause(t);
                this.GPositionWaiting();
                
                % 3rd Dropplet
                disp('')
                disp('3rd dropplet')
                disp('')
                this.gantry.MoveBy(this.yAxis,10,5,1);
                this.GPositionDispensing();
                this.StartDispensing();
                t = t1/1000 + 0.2;
                pause(t);
                this.GPositionWaiting();
                
                % 4th Dropplet
                disp('')
                disp('4th dropplet')
                disp('')
                this.gantry.MoveBy(this.xAxis,-10,5,1);
                this.GPositionDispensing();
                this.StartDispensing();
                t = t1/1000 + 0.2;
                pause(t);
                this.GPositionWaiting();
                this.gantry.MoveBy(this.yAxis,-10,5,1);
            end
        end
        
        function DispenseTest2(this)
            % DispenseTest2 function
            % Dispense four parallel lines
            % OK
            % Return 0 if everything is OK
            
            t1 = 1000;  %mseg
            nLines = 5;
            delay = 0;
            error = 0;
            
            error = error + this.DispenserDefaults();
            xStartPetal = this.TestingZone(1)+20;
            yStartPetal = this.TestingZone(2);
            this.gantry.MoveToFast(xStartPetal, yStartPetal,1);
            
            error = error + this.SetTime(t1);
            if error ~= 0
                fprintf ('\n ERROR \n');
                return
            else
                
                t = t1 + delay;
                for i=0:nLines
                    % Preparing
                    t = t1+100*i;
                    error = error + this.SetTime(t);
                    LineLength = (t + delay)/1000 * this.dispSpeed;
                    disp('')
                    fprintf('Dispensing Line: %d \t Length = %2.2fmm\t Setting time: %2.2f\n', i,LineLength, t/1000);
                    xStartPetal = xStartPetal + this.Pitch;
                    yStartPetal = this.TestingZone(2);
                    this.gantry.MoveToLinear(xStartPetal, yStartPetal,this.xyHighSpeed,1);
                    
                    % Dispense one glue line
                    this.GPositionDispensing();
                    this.StartDispensing();
                    tic
                    this.gantry.MoveBy(this.yAxis,LineLength,this.dispSpeed,1);
                    toc
                    this.GPositionWaiting();
                    
                end
            end
        end
        
        %% Dispensing R0 %%
        
        function R0_Pattern(this)
            % DispenseTest function
            % Dispense 4 dropplets
            % Arguments: none
            %
            
            t = 1000;  %mseg
            nLines = 28;
            error = 0;
            
            this.f1 = this.petal1.fiducials_sensors.R0{4};
            this.f2 = this.petal1.fiducials_sensors.R0{3};
            
            this.f3 = this.petal1.fiducials_sensors.R0{1};
            this.f4 = this.petal1.fiducials_sensors.R0{2};
            
            StartSensor(2) = this.f1(2,1) - this.OffGlueStart(2);
            StartSensor(1) = this.StartLine(StartSensor(2) + this.OffGlueStart(1));
            StopSensor(2) = this.f3(2,1) - this.OffGlueStart(2);
            StopSensor(1) = this.StopLine(StopSensor(2) + this.OffGlueStart(1));
            
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R0');
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R0');
            
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            
            % Dispensing line 0
            this.gantry.MoveToFast(StartGantry(1), StartGantry(2), 1);
            this.GPositionDispensing();
            error = error + this.StartDispensing();
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            this.gantry.MoveToLinear(StopGantry(1), StopGantry(2), this.dispSpeed, 1);
            this.GPositionWaiting();
            
            % Dispensing loop
            for Line=1:nLines
                if 1<=Line && Line<=6
                    t = 1050;
                elseif 7<=Line && Line<=12
                    t = 1100;
                elseif 13<=Line && Line<=18
                    t = 1200;
                elseif 19<=Line && Line<=24
                    t = 1300;
                elseif 25<=Line && Line<=28
                    t = 1400;
                end
                this.SetTime(t);
                
                %Calculate Start and Stop line position in sensor
                StartSensor(2) = this.f1(2,1) - this.Pitch * Line - this.OffGlueStart(2);
                StartSensor(1) = this.StartLine(StartSensor(2) + this.OffGlueStart(1));
                StopSensor(2) = this.f3(2,1) - this.Pitch * Line - this.OffGlueStart(2);
                StopSensor(1) = this.StopLine(StopSensor(2) + this.OffGlueStart(1));
                %Change to Gantry coordinates after dispensing
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R0');
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R0');
                
                %Prepare to dispense
                this.gantry.MoveToFast(StartGantry(1), StartGantry(2), 1);
                this.GPositionDispensing();
                %Dispensing line
                this.StartDispensing();
                this.gantry.MoveToLinear(StopGantry(1), StopGantry(2), this.dispSpeed, 1);
                this.GPositionWaiting()
            end
        end
        
        function PlotLine(this,Start,Stop, fig)
            figure(fig);
            plot([Start(1)],[Start(2)],'x','Color','g')
            hold on
            plot([Stop(1)],[Stop(2)],'o','Color','g')
            plot([Start(1),Stop(1)],[Start(2),Stop(2)],'-','Color','g')
        end
        
        %% Plotting R0 %%
        
        function R0_Plot(this)
            % R0_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 28;
            Module = 'R0';
            
            this.f1 = this.petal1.fiducials_sensors.R0{4};
            this.f2 = this.petal1.fiducials_sensors.R0{3};
            this.f3 = this.petal1.fiducials_sensors.R0{1};
            this.f4 = this.petal1.fiducials_sensors.R0{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1, Module);
            Gf2 = this.petal1.sensor_to_gantry(this.f2, Module);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Module);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Module);
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            this.PlotLine(StartSensor, StopSensor, 2)
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Module);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Module);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Module);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Module);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        %% Plotting R1 %%
        
        function R1_Plot(this)
            % R1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 22;
            Module = 'R1';
            
            this.f1 = this.petal1.fiducials_sensors.R1{4};
            this.f2 = this.petal1.fiducials_sensors.R1{3};
            this.f3 = this.petal1.fiducials_sensors.R1{1};
            this.f4 = this.petal1.fiducials_sensors.R1{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1, Module);
            Gf2 = this.petal1.sensor_to_gantry(this.f2, Module);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Module);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Module);
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            this.PlotLine(StartSensor, StopSensor, 2)
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Module);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Module);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Module);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Module);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        
        function R0_Plot_old(this)
            % R0_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 28;
            Module = 'R0';
            
            this.f1 = this.petal1.fiducials_sensors.R0{4};
            this.f2 = this.petal1.fiducials_sensors.R0{3};
            this.f3 = this.petal1.fiducials_sensors.R0{1};
            this.f4 = this.petal1.fiducials_sensors.R0{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1, Module);
            Gf2 = this.petal1.sensor_to_gantry(this.f2, Module);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Module);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Module);
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Plot first line in Sensor coordinates
            figure(2);
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
            hold on
            plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
            plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
            
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Module);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Module);
            % Plot first line in Sensor coordinates
            figure(1);
            plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
            hold on
            plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
            plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            
            for Line=1:nLines
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                % Plot in Sensor coordinates
                figure(2);
                plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
                plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
                plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
                
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Module);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Module);
                % Plot in gantry coordinates
                figure(1);
                plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
                plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
                plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            end
        end
        
        %% Plotting R2 %%
        
        function R2_Plot(this)
            % R2_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 15;
            Module = 'R2';
            
            this.f1 = this.petal1.fiducials_sensors.R2{4};
            this.f2 = this.petal1.fiducials_sensors.R2{3};
            this.f3 = this.petal1.fiducials_sensors.R2{1};
            this.f4 = this.petal1.fiducials_sensors.R2{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1, Module);
            Gf2 = this.petal1.sensor_to_gantry(this.f2, Module);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Module);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Module);
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            this.PlotLine(StartSensor, StopSensor, 2)
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Module);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Module);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Module);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Module);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        function R2_Plot_old(this)
            % R1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            Line = 0;
            this.petal1.plotFiducialsInGantry;
            
            %this.petal1.plotSensorInGantry('R2')
            this.f1 = this.petal1.fiducials_sensors.R2{4};
            this.f2 = this.petal1.fiducials_sensors.R2{3};
            this.f3 = this.petal1.fiducials_sensors.R2{1};
            this.f4 = this.petal1.fiducials_sensors.R2{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1,'R2');
            Gf2 = this.petal1.sensor_to_gantry(this.f2,'R2');
            Gf3 = this.petal1.sensor_to_gantry(this.f3,'R2');
            Gf4 = this.petal1.sensor_to_gantry(this.f4,'R2');
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Plot first line in Sensor coordinates
            figure(2);
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
            hold on
            plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
            plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
            
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R2');
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R2');
            % Plot first line in Sensor coordinates
            figure(1);
            plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
            hold on
            plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
            plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            
            nLines = 15;
            for Line=1:nLines
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                % Plot in Sensor coordinates
                figure(2);
                plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
                plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
                plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
                
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R2');
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R2');
                % Plot in gantry coordinates
                figure(1);
                plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
                plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
                plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            end
        end
        
        %% Plotting R3S0 %%
        
        function R3S0_Plot(this)
            % R0_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 32;
            Module = 'R3';
            
            this.f1 = this.petal1.fiducials_sensors.R3S0{4};
            this.f2 = this.petal1.fiducials_sensors.R3S0{3};
            this.f3 = this.petal1.fiducials_sensors.R3S0{1};
            this.f4 = this.petal1.fiducials_sensors.R3S0{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1, Module);
            Gf2 = this.petal1.sensor_to_gantry(this.f2, Module);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Module);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Module);
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            this.PlotLine(StartSensor, StopSensor, 2)
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Module);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Module);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Module);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Module);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        
        function R3S0_Plot_old(this)
            % R1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            Line = 0;
            nLines = 32;
            this.petal1.plotFiducialsInGantry;
            
            %this.petal1.plotSensorInGantry('R1')
            this.f1 = this.petal1.fiducials_sensors.R3S0{4};
            this.f2 = this.petal1.fiducials_sensors.R3S0{3};
            this.f3 = this.petal1.fiducials_sensors.R3S0{1};
            this.f4 = this.petal1.fiducials_sensors.R3S0{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1,'R3S0');
            Gf2 = this.petal1.sensor_to_gantry(this.f2,'R3S0');
            Gf3 = this.petal1.sensor_to_gantry(this.f3,'R3S0');
            Gf4 = this.petal1.sensor_to_gantry(this.f4,'R3S0');
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Plot first line in Sensor coordinates
            figure(2);
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
            hold on
            plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
            plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
            
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R3S0');
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R3S0');
            % Plot first line in Sensor coordinates
            figure(1);
            plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
            hold on
            plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
            plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            
            for Line=1:nLines
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                % Plot in Sensor coordinates
                figure(2);
                plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
                plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
                plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
                
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R3S0');
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R3S0');
                % Plot in gantry coordinates
                figure(1);
                plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
                plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
                plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            end
        end
        
        %% Plotting R3S1 %%
        
        function R3S1_Plot(this)
            % R1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            nLines = 32;
            Line = 0;
            this.petal1.plotFiducialsInGantry;
            
            %this.petal1.plotSensorInGantry('R1')
            this.f1 = this.petal1.fiducials_sensors.R3S1{4};
            this.f2 = this.petal1.fiducials_sensors.R3S1{3};
            this.f3 = this.petal1.fiducials_sensors.R3S1{1};
            this.f4 = this.petal1.fiducials_sensors.R3S1{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1,'R3S1');
            Gf2 = this.petal1.sensor_to_gantry(this.f2,'R3S1');
            Gf3 = this.petal1.sensor_to_gantry(this.f3,'R3S1');
            Gf4 = this.petal1.sensor_to_gantry(this.f4,'R3S1');
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Plot first line in Sensor coordinates
            figure(2);
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
            hold on
            plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
            plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
            
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R3S1');
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R3S1');
            % Plot first line in Sensor coordinates
            figure(1);
            plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
            hold on
            plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
            plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            
            for Line=1:nLines
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                % Plot in Sensor coordinates
                figure(2);
                plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
                plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
                plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
                
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R3S1');
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R3S1');
                % Plot in gantry coordinates
                figure(1);
                plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
                plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
                plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            end
        end
        
        %% Plotting R4S0 %%
        
        function R4S0_Plot(this)
            % R1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            nLines = 30;
            Line = 0;
            this.petal1.plotFiducialsInGantry;
            
            %this.petal1.plotSensorInGantry('R1')
            this.f1 = this.petal1.fiducials_sensors.R4S0{4};
            this.f2 = this.petal1.fiducials_sensors.R4S0{3};
            this.f3 = this.petal1.fiducials_sensors.R4S0{1};
            this.f4 = this.petal1.fiducials_sensors.R4S0{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1,'R4S0');
            Gf2 = this.petal1.sensor_to_gantry(this.f2,'R4S0');
            Gf3 = this.petal1.sensor_to_gantry(this.f3,'R4S0');
            Gf4 = this.petal1.sensor_to_gantry(this.f4,'R4S0');
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Plot first line in Sensor coordinates
            figure(2);
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
            hold on
            plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
            plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
            
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R4S0');
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R4S0');
            % Plot first line in Sensor coordinates
            figure(1);
            plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
            hold on
            plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
            plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            
            for Line=1:nLines
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                % Plot in Sensor coordinates
                figure(2);
                plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
                plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
                plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
                
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R4S0');
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R4S0');
                % Plot in gantry coordinates
                figure(1);
                plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
                plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
                plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            end
        end
        %% Plotting R4S1 %%
        
        
        function R4S1_Plot(this)
            % R4S1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            nLines = 30;
            Line = 0;
            this.petal1.plotFiducialsInGantry;
            
            %this.petal1.plotSensorInGantry('R1')
            this.f1 = this.petal1.fiducials_sensors.R4S1{4};
            this.f2 = this.petal1.fiducials_sensors.R4S1{3};
            this.f3 = this.petal1.fiducials_sensors.R4S1{1};
            this.f4 = this.petal1.fiducials_sensors.R4S1{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1,'R4S1');
            Gf2 = this.petal1.sensor_to_gantry(this.f2,'R4S1');
            Gf3 = this.petal1.sensor_to_gantry(this.f3,'R4S1');
            Gf4 = this.petal1.sensor_to_gantry(this.f4,'R4S1');
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Plot first line in Sensor coordinates
            figure(2);
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
            hold on
            plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
            plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
            
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R4S1');
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R4S1');
            % Plot first line in Sensor coordinates
            figure(1);
            plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
            hold on
            plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
            plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            
            for Line=1:nLines
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                % Plot in Sensor coordinates
                figure(2);
                plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
                plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
                plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
                
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R4S1');
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R4S1');
                % Plot in gantry coordinates
                figure(1);
                plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
                plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
                plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            end
        end
        
        %% Plotting R5S0 %%
        
        function R5S0_Plot(this)
            % R5S0_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            nLines = 27;
            Line = 0;
            this.petal1.plotFiducialsInGantry;
            
            %this.petal1.plotSensorInGantry('R1')
            this.f1 = this.petal1.fiducials_sensors.R5S0{4};
            this.f2 = this.petal1.fiducials_sensors.R5S0{3};
            this.f3 = this.petal1.fiducials_sensors.R5S0{1};
            this.f4 = this.petal1.fiducials_sensors.R5S0{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1,'R5S0');
            Gf2 = this.petal1.sensor_to_gantry(this.f2,'R5S0');
            Gf3 = this.petal1.sensor_to_gantry(this.f3,'R5S0');
            Gf4 = this.petal1.sensor_to_gantry(this.f4,'R5S0');
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Plot first line in Sensor coordinates
            figure(2);
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
            hold on
            plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
            plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
            
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R5S0');
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R5S0');
            % Plot first line in Sensor coordinates
            figure(1);
            plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
            hold on
            plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
            plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            
            for Line=1:nLines
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                % Plot in Sensor coordinates
                figure(2);
                plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
                plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
                plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
                
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R5S0');
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R5S0');
                % Plot in gantry coordinates
                figure(1);
                plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
                plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
                plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            end
        end
        
        %% Plotting R5S1 %%
        
        function R5S1_Plot(this)
            % R5S1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            nLines = 27;
            Line = 0;
            this.petal1.plotFiducialsInGantry;
            
            %this.petal1.plotSensorInGantry('R1')
            this.f1 = this.petal1.fiducials_sensors.R5S1{4};
            this.f2 = this.petal1.fiducials_sensors.R5S1{3};
            this.f3 = this.petal1.fiducials_sensors.R5S1{1};
            this.f4 = this.petal1.fiducials_sensors.R5S1{2};
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            %Plot fiducials in Sensor system
            figure(2);
            plot([this.f1(1)],[this.f1(2)],'x','Color','k')
            hold on
            plot([this.f2(1)],[this.f2(2)],'x','Color','r')
            
            plot([this.f3(1)],[this.f3(2)],'o','Color','k')
            plot([this.f4(1)],[this.f4(2)],'o','Color','r')
            plot([this.f1(1),this.f2(1),this.f4(1),this.f3(1),this.f1(1)],[this.f1(2),this.f2(2),this.f4(2),this.f3(2),this.f1(2)],'-','Color','k')
            
            % Plot fiducials in gantry system
            figure(1);
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1,'R5S1');
            Gf2 = this.petal1.sensor_to_gantry(this.f2,'R5S1');
            Gf3 = this.petal1.sensor_to_gantry(this.f3,'R5S1');
            Gf4 = this.petal1.sensor_to_gantry(this.f4,'R5S1');
            plot([Gf1(1)],[Gf1(2)],'x','Color','k')
            hold on
            plot([Gf2(1)],[Gf2(2)],'x','Color','r')
            
            plot([Gf3(1)],[Gf3(2)],'o','Color','k')
            plot([Gf4(1)],[Gf4(2)],'o','Color','r')
            plot([Gf1(1),Gf2(1),Gf4(1),Gf3(1),Gf1(1)],[Gf1(2),Gf2(2),Gf4(2),Gf3(2),Gf1(2)],'-','Color','k')
            
            % Plot first line in Sensor coordinates
            figure(2);
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
            hold on
            plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
            plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
            
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R5S1');
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R5S1');
            % Plot first line in Sensor coordinates
            figure(1);
            plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
            hold on
            plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
            plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            
            for Line=1:nLines
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                % Plot in Sensor coordinates
                figure(2);
                plot([StartSensor(1)],[StartSensor(2)],'x','Color','g')
                plot([StopSensor(1)],[StopSensor(2)],'o','Color','g')
                plot([StartSensor(1),StopSensor(1)],[StartSensor(2),StopSensor(2)],'-','Color','g')
                
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R5S1');
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R5S1');
                % Plot in gantry coordinates
                figure(1);
                plot([StartGantry(1)],[StartGantry(2)],'x','Color','g')
                plot([StopGantry(1)],[StopGantry(2)],'o','Color','g')
                plot([StartGantry(1),StopGantry(1)],[StartGantry(2),StopGantry(2)],'-','Color','g')
            end
        end
        
        
        function LinesCalculation(this)
            % function LinesCalculation(this)
            % Arg: none
            % Return: none
            % Calculate line equations between F-F: 1-2 and 3-4
            this.mLine12 = (this.f2(1) - this.f1(1))/(this.f2(2) - this.f1(2));
            this.qLine12 = (this.f2(2)*this.f1(1)) - (this.f1(2)*this.f2(1)) / (this.f2(2)-this.f1(2));
            
            this.mLine34 = (this.f4(1) - this.f3(1))/(this.f4(2)-this.f3(2));
            this.qLine34 = ((this.f4(2)*this.f3(1)) - (this.f3(2)*this.f4(1))) / (this.f4(2)-this.f3(2));
        end
        
        function [Start, Stop] = CalculateStartAndStop(this, Line)
            % function CalculateStartAndStop(this, Line)
            % Arg: Line number
            % Return: [Start, Stop] for the current Line
            
            Start(2) = this.f1(2,1) - this.Pitch * Line - this.OffGlueStart(2);
            Start(1) = this.mLine12*Start(2) + this.qLine12 + this.OffGlueStart(1);
            Stop(2) = this.f3(2,1) - this.Pitch * Line - this.OffGlueStart(2);
            Stop(1) = this.mLine34*Stop(2) + this.qLine34 - this.OffGlueStart(1);
        end
        
        %% Funciones obsoletas a borrar %%
        
        function xStartP = StartLine(this, yStartP)
            % function Line12Start()
            % Arg: none
            % Return: none
            % Calculate line equations between F-F: 1-2 and 3-4 in the
            % petal system
            
            this.mLine12 = (this.f2(1) - this.f1(1))/(this.f2(2) - this.f1(2));
            this.qLine12 = (this.f2(2)*this.f1(1)) - (this.f1(2)*this.f2(1)) / (this.f2(2)-this.f1(2));
            xStartP = this.mLine12*yStartP + this.qLine12;
        end
        
        function xStopP = StopLine(this, yStopP)
            % function Line12Start()
            % Arg: none
            % Return: none
            % Calculate line equations between F-F: 1-2 and 3-4 in the
            % petal system
            
            this.mLine34 = (this.f4(1) - this.f3(1))/(this.f4(2)-this.f3(2));
            this.qLine34 = ((this.f4(2)*this.f3(1)) - (this.f3(2)*this.f4(1))) / (this.f4(2)-this.f3(2));
            xStopP = this.mLine34*yStopP +this.qLine34;
        end
        
        
        
        
        
        %         function yStartP = Line12Start(this, xStartP)
        %             % function Line12Start()
        %             % Arg: none
        %             % Return: none
        %             % Calculate line equations between F-F: 1-2 and 3-4 in the
        %             % petal system
        %
        %             mLine12 = (this.Yf2 - this.Yf1)/(this.Xf2 - this.Xf1);
        %             qLine12 = ((this.Xf2*this.Yf1) - (this.Xf1*this.Yf2)) / (this.Xf2-this.Xf1);
        %             yStartP = mLine12*xStartP +qLine12;
        %         end
    end
end

