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
        zDispensingHeigh = -72;      % Z Position while glue dispensing
    end
    
    properties (Access = public)
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
        glueOffX = 415.5;       %Offset Between camera and syrenge
        glueOffY = 4;
        %glueOff = [0,0]
%         glueOff = [415.5,4,0]
%         glueOff = [4, 415.5,0]
        glueOff = [415.5;4;0];
        
        zHighSpeed = 10;
        zLowSpeed = 5;
        
        xyHighSpeed = 20;
        xyLowSpeed = 5;
        
        dispSpeed = 60;
        
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
%             error = this.DispenserDefaults();
%             if error ~= 0
%                 fprintf ('Error -> Could not set Dispenser');
%             end
            
            % Preparing gantry object
            this.gantry = gantry_obj;
            this.xAxis = this.gantry.X;
            this.yAxis = this.gantry.Y;
            this.z1Axis = this.gantry.Z1;
            this.z2Axis = this.gantry.Z2;
            if gantry_obj.IsConnected == 1
                disp('Gantry connected succesfully')
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
            
            value = 4;                    % 4 BAR
            value = value * 1000;
            cmd = sprintf('PS--%04d', value);    % Set dispenser pressure to 40 KPA = 0.4 BAR
            error = error + this.dispenser.SetUltimus(cmd);
            
            value = 0.4;                  % 0.5 "H2O
            value = value * 10;
            cmd = sprintf('VS--%04d', value);    % Set dispenser vacuum to 0.12 KPA = 0.5 "H2O
            error = error + this.dispenser.SetUltimus(cmd);
            
            error = error + this.SetTime(1000);    % Dispenser in timing mode and t=1000 msec
        end
        
        function error = SetTime(this, time)
            % SetTime function (time)
            % Arguments: time -> Dispensing time (mseconds)
            % Returns: 0 if communication was OK
            % Set dispenser in timing mode and preset the desired time
            
            error = 0;
            cmd = sprintf('DS-T%04d',time); %Setting time in ms
            disp(cmd)
            error = error + this.dispenser.SetUltimus(cmd);
            pause(0.1);
        end
        
        function error = SetTimingMode(this)
            % SetTimingMode function (time)
            % Arguments: none
            % Returns: 0 if communication was OK
            % Set dispenser in timing mode
            
            error = 0;
            cmd = sprintf('TT--');           %Setting timing mode
            error = error + this.dispenser.SetUltimus(cmd);
        end
        
        function error = SetContiusMode(this)
            % SetContius function (time)
            % Arguments: none
            % Returns: 0 if communication was OK
            % Set dispenser in continuous mode
            
            error = 0;
            cmd = sprintf('MT--');           %Setting Continious mode
            error = error + this.dispenser.SetUltimus(cmd);
        end
        
        function error = StartDispensing(this)
            % StartDispensing function
            % Arguments: none
            % Return Error (0 -> No error)
            % 1- Z2 axis go to dispensing Heigh and wait
            % 2- Send "dispense" command to the dispenser.
            
            cmd = sprintf('DI--');
            error = this.dispenser.SetUltimus(cmd);
            %pause(0.1)
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
        
        function GoFiducial_Lower(this)
            % function GoFiducial_Lower(this)
            % Arguments: none
            % Return NONE
            % Move to defined Fiducial 1
            % Wait until all movements finished
            this.gantry.MoveToFast(this.petal1.lower_petalFid(1),this.petal1.lower_petalFid(2),1);
        end
        function GoFiducial_Upper(this)
            % function GoFiducial_Upper(this)
            % Arguments: none
            % Return NONE
            % Move to defined Fiducial 2
            % Wait until all movements finished
            this.gantry.MoveToFast(this.petal1.upper_petalFid(1),this.petal1.upper_petalFid(2),1);
        end
        
        %% Dispensing Patterns %%
        
        function DispenseContinius(this, Sensor)
            % Generic Dispense function
            % Dispensing procedure for indicated Sensor. Dispenser in
            % continuous mode.
            % Arguments: Sensor String
            %
            
            switch Sensor
                case 'R0'
                    nLines = 28;
                    this.f1 = this.petal1.fiducials_sensors.R0{4};
                    this.f2 = this.petal1.fiducials_sensors.R0{3};
                    this.f3 = this.petal1.fiducials_sensors.R0{1};
                    this.f4 = this.petal1.fiducials_sensors.R0{2};
                case 'R1'
                    nLines = 22;
                    this.f1 = this.petal1.fiducials_sensors.R1{4};
                    this.f2 = this.petal1.fiducials_sensors.R1{3};
                    this.f3 = this.petal1.fiducials_sensors.R1{1};
                    this.f4 = this.petal1.fiducials_sensors.R1{2};
                case 'R2'
                    nLines = 15;
                    this.f1 = this.petal1.fiducials_sensors.R2{4};
                    this.f2 = this.petal1.fiducials_sensors.R2{3};
                    this.f3 = this.petal1.fiducials_sensors.R2{1};
                    this.f4 = this.petal1.fiducials_sensors.R2{2};
                case 'R3S0'
                    nLines = 32;
                    this.f1 = this.petal1.fiducials_sensors.R3S0{4};
                    this.f2 = this.petal1.fiducials_sensors.R3S0{3};
                    this.f3 = this.petal1.fiducials_sensors.R3S0{1};
                    this.f4 = this.petal1.fiducials_sensors.R3S0{2};
                case 'R3S1'
                    nLines = 32;
                    this.f1 = this.petal1.fiducials_sensors.R3S1{4};
                    this.f2 = this.petal1.fiducials_sensors.R3S1{3};
                    this.f3 = this.petal1.fiducials_sensors.R3S1{1};
                    this.f4 = this.petal1.fiducials_sensors.R3S1{2};
                case 'R4S0'
                    nLines = 30;
                    this.f1 = this.petal1.fiducials_sensors.R4S0{4};
                    this.f2 = this.petal1.fiducials_sensors.R4S0{3};
                    this.f3 = this.petal1.fiducials_sensors.R4S0{1};
                    this.f4 = this.petal1.fiducials_sensors.R4S0{2};
                case 'R4S1'
                    nLines = 30;
                    this.f1 = this.petal1.fiducials_sensors.R4S1{4};
                    this.f2 = this.petal1.fiducials_sensors.R4S1{3};
                    this.f3 = this.petal1.fiducials_sensors.R4S1{1};
                    this.f4 = this.petal1.fiducials_sensors.R4S1{2};
                case 'R5S0'
                    nLines = 27;
                    this.f1 = this.petal1.fiducials_sensors.R5S0{4};
                    this.f2 = this.petal1.fiducials_sensors.R5S0{3};
                    this.f3 = this.petal1.fiducials_sensors.R5S0{1};
                    this.f4 = this.petal1.fiducials_sensors.R5S0{2};
                case 'R5S1'
                    nLines = 27;
                    this.f1 = this.petal1.fiducials_sensors.R5S1{4};
                    this.f2 = this.petal1.fiducials_sensors.R5S1{3};
                    this.f3 = this.petal1.fiducials_sensors.R5S1{1};
                    this.f4 = this.petal1.fiducials_sensors.R5S1{2};
                otherwise
                    fprintf ('\n\t Error, "%s" is not a valid sensor name: ', Sensor);
                    disp('"R0", "R1", "R2", "R3S0", "R3S1", "R4S0", "R4S1", "R5S0", "R5S1"');
                    return
            end
            
            Line = 0;
            error = 0;

            timeStop = zeros(1,nLines);
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Dispense first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor) - this.glueOff;
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor) - this.glueOff;
            
            % Move to Start Position and start dispensing
            this.gantry.MoveToFast(StartGantry(1), StartGantry(2), 1);
            this.GPositionDispensing();
            error = error + this.SetContiusMode();
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.StartDispensing();
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            timeStart = tic;                    %Timing line movement
            this.gantry.MoveToLinear(StopGantry(1), StopGantry(2), this.dispSpeed);
            this.gantry.WaitForMotionAll();
            timeStop(1) = toc(timeStart);       %Timing line movement line 0 --> timeStop(1)
            fprintf('Line %d -> %.3f\n', 0, timeStop(1))
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                % Flip Start and Stop point if line number is odd
                if rem(Line,2) ~= 0
                    Temporal = StartSensor;
                    StartSensor = StopSensor;
                    StopSensor = Temporal;
                end
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor)- this.glueOff;
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor)- this.glueOff;
                
                %When last movement finished, continue with next line
                this.gantry.WaitForMotionAll()
                
                this.gantry.MoveTo(this.gantry.X,StartGantry(1),this.dispSpeed)
                this.gantry.MoveTo(this.gantry.Y,StartGantry(2),this.dispSpeed)
                this.gantry.WaitForMotionAll()
                timeStart = tic;                    %Timing line movement
                this.gantry.MoveToLinear(StopGantry(1), StopGantry(2), this.dispSpeed);
                this.gantry.WaitForMotionAll()
                timeStop(Line+1) = toc(timeStart);  %Timing line movement line x -> timeStop(x+1)
                fprintf('Line %d -> %.3f\n', Line, timeStop(Line+1))
            end
            this.gantry.WaitForMotionAll()
            error = error + this.StartDispensing();
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
            end
            save('R3S0_times.mat', 'timeStop')      %Save the times measured in a file for each sensor
            this.gantry.zSecurityPosition();
        end
        
        function DispenseTime(this, Sensor)
            % Generic Dispense function
            % Dispensing procedure for indicated Sensor setting the
            % dispenser in timming mode.
            % Arguments: Sensor String
            %
            
            this.SetTimingMode();
            
            switch Sensor
                case 'R0'
                    nLines = 28;
                    this.f1 = this.petal1.fiducials_sensors.R0{4};
                    this.f2 = this.petal1.fiducials_sensors.R0{3};
                    this.f3 = this.petal1.fiducials_sensors.R0{1};
                    this.f4 = this.petal1.fiducials_sensors.R0{2};
                    %                     nLines = (this.f1(2) - this.f2(2)-2*this.OffGlueStart)/this.Pitch
                    load('R0.mat', 'timeStop');
                case 'R1'
                    nLines = 22;
                    this.f1 = this.petal1.fiducials_sensors.R1{4};
                    this.f2 = this.petal1.fiducials_sensors.R1{3};
                    this.f3 = this.petal1.fiducials_sensors.R1{1};
                    this.f4 = this.petal1.fiducials_sensors.R1{2};
                    load('R1.mat', 'timeStop');
                case 'R2'
                    nLines = 15;
                    this.f1 = this.petal1.fiducials_sensors.R2{4};
                    this.f2 = this.petal1.fiducials_sensors.R2{3};
                    this.f3 = this.petal1.fiducials_sensors.R2{1};
                    this.f4 = this.petal1.fiducials_sensors.R2{2};
                    load('R2.mat', 'timeStop');
                case 'R3S0'
                    nLines = 32;
                    this.f1 = this.petal1.fiducials_sensors.R3S0{4};
                    this.f2 = this.petal1.fiducials_sensors.R3S0{3};
                    this.f3 = this.petal1.fiducials_sensors.R3S0{1};
                    this.f4 = this.petal1.fiducials_sensors.R3S0{2};
                    load('R3S0.mat', 'timeStop');
                case 'R3S1'
                    nLines = 32;
                    this.f1 = this.petal1.fiducials_sensors.R3S1{4};
                    this.f2 = this.petal1.fiducials_sensors.R3S1{3};
                    this.f3 = this.petal1.fiducials_sensors.R3S1{1};
                    this.f4 = this.petal1.fiducials_sensors.R3S1{2};
                    load('R3S1.mat', 'timeStop');
                case 'R4S0'
                    nLines = 30;
                    this.f1 = this.petal1.fiducials_sensors.R4S0{4};
                    this.f2 = this.petal1.fiducials_sensors.R4S0{3};
                    this.f3 = this.petal1.fiducials_sensors.R4S0{1};
                    this.f4 = this.petal1.fiducials_sensors.R4S0{2};
                    load('R4S0.mat', 'timeStop');
                case 'R4S1'
                    nLines = 30;
                    this.f1 = this.petal1.fiducials_sensors.R4S1{4};
                    this.f2 = this.petal1.fiducials_sensors.R4S1{3};
                    this.f3 = this.petal1.fiducials_sensors.R4S1{1};
                    this.f4 = this.petal1.fiducials_sensors.R4S1{2};
                    load('R4S1.mat', 'timeStop');
                case 'R5S0'
                    nLines = 27;
                    this.f1 = this.petal1.fiducials_sensors.R5S0{4};
                    this.f2 = this.petal1.fiducials_sensors.R5S0{3};
                    this.f3 = this.petal1.fiducials_sensors.R5S0{1};
                    this.f4 = this.petal1.fiducials_sensors.R5S0{2};
                    load('R5S0.mat', 'timeStop');
                case 'R5S1'
                    nLines = 27;
                    this.f1 = this.petal1.fiducials_sensors.R5S1{4};
                    this.f2 = this.petal1.fiducials_sensors.R5S1{3};
                    this.f3 = this.petal1.fiducials_sensors.R5S1{1};
                    this.f4 = this.petal1.fiducials_sensors.R5S1{2};
                    load('R5S1.mat', 'timeStop');
                otherwise
                    fprintf ('\n\t Error, "%s" is not a valid sensor name: ', Sensor);
                    disp('"R0", "R1", "R2", "R3S0", "R3S1", "R4S0", "R4S1", "R5S0", "R5S1"');
                    return
            end
            
            Line = 0;
            error = 0;
            fprintf('%.3f ; ',timeStop);
            disp(' ');
            time = uint16((timeStop*1000) - 480);  %380   %Convert from seg to ms and estimate a delay of 380ms for Ultimus
            fprintf('%d ; ',time);
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            % Dispense first line in Sensor coordinates
            [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
            
            % Calculate first line in Gantry coordinates
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor) - this.glueOff;
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor) - this.glueOff;
            
            % Move to Start Position and start dispensing
            this.gantry.MoveToFast(StartGantry(1), StartGantry(2), 1);
            this.GPositionDispensing();
            error = error + this.SetTime(time(1));
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            error = error + this.StartDispensing();
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            this.gantry.MoveToLinear(StopGantry(1), StopGantry(2), this.dispSpeed);
            tic
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                % Flip Start and Stop point if line number is odd
                if rem(Line,2) ~= 0
                    Temporal = StartSensor;
                    StartSensor = StopSensor;
                    StopSensor = Temporal;
                end
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor) - this.glueOff;
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor) - this.glueOff;
                %When last movement finished, continue with next line 
                this.gantry.WaitForMotionAll()
                toc
                error = error + this.SetTime(time(Line+1));
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                    return
                end
                fprintf('Line %d (%d) -> ',Line, time(Line+1));
                this.gantry.WaitForMotionAll()
                this.gantry.MoveToLinear(StartGantry(1), StartGantry(2), this.dispSpeed);
                pause(0.3)
                error = error + this.StartDispensing();
                if error ~= 0
                    fprintf ('\n DISPENSER ERROR \n');
                end
                this.gantry.MoveToLinear(StopGantry(1), StopGantry(2), this.dispSpeed);
                tic
            end
            this.gantry.WaitForMotionAll()
%             error = error + this.StartDispensing();
%             if error ~= 0
%                 fprintf ('\n DISPENSER ERROR \n');
%             end
            this.gantry.zSecurityPosition();
            this.gantry.MoveToFast(0,0);
            this.gantry.WaitForMotionAll();
        end
        
        
        %% Plotting Patterns %%
        
        function Plot(this, Sensor)
            % Generic Plot function
            % Plot dispensing procedure in sensor CS and gantry CS
            % Arguments: none
            %
            
            switch Sensor
                case 'R0'
                    nLines = 28;
                    this.f1 = this.petal1.fiducials_sensors.R0{4};
                    this.f2 = this.petal1.fiducials_sensors.R0{3};
                    this.f3 = this.petal1.fiducials_sensors.R0{1};
                    this.f4 = this.petal1.fiducials_sensors.R0{2};
                    fig = 10;
                    %                     nLines = (this.f1(2) - this.f2(2)-2*this.OffGlueStart)/this.Pitch
                case 'R1'
                    nLines = 22;
                    this.f1 = this.petal1.fiducials_sensors.R1{4};
                    this.f2 = this.petal1.fiducials_sensors.R1{3};
                    this.f3 = this.petal1.fiducials_sensors.R1{1};
                    this.f4 = this.petal1.fiducials_sensors.R1{2};
                    fig = 11;
                case 'R2'
                    nLines = 15;
                    this.f1 = this.petal1.fiducials_sensors.R2{4};
                    this.f2 = this.petal1.fiducials_sensors.R2{3};
                    this.f3 = this.petal1.fiducials_sensors.R2{1};
                    this.f4 = this.petal1.fiducials_sensors.R2{2};
                    fig = 20;
                case 'R3S0'
                    nLines = 32;
                    this.f1 = this.petal1.fiducials_sensors.R3S0{4};
                    this.f2 = this.petal1.fiducials_sensors.R3S0{3};
                    this.f3 = this.petal1.fiducials_sensors.R3S0{1};
                    this.f4 = this.petal1.fiducials_sensors.R3S0{2};
                    fig = 30;
                case 'R3S1'
                    nLines = 32;
                    this.f1 = this.petal1.fiducials_sensors.R3S1{4};
                    this.f2 = this.petal1.fiducials_sensors.R3S1{3};
                    this.f3 = this.petal1.fiducials_sensors.R3S1{1};
                    this.f4 = this.petal1.fiducials_sensors.R3S1{2};
                    fig = 31;
                case 'R4S0'
                    nLines = 30;
                    this.f1 = this.petal1.fiducials_sensors.R4S0{4};
                    this.f2 = this.petal1.fiducials_sensors.R4S0{3};
                    this.f3 = this.petal1.fiducials_sensors.R4S0{1};
                    this.f4 = this.petal1.fiducials_sensors.R4S0{2};
                    fig = 40;
                case 'R4S1'
                    nLines = 30;
                    this.f1 = this.petal1.fiducials_sensors.R4S1{4};
                    this.f2 = this.petal1.fiducials_sensors.R4S1{3};
                    this.f3 = this.petal1.fiducials_sensors.R4S1{1};
                    this.f4 = this.petal1.fiducials_sensors.R4S1{2};
                    fig = 41;
                case 'R5S0'
                    nLines = 27;
                    this.f1 = this.petal1.fiducials_sensors.R5S0{4};
                    this.f2 = this.petal1.fiducials_sensors.R5S0{3};
                    this.f3 = this.petal1.fiducials_sensors.R5S0{1};
                    this.f4 = this.petal1.fiducials_sensors.R5S0{2};
                    fig = 50;
                case 'R5S1'
                    nLines = 27;
                    this.f1 = this.petal1.fiducials_sensors.R5S1{4};
                    this.f2 = this.petal1.fiducials_sensors.R5S1{3};
                    this.f3 = this.petal1.fiducials_sensors.R5S1{1};
                    this.f4 = this.petal1.fiducials_sensors.R5S1{2};
                    fig = 51;
                otherwise
                    fprintf ('\n\t Error, "%s" is not a valid sensor name: ', Sensor);
                    disp('"R0", "R1", "R2", "R3S0", "R3S1", "R4S0", "R4S1", "R5S0", "R5S1"');
                    return
            end
            
            Line = 0;
            %Calculate Start and Stop gluing lines
            this.LinesCalculation();
            
            this.petal1.plotFiducialsInGantry;
            
            %Plot fiducials in Sensor system
            figure(fig);
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
            this.PlotLine(StartSensor, StopSensor, fig)
            
            % Calculate first line in Gantry coordinates
%             transpose(this.glueOff)
            StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor) - this.glueOff;
            StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor) - this.glueOff;
            this.PlotLine(StartGantry, StopGantry, 1)
            
            for Line=1:nLines
                % Calculate line in Sensor coordinates
                [StartSensor, StopSensor] = this.CalculateStartAndStop(Line);
                % Flip Start and Stop point if line number is odd
                if rem(Line,2) ~= 0
                    Temporal = StartSensor;
                    StartSensor = StopSensor;
                    StopSensor = Temporal;
                end
                this.PlotLine(StartSensor, StopSensor, fig)
                title(['Glue pattern in Sensor Coordinates of sensor: ' Sensor]);
                
                %Convert to Gantry coordinates
                StartGantry = this.petal1.sensor_to_gantry(StartSensor, Sensor) - this.glueOff;
                StopGantry = this.petal1.sensor_to_gantry(StopSensor, Sensor) - this.glueOff;
                this.PlotLine(StartGantry, StopGantry, 1)
            end
        end
        
        
        %% Calculating functions %%
        
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
            
%             Start(2) = this.f1(2,1) - this.Pitch * Line - this.OffGlueStart(2) + this.glueOff(2);
%             Start(1) = this.mLine12*Start(2) + this.qLine12 + this.OffGlueStart(1) + this.glueOff(1);
%             Stop(2) = this.f3(2,1) - this.Pitch * Line - this.OffGlueStart(2) + this.glueOff(2);
%             Stop(1) = this.mLine34*Stop(2) + this.qLine34 - this.OffGlueStart(1) + this.glueOff(1);
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
            this.gantry.MoveToLinear(Start(1), Start(2), 1);
            this.GPositionDispensing();
            error = this.StartDispensing();
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            this.gantry.MoveToLinear(Stop(1), Stop(2), this.dispSpeed, 1);
            this.GPositionWaiting();
        end
    end
end

