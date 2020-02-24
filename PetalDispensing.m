classdef PetalDispensing < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        robot;
        NumPetals;
        dispenser;
        ready = 0;
        zSecureHeigh = 20;              % Min Z height for fast movements
        zWorkingHeight = 10;            % Z Position prepared to dispense
        zDispenseHeigh = 0;             % Z Position while glue dispensing
    end
    
    properties (Constant, Access = public)
        % All units in mm
        Pitch = 3.4;
        OffGlueStarX = 5;   % Distance from the sensor edge 
        OffGlueStarY = 5;  
        glueOffX = 0;       %Offset Between camera and syrenge
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
            error = this.DispenserDefaults();
            if error ~= 0
                fprintf ('Error -> Could not set Dispenser');
            end
        end
        
        %% Moving improvements %%
        
        function zSecurityPosition(this)
            % function zSecurityPosition (this)
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
            % Operation:   1- Move all Z axis to a safe height and wait
            %              2- Then move X and Y axis to the desired zone.
            
            switch nargin
                case 4
                    
                case 3
                    mode = 0;
                otherwise
                    disp('\n Improper number of arguments ');
                    return
            end
            
            this.zSecurityPosition();
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
        
        function error = DispenserDefaults(this)
            % DispenserDefaults(this)
            % Arguments: none
            % Returns: 0 if communication was error
            % Set default dispenser setting
            
            error = 0;
            cmd = fprintf ('E--02');      % Set dispenser units in KPA
            error = error + this.dispenser.SetUltimus(cmd);
            
            cmd = fprintf('E7-00');      % Set dispenser Vacuum unit KPA
            error = error + this.dispenser.SetUltimus(cmd);
            
            cmd = fprintf('PS-4000');    % Set dispenser pressure to 40 KPA = 0.4 BAR
            error = error + this.dispenser.SetUltimus(cmd);
            
            error = error + this.setTime(1000);    % Dispenser in timing mode and t=1000 msec
        end
        
        function error = setTime(this, time)
            % setTime function (time)
            % Arguments: time -> Dispensing time (mseconds)
            % Returns: 0 if communication was OK
            % Set dispenser in timing mode and preset the desired time
            
            error = 0;
            cmd = sprintf('TT--');           %Setting timing mode
            error = error + this.dispenser.SetUltimus(cmd);
            
            cmd = sprintf('DS-T%d',time*10); %Setting time in ms
            error = error + this.dispenser.SetUltimus(cmd);
        end
        
        function error = StartDispensing(this)
            % StartDispensing function
            % Arguments: none
            % Return
            cmd = sprintf('DI--');
            error = this.dispenser.SetUltimus(cmd);
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
            error = 0;
            
            error = error + this.DispenserDefaults();
            this.MoveToFast(TestingZone(1), TestingZone(2));
            
            error = error + this.setTime(t1);
            if error ~= 0
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
            error = 0;
            
            
            error = error + this.DispenserDefaults();
            xStartPoint = this.TestingZone(1)+20;
            this.MoveToFast(xStartPoint, this.TestingZone(2));
            
            
            error = error + this.setTime(t1);
            if error ~= 0
                fprintf ('\n ERROR \n');
                return
            else
                
                LineLength = (t1 + delay) * this.dispSpeed;
                
                for i=1:nlines
                    xStartPoint = xStartPoint + this.Pitch;
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
            error = 0;
            xStartGluing = Xf1_G;
            yStartGluing = Yf1_G;
            xStopGluing = Xf3_G;
            yStopGluing = Yf3_G;
            
            error = error + this.DispenserDefaults();
            xStartPoint = this.TestingZone(1)+50;
            yStartPoint = this.TestingZone(2);
            this.MoveToFast(xStartPoint, yStartPoint);
            
            error = error + this.setTime(t);
            if error ~= 0
                fprintf ('\n ERROR \n');
                return
            else
                % Dispensing Line 0
                % Lift Down syrenge
                this.robot.MoveTo(this.robot.z2Axis,zDispenseHeigh,this.zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                % Dispense line 0
                this.StartDispensing();
                this.robot.MoveTo(this.robot.xAxis,xStopGluing,this.dispSpeed;
                this.robot.MoveTo(this.robot.yAxis,yStopGluing,this.dispSpeed;                
%                 this.robot.MoveBy(this.robot.xAxis,LineLength,this.dispSpeed;
%                 this.robot.MoveBy(this.robot.yAxis,LineLength,this.dispSpeed;
                this.robot.WaitForMotion(this.robot.xAxis);
                this.robot.WaitForMotion(this.robot.yAxis);

                % Lift Up syrenge
                this.robot.MoveTo(this.robot.z2Axis,this.zWorkingHeight,this.zLowSpeed);
                this.robot.WaitForMotion(this.robot.z2Axis);
                
                for nLine=1:6
                    xStartPoint = xStartPoint + this.Pitch*nLine;
                    xStartGluing = 
                    this.MoveToFast(xStartPoint, yStartPoint)
                    % Lift Down syrenge
                    this.robot.MoveTo(this.robot.z2Axis,zDispenseHeigh,this.zLowSpeed);
                    this.robot.WaitForMotion(this.robot.z2Axis);
                    % Dispense one glue line
                    this.StartDispensing();
                    this.robot.MoveBy(this.robot.yAxis,LineLength,this.dispSpeed;
                    this.robot.WaitForMotion(this.robot.yAxis);
                    % Lift Up syrenge
                    this.robot.MoveTo(this.robot.z2Axis,this.zWorkingHeight,this.zLowSpeed);
                    this.robot.WaitForMotion(this.robot.z2Axis);
                end
                
            end
            
            
        end
        
        function Line12Start(this)
            % function Line12Start() 
            % Arg: none
            % Return: none
            % Calculate line equations between F-F: 1-2 and 3-4 in the
            % petal system
            
            mLine12 = (Yf2 - Yf1)/(Xf2 - Xf1)
            qLine12 = ((Xf2*Yf1) - (Xf1*Yf2)) / (Xf2-Xf1)
            yStartP = mLine12*xStartP +qLine12
        end
        
        function Line34Stop(this)
            % function Line12Start() 
            % Arg: none
            % Return: none
            % Calculate line equations between F-F: 1-2 and 3-4 in the
            % petal system
            
            mLine34 = (Yf4 - Yf3)/(Xf4-Xf3)
            qLine34 = ((Xf4*Yf3) - (Xf3*Yf4)) / (Xf4-Xf3)
            yStartP = mLine34*xStartP +qLine34
        end
    end
    
