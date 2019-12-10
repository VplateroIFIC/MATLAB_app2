classdef JOYSTICK
    %JOYSTICK Control over joystick device
    %   This class provide control over joystick device connected to Gantry
    
    properties (Access=public)
  
    end
    properties (Access=protected)
        JoystickIsReady=0;
        setup;
        t;
        threshold=0.1;
        maxVel=15;
        minVel=0.1;
        CurrentVel=5;
        xAxis = -1;
        yAxis = -1;
        z1Axis = -1;
        z2Axis = -1;
        uAxis = -1;
%         OWIS = 0;
%         Gantry = 0;
    end
    
    methods
        function this = JOYSTICK(setup_obj)
            %JOYSTICK Construct an instance of this class
            %   receiving gantry object and creating joystick instance
            this.setup=setup_obj;
            if (this.setup.IsConnected==1)
                
            else
                disp('joystick can not be used: gantry is not connected')
            end
            
            if isprop (this.setup.xAxis)
                this.xAxis = gantry.xAxis;
            end
            if isprop (this.setup.yAxis)
                this.yAxis = gantry.yAxis;
            end
            if isprop (this.setup.z1Axis)
                this.z1Axis = gantry.z1Axis;
            end
            if isprop (this.setup.z2Axis)
                this.z2Axis = gantry.z2Axis;
            end
            if isprop (this.setup.z2Axis)
                this.z2Axis = gantry.z2Axis;
            end
            if isprop (this.setup.uAxis)
                this.uAxis = gantry.uAxis;
            end
        end
        
        function this = Connect(this)
            %Connect Connecting joystick
            % starting timer to manage the joystick input
        this.setup.MotorEnableAll;     
        this.t = timer('Name','JoyTimer','ExecutionMode','fixedSpacing','StartDelay', 0,'Period',0.01);
        this.t.UserData = struct('FlagAxes',zeros(5,1),'FlagBut',zeros(16,1),'maxVelocity',this.maxVel,'minVelocity',this.minVel,'Velocity',this.CurrentVel);
        this.t.BusyMode='queue';
        
        this.t.TimerFcn = {@this.joyControl};
        this.t.ErrorFcn = {@this.stopAll};
        this.t.StopFcn = {@this.stopAll};
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
             vel=-tobj.UserData.Velocity*pos(1);
             fprintf ('X_axis is moving with velocity %f\n',vel);
             this.setup.FreeRunX(vel);
             tobj.UserData.FlagAxes(1)=1;
            end
            
            if (abs(pos(2))> this.threshold)
             vel=-tobj.UserData.Velocity*pos(2);
             fprintf ('Y_axis is moving with velocity %f\n',vel);
             this.setup.FreeRunY(vel);
             tobj.UserData.FlagAxes(2)=1;
            end
            
            if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==0)
            vel=-tobj.UserData.Velocity*pos(3);
            fprintf ('Z1_axis is moving with velocity %f\n',vel);
            this.setup.FreeRunZ1(vel);
            tobj.UserData.FlagAxes(3)=1;
            end            
            
            
            if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==1)
                vel=-tobj.UserData.Velocity*pos(3);
                fprintf ('Z2_axis is moving with velocity %f\n',vel);
                if ismethod (setup, 'FreeRunZ2')
                    this.setup.FreeRunZ2(vel);
                    tobj.UserData.FlagAxes(3)=1;
                else
                    disp ('No Z2 axis available');
                end
            end
            
            
            if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==1)
                vel=-tobj.UserData.Velocity*pos(3);
                fprintf ('Z2_axis is moving with velocity %f\n',vel);
                if ismethod (setup, 'FreeRunU')
                    this.setup.FreeRunU(vel);
                    tobj.UserData.FlagAxes(3)=1;
                else
                    disp ('No U axis available');
                end
            end
            
            % Controling of the axes: stopping %

            if (abs(pos(1))<this.threshold) && (tobj.UserData.FlagAxes(1)==1)
            this.setup.MotionStop(this.xAxis);
            tobj.UserData.FlagAxes(1)=0;
            end
            
            if (abs(pos(2))<this.threshold) && (tobj.UserData.FlagAxes(2)==1)
            this.setup.MotionStop(this.yAxis);
            tobj.UserData.FlagAxes(2)=0;
            end
            
            if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==0)
                this.setup.MotionStop(this.z1Axis);
                tobj.UserData.FlagAxes(3)=0;
            end
            
            if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==1)
                if ismethod (setup, 'FreeRunZ2')
                    this.setup.MotionStop(this.z2Axis);
                    tobj.UserData.FlagAxes(3)=0;
                else
                    disp ('No Z2 axis available');
                end
            end
            
            if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==1)
                if ismethod (setup, 'FreeRunZ2')
                    this.setup.MotionStop(this.uAxis);
                    tobj.UserData.FlagAxes(3)=0;
                else
                    disp ('No U axis available');
                end
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
             tobj.UserData.Velocity=max(tobj.UserData.minVelocity,tobj.UserData.Velocity-0.05*tobj.UserData.maxVelocity);
             tobj.UserData.FlagBut(1)=1; 
             fprintf('Velocity Value: %2.4f\n',tobj.UserData.Velocity);
             end    
             if (but(1)==0) && (tobj.UserData.FlagBut(1)==1)
             tobj.UserData.FlagBut(1)=0;
             end
             
             % Button 2: Increase Velocity %
             
              if (but(2)==1) && (tobj.UserData.FlagBut(2)==0)
             tobj.UserData.Velocity=min(tobj.UserData.maxVelocity,tobj.UserData.Velocity+0.05*tobj.UserData.maxVelocity);
             tobj.UserData.FlagBut(2)=1;    
             fprintf('Velocity Value: %2.4f\n',tobj.UserData.Velocity);
             end    
             if (but(2)==0) && (tobj.UserData.FlagBut(2)==1)
             tobj.UserData.FlagBut(2)=0;
             end
        end
        
        
        function stopAll(this,tobj,event)
            % safe stop in case timer stopped %
            
            if ismethod(setup,'MotionStopAll')
                setup.MotionStopAll;
            end
            
            if this.xAxis >= 0
                this.setup.MotionStop(this.xAxis);
            end
            if this.yAxis >= 0
                this.setup.MotionStop(this.yAxis);
            end
            if this.z1Axis >= 0
                this.setup.MotionStop(this.z1Axis);
            end
            if this.z2Axis >= 0
                this.setup.MotionStop(this.z2Axis);
            end
            if this.uAxis >= 0
                this.setup.MotionStop(this.uAxis);
            end
        end

end
end
