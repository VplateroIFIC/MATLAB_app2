classdef JOYSTICK
    %JOYSTICK Control over joystick device
    %   This class provide control over joystick device connected to Gantry
    
    properties (Access=public)
  
    end
    properties (Access=protected)
        JoystickIsReady=0;
        gantry;
        t;
        threshold=0.01;
        maxVel=15;
        minVel=0.1;
        CurrentVel=5;
        xAxis=0;
        yAxis=1;
        z1Axis=4;
        z2Axis=5;
        uAxis=6;
        FlagX=0;
        FlagY=0;
        FlagZ1=0;
        FlagZ2=0;
        FlagU=0;
        
        FlagBut1=0;
        FlagBut2=0;
        FlagBut3=0;
        FlagBut4=0;
        FlagBut5=0;
        FlagBut6=0;
        FlagBut7=0;
        FlagBut8=0;
        FlagBut9=0;
        FlagBut10=0;
        FlagBut11=0;
        FlagBut12=0;
        FlagBut13=0;
        FlagBut14=0;
        FlagBut15=0;
        FlagBut16=0;
    end
    
    methods
        function this = JOYSTICK(gantry_obj)
            %JOYSTICK Construct an instance of this class
            %   receiving gantry object and creating joystick instance
        this.gantry=gantry_obj;
         if (this.gantry.IsConnected==1)
   
        else
            disp('joystick can not be used: gantry is not connected')
        end
        end
        
        function this = Connect(this)
            %Connect Connecting joystick
            % starting timer to manage the joystick input

        this.gantry.MotorEnableAll;     
        this.t = timer('Name','JoyTimer','ExecutionMode','fixedSpacing','StartDelay', 0);
%         t.UserData = struct('iteration', 0, 'timerThresh', this.threshold,'timerMaxVel',this.maxVel,'timerMinVel',this.minVel,'timerCurrentVel',this.CurrentVel);
        this.t.period=0.001;
        this.t.BusyMode='queue';
        this.t.TimerFcn = {@this.joyControl};
        start(this.t);
        disp('Joystick is ready to be used')
        this.JoystickIsReady=1;
        end
        
        function this = Disconnect(this)
            %Disconnect Disconnect joystick
            % Stopping timer
        stop(this.t);
        end
        
        function joyControl(this,tobj,event)
            % calling the joystick inpput %
           [pos, but] = mat_joy(0); 
%             Npos=length(pos);
%             Nbut=length(but);
           % Controling of the axes: moving %
            if (abs(pos(1))> this.threshold)
%             vel=this.CurrentVel*pos(1);
%             gantry.FreeRunX(this,vel);
%             this.FlagX=1;
            this.RunX(this,pos(1));
             fprintf('X axis is moving %0.4f\n',pos(1));
            end
            
            if (abs(pos(2))> this.threshold)
%             vel=this.timerCurrentVel*pos(2);
%             gantry.FreeRunY(this,vel);
%             this.FlagY=1;
              fprintf('Y axis is moving %0.4f\n',pos(2));
            end
            
            if (abs(pos(3))> this.threshold)
%             vel=this.timerCurrentVel*pos(3);
%             gantry.FreeRunZ1(this,vel);
%            this.FlagZ1=1;
             fprintf('Z axis is moving %0.4f\n',pos(3));
            end
            
            % Controling of the axes: stopping %
            
            if (abs(pos(1))<this.threshold) && (this.FlagX==1)
%             gantry.MotionStop(this,this.xAxis);
%             this.FlagX=0;
            end
            
            if (abs(pos(2))<this.threshold) && (this.FlagY==1)
%             gantry.MotionStop(this,this.yAxis);
%             this.FlagY=0;
            end
            
            if (abs(pos(3))<this.threshold) && (this.FlagZ1==1)
%             gantry.MotionStop(this,this.z1Axis);
%             this.FlagZ1=0;
            end
        end
        
         function RunX(this,pos) 
            vel=this.CurrentVel*pos(1);
            this.gantry.FreeRunX(this,vel);
    end
end

