classdef PetalDispensing < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        gantry;
        NumPetals;
        dispenser;
        ready = 0;
        zSecureHeigh = 20;              % Min Z height for fast movements
        zWaitingHeigh = 10;            % Z Position prepared to dispense
        zDispensingHeigh = 5;             % Z Position while glue dispensing
    end
    
    properties (Constant, Access = public)
        % All units in mm
        Pitch = 3.4;
        OffGlueStarX = 5;   % Distance from the sensor edge
        OffGlueStarY = 5;
        glueOffX = 0;       %Offset Between camera and syrenge
        glueoffY = 0;
        TestingZone = [100, 100, 0, 0]; % X,Y,Z1,Z2
        
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
        function this = PetalDispensing(dispenser_obj, gantry_obj)
            % Constructor function.
            % Arguments: dispense_obj, gantry_obj (Gantry or OWIS)
            % present on the setup.
            % Returns: this object
            
            this.dispenser = dispenser_obj;
            this.dispenser.Connect;
            if this.dispenser.IsConnected == 1
                disp('Dispenser connected succesfully')
            else
                disp('Dispenser connecting FAIL');
            end
            
            if gantry_obj.IsConnected == 1
                this.gantry = gantry_obj;
                disp('Gantry connected succesfully')
            else
                disp('Gantry connecting FAIL');
            end
            error = this.DispenserDefaults();
            if error ~= 0
                fprintf ('Error -> Could not set Dispenser');
            end
        end
        
        %% Macros Dispenser%%
        
        function error = DispenserDefaults(this)
            % DispenserDefaults(this)
            % Arguments: none
            % Returns: 0 if communication was OK
            % Set default dispenser setting
            
            error = 0;
            cmd = sprintf ('E6--02');      % Set dispenser units in KPA
            error = error + this.dispenser.SetUltimus(cmd);
            
            cmd = sprintf('E7--00');      % Set dispenser Vacuum unit KPA
            error = error + this.dispenser.SetUltimus(cmd);
            
            cmd = sprintf('PS--0040');    % Set dispenser pressure to 40 KPA = 0.4 BAR
            error = error + this.dispenser.SetUltimus(cmd);
            
            cmd = sprintf('VS--0050');    % Set dispenser vacuum to 0.12 KPA = 0.5 "H2O
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
            
            cmd = sprintf('DS-T%04d',time) %Setting time in ms
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
        end
        
        function ReadDispenserStatus(this)
            % function ReadDispenserStatus (this)
            % Arguments: none
            % Return Error (0 -> No error)
            % 1- Z2 axis go to dispensing Heigh and wait
            % 2- Send "dispense" command to the dispenser.
            
            cmd = 'E4--';
            FeedBack = this.dispenser.GetUltimus(cmd);
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
            c = strcat(FeedBack(5), FeedBack(6), FeedBack(7), FeedBack(8));
            value = str2double(c);
            fprintf('Dispensing Pressure: %d %s\n',value, unitsP);
            
            c = strcat(FeedBack(11), FeedBack(12), FeedBack(13), FeedBack(14), FeedBack(15));
            value = str2double(c)/10;
            fprintf('Dispensing Time: %d ms\n',value);
            
            c = strcat(FeedBack(18), FeedBack(19), FeedBack(20), FeedBack(21));
            value = str2double(c);
            fprintf('Vacuum: %d %s\n',value, unitsV);
        end
        
        %% Macros Gantry %%
        
        function GPositionDispensing(this)
            % function GPositionDispensing(this)
            % Arguments: none
            % Return Error (0 -> No error)
            this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh, this.zLowSpeed,1);
        end
        
        function GPostionWaiting (this)
            % function GPositionDispensing(this)
            % Arguments: none
            % Return Error (0 -> No error)
            this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh, this.zLowSpeed,1);
        end
        
        %% Testing %%
        
        function DispenseTest1(this)
            % DispenseTest function
            % Dispense 4 dropplets
            % Arguments: none
            %
            t1 = 1000;  %mseg
            t2 = 300;
            t3 = 1000;
            error = 0;
            
            %             error = error + this.DispenserDefaults();
            disp('Move to test zone')
            this.gantry.MoveToFast(this.TestingZone(1), this.TestingZone(2));
            
            if error ~= 0
                fprintf ('\n ERROR \n');
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
                this.GPostionWaiting();
                this.gantry.MoveTo(this.z2Axis,this.zWaitingHeigh,this.zLowSpeed,1);
                this.gantry.WaitForMotion(this.z2Axis);
                % 2nd Dropplet
                disp('')
                disp('2nd dropplet')
                disp('')
                this.gantry.MoveBy(this.xAxis,10,5,1);
                this.StartDispensing();
                pause(t);
                this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh,this.zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                
                % 3rd Dropplet
                disp('')
                disp('3rd dropplet')
                disp('')
                this.gantry.MoveBy(this.yAxis,10,5,1);
                this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh,this.zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                this.StartDispensing();
                pause(t);
                this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh,this.zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                
                % 4th Dropplet
                disp('')
                disp('4th dropplet')
                disp('')
                this.gantry.MoveBy(this.xAxis,-10,5,1);
                this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh,this.zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                this.StartDispensing();
                pause(t);
                this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh,this.zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                
                this.gantry.MoveBy(this.yAxis,-10,5,1);
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
            
            
            error = error + this.SetTime(t1);
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
                    this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh,this.zLowSpeed);
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
            
            error = error + this.SetTime(t);
            if error ~= 0
                fprintf ('\n ERROR \n');
                return
            else
                % Dispensing Line 0
                % Lift Down syrenge
                this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh,this.zLowSpeed);
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
                this.gantry.MoveTo(this.z2Axis,this.zWaitingHeigh,this.zLowSpeed);
                this.gantry.WaitForMotion(this.z2Axis);
                
                for nLine=1:6
                    xStartPoint = xStartPoint + this.Pitch*nLine;
                    xStartGluing = 0;
                    this.gantry.MoveToFast(xStartPoint, yStartPoint)
                    % Lift Down syrenge
                    this.gantry.MoveTo(this.z2Axis,this.zDispensingHeigh,this.zLowSpeed);
                    this.gantry.WaitForMotion(this.z2Axis);
                    % Dispense one glue line
                    this.StartDispensing();
                    this.gantry.MoveBy(this.yAxis,LineLength,this.dispSpeed);
                    this.gantry.WaitForMotion(this.yAxis);
                    % Lift Up syrenge
                    this.gantry.MoveTo(this.z2Axis,this.zWaitingHeigh,this.zLowSpeed);
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
            this.yStartP = mLine12*xStartP +qLine12
        end
        
        function Line34Stop(this)
            % function Line12Start()
            % Arg: none
            % Return: none
            % Calculate line equations between F-F: 1-2 and 3-4 in the
            % petal system
            
            mLine34 = (Yf4 - Yf3)/(Xf4-Xf3)
            qLine34 = ((Xf4*Yf3) - (Xf3*Yf4)) / (Xf4-Xf3)
            this.yStopP = mLine34*xStartP +qLine34
        end
    end
end

