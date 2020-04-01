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
        
        function GoFiducial_1(this)
            % function GFiducial_1(this)
            % Arguments: none
            % Return NONE
            % Move to defined Fiducial 1
            % Wait until all movements finished
            
            this.gantry.MoveToFast(this.fiducial_1(1),this.fiducial_1(2),1);
        end
        function GoFiducial_2(this)
            % function GFiducial_1(this)
            % Arguments: none
            % Return NONE
            % Move to defined Fiducial 2
            % Wait until all movements finished
            
            this.gantry.MoveToFast(this.fiducial_2(1),this.fiducial_2(2),1);
        end
        
        %% Dispensing Patterns %%
        
        function R0_Dispense(this)
            % R0_Dispense function
            % Dispensing procedure for R0 Sensor
            % Arguments: none
            %

            nLines = 28;
            t = 1000;  %mseg
            Sensor = 'R0';
            this.f1 = this.petal1.fiducials_sensors.R0{4};
            this.f2 = this.petal1.fiducials_sensors.R0{3};
            this.f3 = this.petal1.fiducials_sensors.R0{1};
            this.f4 = this.petal1.fiducials_sensors.R0{2};
%             Group1 = (1, 6, 1050);
%             Group2 = (7, 12, 1100);
%             Group3 = (13, 18, 1200);
%             Group4 = (19, 24, 1300);
%             Group5 = (25, 28, 1400);

            error = 0;
            Line = 0;
            
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            
            %Dispense first line
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.DispenseLine(StartGantry, StopGantry);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            
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
                error = error + this.SetTime(t);
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                error = error + this.DispenseLine(StartGantry, StopGantry);
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                    return
                end
            end
        end
        
        function R1_Dispense(this)
            % R1_Dispense function
            % Dispensing procedure R1 sensor
            % Arguments: none
            %
            
            nLines = 22;
            t = 1400;  %mseg
            Sensor = 'R1';
            this.f1 = this.petal1.fiducials_sensors.R1{4};
            this.f2 = this.petal1.fiducials_sensors.R1{3};
            this.f3 = this.petal1.fiducials_sensors.R1{1};
            this.f4 = this.petal1.fiducials_sensors.R1{2};
            
            error = 0;
            Line = 0;
            
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            
            %Dispense first line
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.DispenseLine(StartGantry, StopGantry);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            
            for Line=1:nLines
                if 1<=Line && Line<=7
                    t = 1400;
                elseif 8<=Line && Line<=13
                    t = 1500;
                elseif 13<=Line && Line<=18
                    t = 1200;
                elseif 14<=Line && Line<=22
                    t = 1600;
                end
                error = error + this.SetTime(t);
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                error = error + this.DispenseLine(StartGantry, StopGantry);
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                    return
                end
            end
        end
        
        function R2_Dispense(this)
            % R2_Dispense function
            % Dispensing procedure
            % Arguments: none
            %

            nLines = 15;
            t = 1700;  %mseg
            Sensor = 'R2';
            this.f1 = this.petal1.fiducials_sensors.R2{4};
            this.f2 = this.petal1.fiducials_sensors.R2{3};
            this.f3 = this.petal1.fiducials_sensors.R2{1};
            this.f4 = this.petal1.fiducials_sensors.R2{2};
            
            error = 0;
            Line = 0;
            
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            
            %Dispense first line
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.DispenseLine(StartGantry, StopGantry);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            
            for Line=1:nLines
                if 1<=Line && Line<=8
                    t = 1700;
                elseif 9<=Line && Line<=15
                    t = 1800;
                end
                error = error + this.SetTime(t);
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                error = error + this.DispenseLine(StartGantry, StopGantry);
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                    return
                end
            end
        end
       
        function R3S0_Dispense(this)
            % R3S0_Dispense function
            % Dispensing procedure
            % Arguments: none
            %
            

            nLines = 32;
            t = 800;  %mseg
            Sensor = 'R3S0';
            this.f1 = this.petal1.fiducials_sensors.R3S0{4};
            this.f2 = this.petal1.fiducials_sensors.R3S0{3};
            this.f3 = this.petal1.fiducials_sensors.R3S0{1};
            this.f4 = this.petal1.fiducials_sensors.R3S0{2};
            
            error = 0;
            Line = 0;
            
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            
            %Dispense first line
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.DispenseLine(StartGantry, StopGantry);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            
            for Line=1:nLines
                if 1<=Line && Line<=10
                    t = 850;
                elseif 11<=Line && Line<=20
                    t = 900;
                elseif 21<=Line && Line<=32
                    t = 1000;
                end
                error = error + this.SetTime(t);
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                error = error + this.DispenseLine(StartGantry, StopGantry);
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                    return
                end
            end
        end
        
        function R3S1_Dispense(this)
            % R3S1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            

            nLines = 32;
            t = 800;  %mseg
            Sensor = 'R3S1';
            this.f1 = this.petal1.fiducials_sensors.R3S1{4};
            this.f2 = this.petal1.fiducials_sensors.R3S1{3};
            this.f3 = this.petal1.fiducials_sensors.R3S1{1};
            this.f4 = this.petal1.fiducials_sensors.R3S1{2};
            
            error = 0;
            Line = 0;
            
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            
            %Dispense first line
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.DispenseLine(StartGantry, StopGantry);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            
            for Line=1:nLines
                if 1<=Line && Line<=10
                    t = 850;
                elseif 11<=Line && Line<=20
                    t = 900;
                elseif 21<=Line && Line<=32
                    t = 1000;
                end
                error = error + this.SetTime(t);
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                error = error + this.DispenseLine(StartGantry, StopGantry);
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                    return
                end
            end
        end
        
        function R4S0_Dispense(this)
            % R4S0_Dispense function
            % Dispensing procedure for R4 sensor
            % Arguments: none
            %
            

            nLines = 32;
            t = 1000;  %mseg
            Sensor = 'R4S0';
            this.f1 = this.petal1.fiducials_sensors.R4S0{4};
            this.f2 = this.petal1.fiducials_sensors.R4S0{3};
            this.f3 = this.petal1.fiducials_sensors.R4S0{1};
            this.f4 = this.petal1.fiducials_sensors.R4S0{2};
            
            error = 0;
            Line = 0;
            
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            
            %Dispense first line
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.DispenseLine(StartGantry, StopGantry);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            
            for Line=1:nLines
                if 1<=Line && Line<=10
                    t = 1000;
                elseif 11<=Line && Line<=20
                    t = 1050;
                elseif 21<=Line && Line<=30
                    t = 1150;
                end
                error = error + this.SetTime(t);
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                error = error + this.DispenseLine(StartGantry, StopGantry);
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                    return
                end
            end
        end
        
        function R4S1_Dispense(this)
            % R4S1_Dispense function
            % Dispensing procedure for R4S1 sensor
            % Arguments: none
            %

            nLines = 30;
            t = 1000;  %mseg
            Sensor = 'R4S1';
            this.f1 = this.petal1.fiducials_sensors.R4S1{4};
            this.f2 = this.petal1.fiducials_sensors.R4S1{3};
            this.f3 = this.petal1.fiducials_sensors.R4S1{1};
            this.f4 = this.petal1.fiducials_sensors.R4S1{2};
            
            error = 0;
            Line = 0;
            
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            
            %Dispense first line
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.DispenseLine(StartGantry, StopGantry);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            
            for Line=1:nLines
                if 1<=Line && Line<=10
                    t = 1050;
                elseif 11<=Line && Line<=20
                    t = 1100;
                elseif 21<=Line && Line<=30
                    t = 1150;
                end
                error = error + this.SetTime(t);
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                error = error + this.DispenseLine(StartGantry, StopGantry);
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                    return
                end
            end
        end
        
        function R5S0_Dispense(this)
            % R5S0_Dispense function
            % Dispensing procedure for R5S0 sensor
            % Arguments: none
            %
            

            nLines = 27;
            t = 1200;  %mseg
            Sensor = 'R5S0';
            this.f1 = this.petal1.fiducials_sensors.R5S0{4};
            this.f2 = this.petal1.fiducials_sensors.R5S0{3};
            this.f3 = this.petal1.fiducials_sensors.R5S0{1};
            this.f4 = this.petal1.fiducials_sensors.R5S0{2};
            
            error = 0;
            Line = 0;
            
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            
            %Dispense first line
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.DispenseLine(StartGantry, StopGantry);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            
            for Line=1:nLines
                if 1<=Line && Line<=9
                    t = 1200;
                elseif 10<=Line && Line<=18
                    t = 1300;
                elseif 19<=Line && Line<=27
                    t = 1400;
                end
                error = error + this.SetTime(t);
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                error = error + this.DispenseLine(StartGantry, StopGantry);
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                    return
                end
            end
        end
        
        function R5S1_Dispense(this)
            % R5S1_Dispense function
            % Dispensing procedure for R5S0 sensor
            % Arguments: none
            %
            

            nLines = 32;
            t = 1200;  %mseg
            Sensor = 'R5S1';
            this.f1 = this.petal1.fiducials_sensors.R5S1{4};
            this.f2 = this.petal1.fiducials_sensors.R5S1{3};
            this.f3 = this.petal1.fiducials_sensors.R5S1{1};
            this.f4 = this.petal1.fiducials_sensors.R5S1{2};
            
            error = 0;
            Line = 0;
            
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Calculate first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            
            %Dispense first line
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.DispenseLine(StartGantry, StopGantry);
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            
            for Line=1:nLines
                if 1<=Line && Line<=9
                    t = 1200;
                elseif 10<=Line && Line<=18
                    t = 1300;
                elseif 19<=Line && Line<=27
                    t = 1400;
                end
                error = error + this.SetTime(t);
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                error = error + this.DispenseLine(StartGantry, StopGantry);
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                    return
                end
            end
        end
        
        
        %% Plotting Lines %%
        
                %% Plotting Lines %%
        function R0_PlotZ(this)
            % R0_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 28;
            Sensor = 'R0';
            Direction = 1;
            
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
            Gf1 = this.petal1.sensor_to_gantry(this.f1, Sensor);
            Gf2 = this.petal1.sensor_to_gantry(this.f2, Sensor);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Sensor);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Sensor);
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
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                if Direction == 1
                    Direction = 0;
                    Temporal = StartSensor;
                    StartSensor = StopSensor;
                    StopSensor = Temporal;
                else
                    Direction = 1;
                end
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        function R0_Plot(this)
            % R0_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 28;
            Sensor = 'R0';
            
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
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1, Sensor);
            Gf2 = this.petal1.sensor_to_gantry(this.f2, Sensor);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Sensor);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Sensor);
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
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        function R1_Plot(this)
            % R1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 22;
            Sensor = 'R1';
            
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
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1, Sensor);
            Gf2 = this.petal1.sensor_to_gantry(this.f2, Sensor);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Sensor);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Sensor);
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
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        function R2_Plot(this)
            % R2_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 15;
            Sensor = 'R2';
            
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
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1, Sensor);
            Gf2 = this.petal1.sensor_to_gantry(this.f2, Sensor);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Sensor);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Sensor);
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
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        function R3S0_Plot(this)
            % R3S0_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 32;
            Sensor = 'R3S0';
            
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
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1, Sensor);
            Gf2 = this.petal1.sensor_to_gantry(this.f2, Sensor);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Sensor);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Sensor);
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
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        function R3S1_Plot(this)
            % R3S1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            this.petal1.plotFiducialsInGantry;
            
            Line = 0;
            nLines = 32;
            Sensor = 'R3S1';
            
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
            Gf1 = this.petal1.sensor_to_gantry(this.f1,Sensor);
            Gf2 = this.petal1.sensor_to_gantry(this.f2,Sensor);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Sensor);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Sensor);
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
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        function R4S0_Plot(this)
            % R1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            nLines = 30;
            Line = 0;
            this.petal1.plotFiducialsInGantry;
            Sensor = 'R4S0';
            
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
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R4S0');
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R4S0');
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        function R4S1_Plot(this)
            % R4S1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            nLines = 30;
            Line = 0;
            this.petal1.plotFiducialsInGantry;
            Sensor = 'R4S1';
            
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
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1,Sensor);
            Gf2 = this.petal1.sensor_to_gantry(this.f2,Sensor);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Sensor);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Sensor);
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
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        function R5S0_Plot(this)
            % R5S0_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            nLines = 27;
            Line = 0;
            this.petal1.plotFiducialsInGantry;
            Sensor = 'R5S0';
            
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
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1,Sensor);
            Gf2 = this.petal1.sensor_to_gantry(this.f2,Sensor);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Sensor);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Sensor);
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
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                this.PlotLine(StartGantry, StopGantry, 1);
            end
        end
        
        function R5S1_Plot(this)
            % R5S1_Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            nLines = 27;
            Line = 0;
            this.petal1.plotFiducialsInGantry;
            Sensor = 'R5S1';
            
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
            
            Gf1 = this.petal1.sensor_to_gantry(this.f1,Sensor);
            Gf2 = this.petal1.sensor_to_gantry(this.f2,Sensor);
            Gf3 = this.petal1.sensor_to_gantry(this.f3,Sensor);
            Gf4 = this.petal1.sensor_to_gantry(this.f4,Sensor);
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
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
            this.PlotLine(StartGantry, StopGantry, 1);
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                this.PlotLine(StartSensor, StopSensor, 2)
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor);
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor);
                this.PlotLine(StartGantry, StopGantry, 1)
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
        
        function PlotLine(this,Start,Stop, fig)
            figure(fig);
            plot([Start(1)],[Start(2)],'x','Color','g')
            hold on
            plot([Stop(1)],[Stop(2)],'o','Color','g')
            plot([Start(1),Stop(1)],[Start(2),Stop(2)],'-','Color','g')
        end
        
        function error = DispenseLine(this,Start,Stop)
            this.gantry.MoveToFast(Start(1), Start(2), 1);
            this.GPositionDispensing();
            error = this.StartDispensing();
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            this.gantry.MoveToLinear(Stop(1), Stop(2), this.dispSpeed, 1);
            this.GPositionWaiting();
        end
        
        %% Funciones obsoletas a borrar %%
        
%         function xStartP = StartLine(this, yStartP)
%             % function Line12Start()
%             % Arg: none
%             % Return: none
%             % Calculate line equations between F-F: 1-2 and 3-4 in the
%             % petal system
%             
%             this.mLine12 = (this.f2(1) - this.f1(1))/(this.f2(2) - this.f1(2));
%             this.qLine12 = (this.f2(2)*this.f1(1)) - (this.f1(2)*this.f2(1)) / (this.f2(2)-this.f1(2));
%             xStartP = this.mLine12*yStartP + this.qLine12;
%         end
        
%         function xStopP = StopLine(this, yStopP)
%             % function Line12Start()
%             % Arg: none
%             % Return: none
%             % Calculate line equations between F-F: 1-2 and 3-4 in the
%             % petal system
%             
%             this.mLine34 = (this.f4(1) - this.f3(1))/(this.f4(2)-this.f3(2));
%             this.qLine34 = ((this.f4(2)*this.f3(1)) - (this.f3(2)*this.f4(1))) / (this.f4(2)-this.f3(2));
%             xStopP = this.mLine34*yStopP +this.qLine34;
%         end
        
        
        
        
        
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
        
        
%         function R0_Pattern(this)
%             % DispenseTest function
%             % Dispense 4 dropplets
%             % Arguments: none
%             %
%             
%             t = 1000;  %mseg
%             nLines = 28;
%             error = 0;
%             
%             this.f1 = this.petal1.fiducials_sensors.R0{4};
%             this.f2 = this.petal1.fiducials_sensors.R0{3};
%             
%             this.f3 = this.petal1.fiducials_sensors.R0{1};
%             this.f4 = this.petal1.fiducials_sensors.R0{2};
%             
%             StartSensor(2) = this.f1(2,1) - this.OffGlueStart(2);
%             StartSensor(1) = this.StartLine(StartSensor(2) + this.OffGlueStart(1));
%             StopSensor(2) = this.f3(2,1) - this.OffGlueStart(2);
%             StopSensor(1) = this.StopLine(StopSensor(2) + this.OffGlueStart(1));
%             
%             StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R0');
%             StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R0');
%             
%             error = error + this.DispenserDefaults();
%             error = error + this.SetTime(t);
%             if error ~= 0
%                 fprintf ('\n DISPENSER ERROR \n');
%                 return
%             end
%             
%             % Dispensing line 0
%             this.gantry.MoveToFast(StartGantry(1), StartGantry(2), 1);
%             this.GPositionDispensing();
%             error = error + this.StartDispensing();
%             if error ~= 0
%                 fprintf ('\n DISPENSER ERROR \n');
%                 return
%             end
%             this.gantry.MoveToLinear(StopGantry(1), StopGantry(2), this.dispSpeed, 1);
%             this.GPositionWaiting();
%             
%             % Dispensing loop
%             for Line=1:nLines
%                 if 1<=Line && Line<=6
%                     t = 1050;
%                 elseif 7<=Line && Line<=12
%                     t = 1100;
%                 elseif 13<=Line && Line<=18
%                     t = 1200;
%                 elseif 19<=Line && Line<=24
%                     t = 1300;
%                 elseif 25<=Line && Line<=28
%                     t = 1400;
%                 end
%                 this.SetTime(t);
%                 
%                 %Calculate Start and Stop line position in sensor
%                 StartSensor(2) = this.f1(2,1) - this.Pitch * Line - this.OffGlueStart(2);
%                 StartSensor(1) = this.StartLine(StartSensor(2) + this.OffGlueStart(1));
%                 StopSensor(2) = this.f3(2,1) - this.Pitch * Line - this.OffGlueStart(2);
%                 StopSensor(1) = this.StopLine(StopSensor(2) + this.OffGlueStart(1));
%                 %Change to Gantry coordinates after dispensing
%                 StartGantry = this.petal1.sensor_to_gantry(StartSensor, 'R0');
%                 StopGantry = this.petal1.sensor_to_gantry(StopSensor, 'R0');
%                 
%                 %Prepare to dispense
%                 this.gantry.MoveToFast(StartGantry(1), StartGantry(2), 1);
%                 this.GPositionDispensing();
%                 %Dispensing line
%                 this.StartDispensing();
%                 this.gantry.MoveToLinear(StopGantry(1), StopGantry(2), this.dispSpeed, 1);
%                 this.GPositionWaiting()
%             end
%         end
    end
end

