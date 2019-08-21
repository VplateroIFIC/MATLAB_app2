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
        this.t.UserData = struct('FlagAxes',zeros(5,1),'FlagBut',zeros(16,1),'MaxVelocity',this.maxVel,'minVelocity',this.minVel,'Velocity',this.CurrentVel);
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
           
           % Controling of the axes: moving %
           
            if (abs(pos(1))> this.threshold)
             vel=tobj.UserData.Velocity*pos(1);
             this.gantry.FreeRunX(this,vel);
             tobj.UserData.FlagAxes(1)=1;
%              fprintf('X axis is moving %0.4f\n',pos(1));
            end
            
            if (abs(pos(2))> this.threshold)
             vel=tobj.UserData.Velocity*pos(2);
             this.gantry.FreeRunY(this,vel);
             tobj.UserData.FlagAxes(2)=1;
%               fprintf('Y axis is moving %0.4f\n',pos(2));
            end
            
            if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==0)
            vel=tobj.UserData.Velocity*pos(3);
            this.gantry.FreeRunZ1(this,vel);
            tobj.UserData.FlagAxes(3)=1;
%              fprintf('Z axis is moving %0.4f\n',pos(3));
            end
            
            if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==1)
            vel=tobj.UserData.Velocity*pos(3);
            this.gantry.FreeRunZ2(this,vel);
            tobj.UserData.FlagAxes(3)=1;
%              fprintf('Z axis is moving %0.4f\n',pos(3));
            end
            
             if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==1)
            vel=tobj.UserData.Velocity*pos(3);
            this.gantry.FreeRunU(this,vel);
            tobj.UserData.FlagAxes(3)=1;
%              fprintf('Z axis is moving %0.4f\n',pos(3));
            end
            
            % Controling of the axes: stopping %

            if (abs(pos(1))<this.threshold) && (tobj.UserData.FlagAxes(1)==1)
            this.gantry.MotionStop(this,this.xAxis);
            tobj.UserData.FlagAxes(1)=0;
            end
            
            if (abs(pos(2))<this.threshold) && (tobj.UserData.FlagAxes(2)==1)
            this.gantry.MotionStop(this,this.yAxis);
            tobj.UserData.FlagAxes(2)=0;
            end
            
            if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==0)
            this.gantry.MotionStop(this,this.z1Axis);
            tobj.UserData.FlagAxes(3)=0;
            end
            
             if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==1)
            this.gantry.MotionStop(this,this.z2Axis);
            tobj.UserData.FlagAxes(3)=0;
             end
            
             if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==1)
            this.gantry.MotionStop(this,this.uAxis);
            tobj.UserData.FlagAxes(3)=0;
             end
            
            % Checking the buttons %

            % Button 11: change between ZZ axis %
            
             if (but(11)==1) && (tobj.UserData.FlagBut(11)==0)
             switch tobj.UserData.FlagAxes(4)
                 case 0
                     tobj.UserData.FlagAxes(4)=1;
                 case 1
                     tobj.UserData.FlagAxes(4)=0;
             end
             tobj.UserData.FlagBut(11)=1;
             end
             
             if (but(11)==0) && (tobj.UserData.FlagBut(11)==1)
             tobj.UserData.FlagBut(11)=0;
             end
             
             % Button 12: change Z axis --> rotative platform %
             
             if (but(12)==1) && (tobj.UserData.FlagBut(12)==0)
             switch tobj.UserData.FlagAxes(5)
                 case 0
                     tobj.UserData.FlagAxes(5)=1;
                 case 1
                     tobj.UserData.FlagAxes(5)=0;
             end
             tobj.UserData.FlagBut(12)=1;
             end
             if (but(12)==0) && (tobj.UserData.FlagBut(12)==1)
             tobj.UserData.FlagBut(12)=0;
             end
             
              % Button 1: decrease velocity %
              
             if (but(1)==1) && (tobj.UserData.FlagBut(1)==0)
             tobj.UserData.Velocity=max(tobj.UserData.minVelocity,tobj.UserData.Velocity-0.05*tobj.UserData.MaxVelocity);
             tobj.UserData.FlagBut(1)=1; 
             fprintf('Velocity Value: %2.4f\n',tobj.UserData.Velocity);
             end    
             if (but(1)==0) && (tobj.UserData.FlagBut(1)==1)
             tobj.UserData.FlagBut(1)=0;
             end
             
             % Button 2: Increase Velocity %
             
              if (but(2)==1) && (tobj.UserData.FlagBut(2)==0)
             tobj.UserData.Velocity=min(tobj.UserData.maxVelocity,tobj.UserData.Velocity+0.5*tobj.UserData.MaxVelocity);
             tobj.UserData.FlagBut(2)=1;    
             fprintf('Velocity Value: %2.4f\n',tobj.UserData.Velocity);
             end    
             if (but(2)==0) && (tobj.UserData.FlagBut(2)==1)
             tobj.UserData.FlagBut(2)=0;
             end
        end

end

