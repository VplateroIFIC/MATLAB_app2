classdef PetalDispensing < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        robot;
        NumPetals;
        dispenser;
        ready = 0;
        zSecureHeigh = 20;
        zDispenseHeigh = 10;
        axis = [0, 0, 0, 0];
        xAxis;
        yAxis;
        z1Axis;
        z2Axis;
    end
    
    properties (Constant, Access = public)
        % All units in mm
        Pitch = 3.4;
        OffGlueStarX = 5;
        OffGlueStarY = 5;
        glueOffX = 0;
        glueoffY = 0;
        TestingZone = [200, 400, 0, 0]; % X,Y,Z1,Z2
        
        zHighSpeed = 10;
        zLowSpeed = 5;
        
        xyHighSpeed = 20;
        xyLowSpeed = 5;
        
        dispSpeed = 60;
    end
    
    
    methods
        
        %% Constructor %%
        function this = PetalDispensing(this, dispense_obj, robot_obj, num_petals)
            % Constructor function.
            % Arguments: dispense_obj, robot_obj (Gantry or OWIS), PetalNum: 1 or 2
            % present on the setup.
            % Returns: this object
            switch nargin
                case 4
                    this.NumPetals = num_petals;
                case 2
                    this.NumPetals = 1;
            end
            if dispense_obj.Connected ~= 1
                fprintf ('Error -> dispenser is not connected')
            else
                this.dispenser = dispense_obj;
            end
            if robot_obj.Connected ~= 1
                fprintf ('Error -> robot object is not connected');
            else
                this.robot = robot_obj;
            end
            OK = this.DispenserDefaults();
        end
        
        %% Moving improvements %%
        
        function zMovePosition(this)
            % function zMovePosition (this)
            % Arguments: none
            % Return: none
            % 1- Move all Z axis to the defined safe height
            % 2- Wait until movement finishes
            
            this.robot.MoveTo(this.robot.z1Axis, this.zSecureHeigh,this.zHighSpeed);
            this.robot.MoveTo(this.robot.z2Axis, this.zSecureHeigh,this.zHighSpeed);
            this.robot.WaitForMotion.(this.robot.z1Axis);
            this.robot.WaitForMotion.(this.robot.z2Axis);
            return
        end
        
        function MoveToFast(this, X, Y, mode)
            % function MoveToFast (this, X, Y)
            % Arguments: X position, Y position, mode (0-> Wait until movement finishes, 1-> No wait
            % Return: none
            % 1- Move all Z axis to a safe height
            % 2- Then move X and Y axis to the desired zone.
            
            switch nargin
                case 4
                    
                case 3
                    mode = 0;
                otherwise
                    disp('\n Improper number of arguments ');
                    return
            end
            
            this.zMovePosition();
            this.robot.MoveTo(this.robot.xAxis, X, this.xyHightSpeed);
            this.robot.MoveTo(this.robot.yAxis, Y, this.xyHightSpeed);
            if mode == 0
                this.robot.WaitForMotion.(this.robot.xAxis);
                this.robot.WaitForMotion.(this.robot.y2Axis);
            else
                return
            end
        end
        
        %% Settings %%
        
        function OK = DispenserDefaults(this)
            % DispenserDefaults(this)
            % Arguments: none
            % Returns: 0 if communication was OK
            % Set default dispenser setting
            
            OK = 0;
            cmd = fprintf ('E--02');      % Set dispenser units in KPA
            OK = OK + this.dispenser.SetUltimus(cmd);
            
            cmd = fprintf('E7-00');      % Set dispenser Vacuum unit KPA
            OK = OK + this.dispenser.SetUltimus(cmd);
            
            cmd = fprintf('PS-4000');    % Set dispenser pressure to 40 KPA = 0.4 BAR
            OK = OK + this.dispenser.SetUltimus(cmd);
            
            OK = OK + this.setTime(1000);    % Dispenser in timing mode and t=1000 msec
        end
        
        function OK = setTime(this, time)
            % setTime function (time)
            % Arguments: time -> Dispensing time (mseconds)
            % Returns: 0 if communication was OK
            % Set dispenser in timing mode and preset the desired time
            
            OK = 0;
            cmd = sprintf('TT--');           %Setting timing mode
            OK = OK + this.dispenser.SetUltimus(cmd);
            
            cmd = sprintf('DS-T%d',time*10); %Setting time in ms
            OK = OK + this.dispenser.SetUltimus(cmd);
        end
        
        function OK = StartDispensing(this)
            % StartDispensing function
            % Arguments: none
            % Return
            cmd = sprintf('DI--');
            OK = this.dispenser.SetUltimus(cmd);
        end
        
        %% Testing %%
        
        function DispenseTest1(this)
            % DispenseTest function
            % Dispense 4 dropplets
            % Arguments: none
            %
            t1 = 100;  %mseg
            t2 = 300;
            t3 = 1000;
            OK = 0;
            
            OK = OK + this.DispenserDefaults();
            this.MoveToFast(TestingZone(1), TestingZone(2));
            
            OK = OK + this.setTime(t1);
            if OK ~= 0
                fprintf ('\n ERROR \n');
                return
            else
                
                % 1st Dropplet
                this.robot.MoveTo(z2Axis,0,zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                this.StartDispensing();
                pause(t1 + 200);
                this.robot.MoveTo(z2Axis,zDispenseHeigh,zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                
                
                % 2nd Dropplet
                this.robot.MoveBy(this.robot.xAxis,1,1);
                this.robot.WaitForMotion(this.robot.xAxis);
                this.robot.MoveBy(this.robot.xAxis,1,1);
                this.robot.WaitForMotion(this.robot.xAxis);
                this.StartDispensing();
                pause(t1 + 200);
                this.robot.MoveTo(z2Axis,zDispenseHeigh,zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                
                % 3rd Dropplet
                this.robot.MoveBy(this.robot.yAxis,1,1);
                this.robot.WaitForMotion(this.robot.xAxis);
                this.robot.MoveTo(z2Axis,0,zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                this.StartDispensing();
                pause(t1 + 200);
                this.robot.MoveTo(z2Axis,zDispenseHeigh,zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                
                % 4th Dropplet
                this.robot.MoveBy(this.robot.xAxis,-1,1);
                this.robot.WaitForMotion(this.robot.xAxis);
                this.robot.MoveTo(z2Axis,0,zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                this.StartDispensing();
                pause(t1 + 200);
                this.robot.MoveTo(z2Axis,zDispenseHeigh,zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                
                this.robot.MoveBy(this.robot.yAxis,-1,1);
                this.robot.WaitForMotion(this.robot.xAxis);
            end
        end
        
        
        function DispenseTest2(this)
            % DispenseTest2 function
            % Dispense four parallel lines
            % OK
            % Return 0 if everything is OK
            
            t1 = 1000;  %mseg
            nlines = 5;
            t2 = 300;
            t3 = 1000;
            delay = 100;
            OK = 0;
            
            
            OK = OK + this.DispenserDefaults();
            StartPointX = this.TestingZone(1)+20;
            this.MoveToFast(StartPointX, this.TestingZone(2));
            
            
            OK = OK + this.setTime(t1);
            if OK ~= 0
                fprintf ('\n ERROR \n');
                return
            else
                
                LineLength = (t1 + delay) * this.dispSpeed;
                
                for i=1:nlines
                    StartPointX = StartPointX + this.Pitch;
                    % Lift Down syrenge
                    this.robot.MoveTo(this.robot.z2Axis,0,this.zLowSpeed);
                    this.robot.WaitForMotion(this.robot.z2Axis);
                    % Dispense one glue line
                    this.StartDispensing();
                    this.robot.MoveBy(this.robot.yAxis,LineLength,this.dispSpeed;
                    this.robot.WaitForMotion(this.robot.yAxis);
                    % Lift Up syrenge
                    this.robot.MoveTo(this.robot.z2Axis,this.zDispenseHeigh,this.zLowSpeed);
                    this.robot.WaitForMotion(this.robot.z2Axis);
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
            nlines = 5;
            delay = 100;
            OK = 0;
            
            OK = OK + this.DispenserDefaults();
            StartPointX = this.TestingZone(1)+50;
            StartPointY = this.TestingZone(2);
            this.MoveToFast(StartPointX, StartPointY);
            
            OK = OK + this.setTime(t);
            if OK ~= 0
                fprintf ('\n ERROR \n');
                return
            else
                % Dispensing Line 0
                % Lift Down syrenge
                this.robot.MoveTo(this.robot.z2Axis,0,this.zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                % Dispense one glue line
                this.StartDispensing();
                this.robot.MoveBy(this.robot.yAxis,LineLength,this.dispSpeed;
                this.robot.WaitForMotion(this.robot.yAxis);
                % Lift Up syrenge
                this.robot.MoveTo(this.robot.z2Axis,this.zDispenseHeigh,this.zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                
                for i=1:6
                    StartPointX = StartPointX + this.Pitch;
                    this.MoveToFast(StartPointX, StartPointY)
                    % Lift Down syrenge
                    this.robot.MoveTo(this.robot.z2Axis,0,this.zLowSpeed);
                    this.robot.WaitForMotion(this.robot.z2Axis);
                    % Dispense one glue line
                    this.StartDispensing();
                    this.robot.MoveBy(this.robot.yAxis,LineLength,this.dispSpeed;
                    this.robot.WaitForMotion(this.robot.yAxis);
                    % Lift Up syrenge
                    this.robot.MoveTo(this.robot.z2Axis,this.zDispenseHeigh,this.zLowSpeed);
                    this.robot.WaitForMotion(this.robot.z2Axis);
                end
                
            end
            
            
        end
    end
    
