classdef PetalDispensing < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = protected)
        gantry;
        NumPetals;
        dispenser;
        ready = 0;
        zSecureHeigh = 20;              % Min Z height for fast movements
        zWorkingHeight = 10;            % Z Position prepared to dispense
        zDispenseHeigh = 5;             % Z Position while glue dispensing
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
        
        xAxis = 0;
        yAxis = 1;
        z1Axis = 4;
        z2Axis = 5;
    end
    
    
    methods
        
        %% Constructor %%
        function this = PetalDispensing(this, dispense_obj, gantry_obj)
            % Constructor function.
            % Arguments: dispense_obj, gantry_obj (Gantry or OWIS), PetalNum: 1 or 2
            % present on the setup.
            % Returns: this object
            
            if dispense_obj.IsConnected ~= 1
                fprintf ('Error -> dispenser is not connected')
            else
                this.dispenser = dispense_obj;
            end
            if gantry_obj.IsConnected ~= 1
                fprintf ('Error -> gantry object is not connected');
            else
                this.gantry = gantry_obj;
            end
            error = this.DispenserDefaults();
            if error ~= 0
                fprintf ('Error -> Could not set Dispenser');
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
            
            cmd = sprintf('DS-T%4d',time); %Setting time in ms
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
            this.gantry.MoveToFast(this.TestingZone(1), this.TestingZone(2));
            
            error = error + this.setTime(t1);
            if error ~= 0
                fprintf ('\n ERROR \n');
                return
            else
                
                % 1st Dropplet
                this.gantry.MoveTo(z2Axis,0,zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                this.StartDispensing();
                pause(t1 + 200);
                this.gantry.MoveTo(z2Axis,zDispenseHeigh,zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                
                
                % 2nd Dropplet
                this.gantry.MoveBy(this.xAxis,1,1);
                this.gantry.WaitForMotion(this.xAxis);
                this.gantry.MoveBy(this.xAxis,1,1);
                this.gantry.WaitForMotion(this.xAxis);
                this.StartDispensing();
                pause(t1 + 200);
                this.gantry.MoveTo(z2Axis,zDispenseHeigh,zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                
                % 3rd Dropplet
                this.gantry.MoveBy(this.yAxis,1,1);
                this.gantry.WaitForMotion(this.xAxis);
                this.gantry.MoveTo(z2Axis,0,zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                this.StartDispensing();
                pause(t1 + 200);
                this.gantry.MoveTo(z2Axis,zDispenseHeigh,zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                
                % 4th Dropplet
                this.gantry.MoveBy(this.xAxis,-1,1);
                this.gantry.WaitForMotion(this.xAxis);
                this.gantry.MoveTo(z2Axis,0,zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                this.StartDispensing();
                pause(t1 + 200);
                this.gantry.MoveTo(z2Axis,zDispenseHeigh,zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                
                this.gantry.MoveBy(this.yAxis,-1,1);
                this.gantry.WaitForMotion(this.xAxis);
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
            this.gantry.MoveToFast(xStartPoint, this.TestingZone(2));
            
            
            error = error + this.setTime(t1);
            if error ~= 0
                fprintf ('\n ERROR \n');
                return
            else
                
                LineLength = (t1 + delay) * this.dispSpeed;
                
                for i=1:nlines
                    xStartPoint = xStartPoint + this.Pitch;
                    % Lift Down syrenge
                    this.gantry.MoveTo(this.z2Axis,0,this.zLowSpeed);
                    this.gantry.WaitForMotion(this.z2Axis);
                    % Dispense one glue line
                    this.StartDispensing();
                    this.gantry.MoveBy(this.yAxis,LineLength,this.dispSpeed);
                    this.gantry.WaitForMotion(this.yAxis);
                    % Lift Up syrenge
                    this.gantry.MoveTo(this.z2Axis,this.zDispenseHeigh,this.zLowSpeed);
                    this.gantry.WaitForMotion(this.z2Axis);
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
            this.gantry.MoveToFast(xStartPoint, yStartPoint);
            
            error = error + this.setTime(t);
            if error ~= 0
                fprintf ('\n ERROR \n');
                return
            else
                % Dispensing Line 0
                % Lift Down syrenge
                this.gantry.MoveTo(this.z2Axis,this.zDispenseHeigh,this.zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                % Dispense line 0
                this.StartDispensing();
                this.gantry.MoveTo(this.xAxis,xStopGluing,this.dispSpeed);
                this.gantry.MoveTo(this.yAxis,yStopGluing,this.dispSpeed);                
%                 this.gantry.MoveBy(this.xAxis,LineLength,this.dispSpeed;
%                 this.gantry.MoveBy(this.yAxis,LineLength,this.dispSpeed;
                this.gantry.WaitForMotion(this.xAxis);
                this.gantry.WaitForMotion(this.yAxis);

                % Lift Up syrenge
                this.gantry.MoveTo(this.z2Axis,this.zWorkingHeight,this.zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                
                for nLine=1:6
                    xStartPoint = xStartPoint + this.Pitch*nLine;
                    xStartGluing = 0;
                    this.gantry.MoveToFast(xStartPoint, yStartPoint)
                    % Lift Down syrenge
                    this.gantry.MoveTo(this.z2Axis,this.zDispenseHeigh,this.zLowSpeed);
                    this.gantry.WaitForMotion(this.z2Axis);
                    % Dispense one glue line
                    this.StartDispensing();
                    this.gantry.MoveBy(this.yAxis,LineLength,this.dispSpeed);
                    this.gantry.WaitForMotion(this.yAxis);
                    % Lift Up syrenge
                    this.gantry.MoveTo(this.z2Axis,this.zWorkingHeight,this.zLowSpeed);
                    this.gantry.WaitForMotion(this.z2Axis);
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
end
    
