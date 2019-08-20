classdef JOYSTICK
    %JOYSTICK Control over joystick device
    %   This class provide control over joystick device connected to Gantry
    
    properties (Access=public)
        
%         FlagX=0;
%         FlagY=0;
%         FlagZ1=0;
%         FlagZ2=0;
%         FlagU=0;
%         
%         FlagBut1=0;
%         FlagBut2=0;
%         FlagBut3=0;
%         FlagBut4=0;
%         FlagBut5=0;
%         FlagBut6=0;
%         FlagBut7=0;
%         FlagBut8=0;
%         FlagBut9=0;
%         FlagBut10=0;
%         FlagBut11=0;
%         FlagBut12=0;
%         FlagBut13=0;
%         FlagBut14=0;
%         FlagBut15=0;
%         FlagBut16=0;
    end
    properties (Access=private)
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
    end
    
    methods
        function this = JOYSTICK(gantry_obj)
            %JOYSTICK Construct an instance of this class
            %   receiving gantry object and creating joystick instance
        if (gantry.IsConnected==1)
        disp('Joystick is ready to be used')
        this.gantry=gantry_obj;
        else
            disp('joystick can not be used: gantry is not connected')
        end
        end
        
        function this = Connect(this)
            %Connect Connecting joystick
            % starting timer to manage the joystick input
        
        timerFlagX=0;
        timerFlagY=0;
        timerFlagZ1=0;
        timerFlagZ2=0;
        timerFlagU=0;
        timerFlagBut1=0;
        timerFlagBut2=0;
        timerFlagBut3=0;
        timerFlagBut4=0;
        timerFlagBut5=0;
        timerFlagBut6=0;
        timerFlagBut7=0;
        timerFlagBut8=0;
        timerFlagBut9=0;
        timerFlagBut10=0;
        timerFlagBut11=0;
        timerFlagBut12=0;
        timerFlagBut13=0;
        timerFlagBut14=0;
        timerFlagBut15=0;
        timerFlagBut16=0;
  
        this.t = timer('Name','JoyTimer','ExecutionMode','fixedSpacing','StartDelay', 0);
        iteration=0;
        timerThresh=this.threshold;
        timerMaxVel=this.maxVel;
        timerMinVel=this.minVel;
        timerCurrentVel=this.CurrentVel;
      
        this.t.UserData = iteration;
        this.t.UserData = timerThresh;
        this.t.UserData = timerMaxVel;
        this.t.UserData = timerMinVel;
        this.t.UserData = timerCurrentVel;
        this.t.UserData = timerFlagX;
        this.t.UserData = timerFlagY;
        this.t.UserData = timerFlagZ1;
        this.t.UserData = timerFlagZ2;
        this.t.UserData = timerFlagU;
        this.t.period=0.001;
        this.t.BusyMode='queue';
        this.t.TimerFcn = {@this.joyControl,this,this.gantry};
        start(this.t);
        end
        
        function this = Disconnect(this)
            %Disconnect Disconnect joystick
            % Stopping timer
        stop(this.t);
        end
        
        function joyControl(tobj,~,this,gantry)
   
            % calling the joystick inpput %
           [pos, but] = mat_joy(0); 
%             Npos=length(pos);
%             Nbut=length(but);

           % Controling of the axes: moving %

            if (abs(pos(1))>tobj.timerThresh) && (tobj.timerFlagX==0)
            vel=tobj.timerCurrentVel*pos(1);
            gantry.FreeRunX(this,vel);
            tobj.timerFlagX=1;
            end
            
            if (abs(pos(2))>tobj.timerThresh) && (tobj.timerFlagY==0)
            vel=tobj.timerCurrentVel*pos(2);
            gantry.FreeRunY(this,vel);
            tobj.timerFlagY=1;
            end
            
            if (abs(pos(3))>tobj.timerThresh) && (tobj.timerFlagZ1==0)
            vel=tobj.timerCurrentVel*pos(3);
            gantry.FreeRunZ1(this,vel);
            tobj.timerFlagZ1=1;
            end
            
            % Controling of the axes: stopping %
            
            if (abs(pos(1))<tobj.timerThresh) && (tobj.timerFlagX==1)
            gantry.MotionStop(this,this.xAxis);
            tobj.timerFlagX=0;
            end
            
            if (abs(pos(2))<tobj.timerThresh) && (tobj.timerFlagY==1)
            gantry.MotionStop(this,this.yAxis);
            tobj.timerFlagY=0;
            end
            
            if (abs(pos(3))<tobj.timerThresh) && (tobj.timerFlagZ1==1)
            gantry.MotionStop(this,this.z1Axis);
            tobj.timerFlagZ1=0;
            end
           tobj.iteration=tobj.iteration+1; 
        end

    end
end

