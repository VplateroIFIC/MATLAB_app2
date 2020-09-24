classdef JOYSTICK_OWIS
    %JOYSTICK Control over joystick device
    %   This class provide control over joystick device connected to setup
    
    properties (SetAccess = protected, GetAccess = public)
        JoystickIsReady = 0;
    end
    properties (Access=protected)
        setup;
        t;
        threshold=0.1;
        maxVel=15;
        maxVel2 = [10, 10, 10, 10, 10, 10]
        minVel=0.1;
        CurrentVel=5;
        X = -1;
        Y = -1;
        Z1 = -1;
        Z2 = -1;
        U = -1;
        %         OWIS = 0;
        %         Gantry = 0;
    end
    
    methods
        function this = JOYSTICK_OWIS(setup_obj)
            %JOYSTICK Construct an instance of this class
            %   receiving setup object and creating joystick instance
            this.setup=setup_obj;
            if (this.setup.IsConnected==1)
                
            else
                disp('joystick can not be used: setup is not connected')
            end
            
            if isprop (this.setup,'X')
                this.X = this.setup.X;
            end
            if isprop (this.setup,'Y')
                this.Y = this.setup.Y;
            end
            if isprop (this.setup,'Z1')
                this.Z1 = this.setup.Z1;
            end
            if isprop (this.setup,'Z2')
                this.Z2 = this.setup.Z2;
            end
%             if isprop (this.setup,'Z2')
%                 this.Z2 = this.setup.Z2;
%             end
            if isprop (this.setup,'U')
                this.U = this.setup.U;
            end
            if isprop (this.setup, 'joy_vel_slow_pos')
                
            end
            if isprop (this.setup, 'joy_vel_fast_pos')
                this.maxVel2 = this.setup.joy_vel_fast_pos;
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
            this.JoystickIsReady = 0;
            stop(this.t);
        end
        
        function joyControl(this,tobj,event)
            % calling the joystick inpput %
            
            [pos, but] = mat_joy(0);
            
            % Controling of the axes: moving %
            
            if (abs(pos(1))> this.threshold)
                vel=-tobj.UserData.Velocity*pos(1);
                this.setup.FreeRunX(vel);
                tobj.UserData.FlagAxes(1)=1;
            end
            
            if (abs(pos(2))> this.threshold)
                vel=-tobj.UserData.Velocity*pos(2);
                this.setup.FreeRunY(vel);
                tobj.UserData.FlagAxes(2)=1;
            end
            
            if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==0)
                vel=-tobj.UserData.Velocity*pos(3);
%                 vel = vel/3;
                if ismethod (this.setup, 'FreeRunZ1')
                    this.setup.FreeRunZ1(vel);
                    tobj.UserData.FlagAxes(3)=1;
                else
                    disp ('No Z2 axis available');
                end
            end
            
            
            if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==1)
                vel=-tobj.UserData.Velocity*pos(3);
                if ismethod (this.setup, 'FreeRunZ2')
                    this.setup.FreeRunZ2(vel);
                    tobj.UserData.FlagAxes(3)=1;
                else
                    disp ('No Z2 axis available');
                end
            end
            
            
            if (abs(pos(3))> this.threshold) && (tobj.UserData.FlagAxes(5)==1)
                vel=-tobj.UserData.Velocity*pos(3);
                if ismethod (this.setup, 'FreeRunU')
                    this.setup.FreeRunU(vel);
                    tobj.UserData.FlagAxes(3)=1;
                else
                    disp ('No U axis available');
                end
            end
            
            % Controling of the axes: stopping %
            
            if (abs(pos(1))<this.threshold) && (tobj.UserData.FlagAxes(1)==1)
                this.setup.MotionStop(this.X);
                tobj.UserData.FlagAxes(1)=0;
            end
            
            if (abs(pos(2))<this.threshold) && (tobj.UserData.FlagAxes(2)==1)
                this.setup.MotionStop(this.Y);
                tobj.UserData.FlagAxes(2)=0;
            end
            
            if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==0)
                this.setup.MotionStop(this.Z1);
                tobj.UserData.FlagAxes(3)=0;
            end
            
            if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==0) && (tobj.UserData.FlagAxes(4)==1)
                if ismethod (this.setup, 'FreeRunZ2')
                    this.setup.MotionStop(this.Z2);
                    tobj.UserData.FlagAxes(3)=0;
                else
                    disp ('No Z2 axis available');
                end
            end
            
            if (abs(pos(3))<this.threshold) && (tobj.UserData.FlagAxes(3)==1) && (tobj.UserData.FlagAxes(5)==1)
                if ismethod (this.setup, 'FreeRunZ2')
                    this.setup.MotionStop(this.U);
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
            
            if ismethod(this.setup,'MotionStopAll')
                this.setup.MotionStopAll;
            end
            
            if this.X >= 0
                this.setup.MotionStop(this.X);
            end
            if this.Y >= 0
                this.setup.MotionStop(this.Y);
            end
            if this.Z1 >= 0
                this.setup.MotionStop(this.Z1);
            end
            if this.Z2 >= 0
                this.setup.MotionStop(this.Z2);
            end
            if this.U >= 0
                this.setup.MotionStop(this.U);
            end
        end
        
    end
end
