classdef PetalDispensing < handle
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        gantry;
        NumPetals;
        dispenser;
        ready = 0;
        zWaitingHeigh = 10;            % Z Position prepared to dispense
        zDispensingHeigh = 5;             % Z Position while glue dispensing
    end
    
    properties (Access = private)
        Xf1;
        Yf1;
        Xf2;
        Yf2;
        Xf3;
        Yf3;
        Xf4;
        Yf4; 
    end

    %%Temporal properties to be deleted
    properties (Access = public)
        fiducial_1 = [-359.4739, 133.3216];
        fiducial_2 = [223.8666, 277.0741];
    end
        
    properties (Constant, Access = public)
        % All units in mm
        Pitch = 3.4;
        OffGlueStartX = 5;   % Distance from the sensor edge
        OffGlueStartY = 5;
        glueOffX = 0;       %Offset Between camera and syrenge
        glueoffY = 0;
        TestingZone = [-100, -100, 0, 0]; % X,Y,Z1,Z2
        
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
        
        function GPostionWaiting (this)
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
                this.GPostionWaiting();
                % 2nd Dropplet
                disp('')
                disp('2nd dropplet')
                disp('')
                this.gantry.MoveBy(this.xAxis,10,5,1);
                this.GPositionDispensing();
                this.StartDispensing();
                t = t1/1000 + 0.2;
                pause(t);
                this.GPostionWaiting();
                
                % 3rd Dropplet
                disp('')
                disp('3rd dropplet')
                disp('')
                this.gantry.MoveBy(this.yAxis,10,5,1);
                this.GPositionDispensing();
                this.StartDispensing();
                t = t1/1000 + 0.2;
                pause(t);
                this.GPostionWaiting();
                
                % 4th Dropplet
                disp('')
                disp('4th dropplet')
                disp('')
                this.gantry.MoveBy(this.xAxis,-10,5,1);
                this.GPositionDispensing();
                this.StartDispensing();
                t = t1/1000 + 0.2;
                pause(t);
                this.GPostionWaiting();
                this.gantry.MoveBy(this.yAxis,-10,5,1);
            end
        end
        
        function DispenseTest2(this)
            % DispenseTest2 function
            % Dispense four parallel lines
            % OK
            % Return 0 if everything is OK
            
            t1 = 1000;  %mseg
            nlines = 5;
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
                for i=0:nlines
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
                    this.GPostionWaiting();
                    
                end
            end
        end
        
        %% Dispensing R0 %%
        
        function R0_Pattern(this)
            % DispenseTest function
            % Dispense 4 dropplets
            % Arguments: none
            %
            
            %Fiducials for R0
            this.Xf1=0.54  + this.OffGlueStartX;
            this.Yf1=36.13 - this.OffGlueStartY;
            
            this.Xf2=104.41 - this.OffGlueStartX;
            this.Yf2=48.19 - this.OffGlueStartY;
            
            this.Xf3=0.08  + this.OffGlueStartX;
            this.Yf3=-40.78 + this.OffGlueStartY;
            
            this.Xf4=104.29  - this.OffGlueStartX;
            this.Yf4=-49.41 + this.OffGlueStartY;
            
            
            t = 1000;  %mseg
            nlines = 28;
            error = 0;
            xStartGantry = Xf1_G;
            yStartGantry = Yf1_G;
            xStopGantry = Xf3_G;
            yStopGantry = Yf3_G;
            
            error = error + this.DispenserDefaults();
            error = error + this.SetTime(t);
            
            % Dispensing line 0
            this.gantry.MoveToFast(xStartGantry, yStartGantry, 1);
            this.GPositionDispensing();
            error = error + gluing.StartDispensing();
            if error ~= 0
                fprintf ('\n DISPENSER ERROR \n');
                return
            end
            this.gantry.MoveToLinear(xStopGantry, yStopGantry, this.dispSpeed, 1);
            this.GPostionWaiting();
            
            % Dispensing loop          
            for nLine=1:nlines
                if 1<=nLine && nLine<=6
                    t = 1050;
                elseif 7<=nLine && nLine<=12
                    t = 1100;
                elseif 13<=nLine && nLine<=18
                    t = 1200;
                elseif 19<=nLine && nLine<=24
                    t = 1300;
                elseif 25<=nLine && nLine<=28
                    t = 1400;
                end
                this.SetTime(t);
                
                %Calculating Start and Stop positions
                xStartPetal = xStartPetal + this.Pitch*nLine;
                xStartGantry = this.PetalToGantry(xStartPetal);
                yStartPetal = this.Line12Start();
                yStartGantry = this.PetalToGantry(yStartPetal);
                xStopPetal = Xf3 + this.Pitch*nLine;
                xStopGantry = this.PetalToGantry(xStopPetal);
                yStopPetal = Line34Stop();
                yStopGantry = this.PetalToGantry(yStopPetal);
                
                [x,Y] = this.PetalToGantry(xpetal,ypetal);
                
                %Prepare to dispense
                this.gantry.MoveToFast(xStartGantry, yStartGantry, 1);
                this.GPositionDispensing();
                %Dispensing line
                this.StartDispensing();
                this.gantry.MoveToLinear(xStopGantry, yStopGantry, this.dispSpeed, 1);
                this.GPostionWaiting()
            end
            
            % Dispensing Lines 7-12
            t = 1100;
            this.SetTime(t);          
            
        end
        
        function yStartP = Line12Start(this)
            % function Line12Start()
            % Arg: none
            % Return: none
            % Calculate line equations between F-F: 1-2 and 3-4 in the
            % petal system
            
            mLine12 = (Yf2 - Yf1)/(Xf2 - Xf1);
            qLine12 = ((Xf2*Yf1) - (Xf1*Yf2)) / (Xf2-Xf1);
            yStartP = mLine12*xStartP +qLine12;
        end
        
        function yStopP = Line34Stop(this)
            % function Line12Start()
            % Arg: none
            % Return: none
            % Calculate line equations between F-F: 1-2 and 3-4 in the
            % petal system
            
            mLine34 = (Yf4 - Yf3)/(Xf4-Xf3);
            qLine34 = ((Xf4*Yf3) - (Xf3*Yf4)) / (Xf4-Xf3);
            yStopP = mLine34*xStartP +qLine34;
        end
    end
end

