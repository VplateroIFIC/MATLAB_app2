
classdef OWIS_STAGES
    %OWIS_STAGES Summary of this class goes here
    %   Detailed explanation goes here
    
    %     properties (Access = public)
    properties (SetAccess = protected, GetAccess = public)
        IsConnected = false;
        CriticalError = false;
    end
    
        %% Connection Properties  %%
    properties (Constant, Access = public)
        Type = 'OWIS';
        OWIS = 1;
        Interface = 0;      % 0-> ComPort or USB; 1-> NET
        nComPort=int32(3);  % 0(COM0), 1(COM1), ... 255(COM255), default: 1
        Baud = 9600;        % 9600,19200,38400,57600,115200, default: 9600
        Handshake = 0;      % 0(CR), 1(CR+LF), 2(LF), default: 0
        Parity = 0;         % 0-> No parity; 1-> OddParity; 2-> EvenParity
        dataBits = 8;
        stopBits = 0;
        nAxis=int32(1);
        dPosF=30000.0;
        dDistance=10.0;
    end
    
            %% Fixed properties for our OWIS controller  %%
    properties (Constant, Access = public)
        Index = 1;    %// PS-90 INDEX    %search for reference switch and release switch
        xAxis = 1.;
        yAxis = 2.;
        z1Axis = 3.;
        Axis = [1,2,3];
        AxisName = [{'X_axis'},{'Y_axis'},{'Z_axis'}];
        units = 1;
        relative = 0;
        absolute = 1;
        motor_type = [0.,0.,0.];
        limit_switch = [15,15,7];           %Z_Min_SW_STOP fails
        limit_switch_mode  = [15,15,15];
        ref_switch  = [2,2,2];              % 2-> Reference SW is MINDEC
        ref_switch_mode  = [15,15,15];
        sample_time  = [256,256,256];
        KP  = [25,30,30];
        KI  = [25,50,50];
        KD  = [50,50,50];
        DTime  = [0,0,0];
        ILimit  = [5000000,5000000,5000000];
        target_window  = [500,500,500];
        in_pos_mode  = [0,0,0];                         % 0-> target position; 1-> Windows arround target position
        current_level  = [1,0,0];
        pitch  = [5.0,2.0,1.0];
        increments_per_rev  = [50000,20000,10000];
        res_motor = [0.0001,0.0001,0.0001]; %inc/pitch
        gear_reduction_ratio  = [1.0,1.0,1.0];
        lin_res  = [0.0001,0.0001,0.0001];
        ini_target_mode  = [0,0,0];
        acc  = [80,80,80];
        dacc  = [80,80,80];
        jacc  = [200000,200000,200000];
        ref_dacc  = [80,80,80];
        vel  = [0,0,0];
        pos_vel  = [10,10,3];
        ref_vel_slow  = [1,1,1];
        ref_vel_fast  = [-10,-7,-3];
        joy_vel_slow_pos = [1,1,1];
        joy_vel_fast_neg = [-10,-7,-3];
        joy_vel_slow_neg = [-1,-1,-1];
        joy_vel_fast_pos = [10,7,3];
        max_velocity = [15, 15, 5];
        max_velocity_neg = [-15, -15, -5];
%         free_vel  = [29802,29802,47683];
        free_vel_FEx = [1,1,1];
    end
    
    methods
        %% Connect  %%
        
        function this = Connect (this)
            if libisloaded('ps90')
                disp ('PS90 library is already loaded')
            else
                disp ('Loading PS90 library')
                loadlibrary('ps90','ps90.h')
            end
            error = calllib('ps90', 'PS90_Connect', this.Index, this.Interface, this.nComPort, this.Baud, this.Handshake, this.Parity, this.dataBits, this.stopBits);
            this.ConnectError(error);
            if error == 0
                this.IsConnected = 1;
            end
        end
        
        %% Showing errors  %%
        
        function ConnectError(this, error)
            switch error
                case 0
                    fprintf('\t OK\n');
                case 1
                    fprintf('\tfunction error ( invalid parameters )\n');
                case 2
                    fprintf('\tInvalid interface\n');
                case 3
                    fprintf('\tInvalid serial port\n');
                case 4
                    fprintf('\tinvalid interface values \n');
                case 5
                    fprintf('\tno response from control unit \n');
                case 6
                    fprintf('\tbaud rate is changed, reconnect control unit \n');
                case 8
                    fprintf('\tno connection to modbus/tcp ( check settings )');
                otherwise
                    fprintf (' Error: %d\n', error);
            end
            
        end
        
        function ReadErrors (this)
            if libisloaded('ps90')
                disp ('PS90 library is already loaded')
            else
                disp ('Loading PS90 library')
                loadlibrary('ps90','ps90.h')
            end
            
            error = (calllib('ps90','PS90_GetError' , this.Index));
            fprintf('Acumulated errors in the controller: %d \n', error);
            if error ~= 0
                error2 = (calllib('ps90','PS90_GetReadError' , this.Index));
                if error2 ~= 0
                    for i=1:error
                        fprintf ('Reading Error: %d', i );
                        this.showError (error2);
                    end
                end
            end
        end
        
        function showError (this, error)
            switch error
                case 0
                    fprintf('\t OK\n');
                case -1
                    fprintf(' Function error\n');
                case -2
                    fprintf(' Communication error\n');
                case -3
                    fprintf(' Syntax error\n');
                case -4
                    fprintf(' Axis in wrong state\n');
                otherwise
                    fprintf (' Error: %d\n', error);
            end
        end
        
        %% Disconnect%%    
        
        function this = Disconnect(this)
            if this.IsConnected  == 0
                disp ('Already disconnected. Nothing to do.');
                return
            end
            this.MotionStopAll;
            this.MotorDisableAll;
            
            for i=1:3
                State = this.AxisState(i);
                if State ~= 2
                    fprintf ('Wrong state on axis %s : %d\n', this.AxisName{i}, State);
                end
            end
            error = calllib ('ps90', 'PS90_Disconnect', this.Index);
            fprintf (' Disconnecting OWIS driver -> ');
            if error == 0
                this.IsConnected = 0;
            end
            this.showError(error);
        end
        
        
        %% MotionStop %%
        function  MotionStop(this,axis)
            %function  MotionAbort(this,axis)
            % stop motion with full decceleration profile
            % Arguments: object OWIS (this),int Axis%
            % Returns: none %            
            error = (calllib('ps90', 'PS90_Stop', this.Index, axis));
            if error ~= 0
                this.showError(error);
            end
        end
        
        
        %% MotionStopAll %% All Axis %%
        function  MotionStopAll(this)
            %function  MotionStopAll(this)
            % stop motion with full decceleration profile in ALL axis
            % Arguments: object OWIS (this)%
            % Returns: none %
            
            for i=1:3
                 fprintf ('Stopping Motor %s\n',  this.AxisName{i});
                this.MotionStop(this.Axis(i));
            end
        end
        
        %% MotionAbort %%
        function  MotionAbort(this,axis)
            %function  MotionAbort(this,axis)
            % stop motion with reduced decceleration profile
            % Arguments: object OWIS (this),array int Axes%
            % Returns: none %
            
            n=length(axis);
            if n>1
                KillAll(this.GantryObj);
            else
                this.Kill(axis);
            end
        end
        
        %% WaitEndMovement %% Wait until Axis movement finishes %%
        function  WaitEndMovement(this,axis) 
            % function  WaitEndMovement(this,axis)
            % Arguments: object OWIS (this), axis int, target double, velocity double%
            % Returns: none %
            
            while (calllib ('ps90', 'PS90_GetMoveState', this.Index, axis) ~= 0)  
            end
        end
        
        %% MoveTo %% Absolute movements %%
        
        function  MoveTo(this,axis,target,velocity)
            % function  MoveTo(this,axis,target,velocity)
            % function  MoveTo(this,axis,target) Default axis velocity
            % Arguments: object OWIS (this), axis int, target double, velocity double%
            % Returns: none %
            
            if calllib ('ps90', 'PS90_GetMoveState', this.Index, axis) ~= 0
                this.MotionStop(axis);          % If axis is currently moving stop it first
                this.WaitEndMovement(axis);
            end
            
            switch nargin
                case 4
                    
                case 3
                    velocity = this.pos_vel(axis);
                otherwise
                    fprintf ('Invalid number of arguments: (obj, axis, delta)\n');
            end 
            
            %Limiting Axis velocity
            if velocity > this.max_velocity(axis)
                velocity = this.max_velocity(axis);
            elseif velocity < this.max_velocity_neg(axis)
                velocity = this.max_velocity_neg(axis);    
            end
            
            error = calllib('ps90','PS90_SetTargetMode', this.Index, axis, this.absolute); %Absolute movement          
            if error ~= 0
                this.showError(error);
            end
            error = calllib ('ps90', 'PS90_SetTargetEx', this.Index, axis, target);
            if error ~= 0
                this.showError(error);
            end
            Position = this.GetPosition(axis);
            fprintf (' Moving %s from %3.3f to %3.3f mm at %.1f mm/s ->', this.AxisName{axis}, Position, target, velocity);
            error = calllib('ps90', 'PS90_SetPosFEx', this.Index, axis, velocity);
            if error ~= 0
                this.showError(error);
            end
            error = calllib ('ps90', 'PS90_GoTarget', this.Index, axis);
            this.showError(error);
        end
        
        %% Getposition %%
        
        function Position = GetAllPositions(this)
            Position = [999.9, 999.9, 999.9];
            for i=1:3
                Position(i) = GetPosition(this,i);
            end
        end
        
        function  value = GetPosition(this,axis)
            % function  value = GetPosition(this,axis)
            % Arguments: object STAGES (this),axis int ()%
            % Returns: double %
         
            value = calllib ('ps90', 'PS90_GetPositionEx', this.Index, axis);
            error = (calllib('ps90','PS90_GetReadError' , this.Index));
            if error ~= 0
                fprintf('Error reading %s position: %d ', this.AxisName{axis}, error);
                this.showError (error);
                value = 'E';
            else
%                 fprintf('Current %s position: %3.3f\n', this.AxisName{axis}, value);
            end            

            return
        end
        
        %% Initialization %%
        
        function this = INIT(this)
            if libisloaded('ps90')
                disp ('PS90 library is already loaded')
            else
                disp ('Loading PS90 library')
                loadlibrary('ps90','ps90.h')
            end
            if  this.IsConnected == true
                disp('Already Connected');
            else
                this = this.Connect;
            end
            
            for i=1:3
                fprintf('Setting %s -> ', this.AxisName{i});
                error = calllib('ps90', 'PS90_SetMotorType', this.Index, this.Axis(i), this.motor_type(i));
                error = error + calllib('ps90', 'PS90_SetLimitSwitch', this.Index, this.Axis(i),this.limit_switch(i));
                error = error + calllib('ps90', 'PS90_SetLimitSwitchMode', this.Index, this.Axis(i),this.limit_switch_mode(i));
                error = error + calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.Axis(i), this.ref_switch(i));
                error = error + calllib('ps90', 'PS90_SetRefSwitchMode', this.Index, this.Axis(i), this.ref_switch_mode(i));
                error = error + calllib('ps90', 'PS90_SetSampleTime', this.Index, this.Axis(i), this.sample_time(i));
                error = error + calllib('ps90', 'PS90_SetKP', this.Index, this.Axis(i), this.KP(i));
                error = error + calllib('ps90', 'PS90_SetKI', this.Index, this.Axis(i), this.KI(i));
                error = error + calllib('ps90', 'PS90_SetKD', this.Index, this.Axis(i), this.KD(i));
                error = error + calllib('ps90', 'PS90_SetDTime', this.Index, this.Axis(i), this.DTime(i));
                error = error + calllib('ps90', 'PS90_SetILimit', this.Index, this.Axis(i), this.ILimit(i));
                error = error + calllib('ps90', 'PS90_SetTargetWindow', this.Index, this.Axis(i), this.target_window(i));
                error = error + calllib('ps90', 'PS90_SetInPosMode', this.Index, this.Axis(i), this.in_pos_mode(i));
                error = error + calllib('ps90', 'PS90_SetCurrentLevel', this.Index, this.Axis(i), this.current_level(i));
                error = error + calllib('ps90', 'PS90_SetStageAttributes', this.Index, this.Axis(i), this.pitch(1), this.increments_per_rev(1), this.gear_reduction_ratio(i));
                error = error + calllib('ps90', 'PS90_SetCalcResol', this.Index, this.Axis(i), this.res_motor(i));
                error = error + calllib('ps90', 'PS90_SetMsysResol', this.Index, this.Axis(i), this.lin_res(i));
                error = error + calllib('ps90', 'PS90_SetTargetMode', this.Index, this.Axis(i), this.ini_target_mode(i));
                error = error + calllib('ps90', 'PS90_SetAccelEx', this.Index, this.Axis(i), this.acc(i));
                error = error + calllib('ps90', 'PS90_SetDecelEx', this.Index, this.Axis(i), this.dacc(i));
                error = error + calllib('ps90', 'PS90_SetJerk', this.Index, this.Axis(i), this.jacc(i));
                error = error + calllib('ps90', 'PS90_SetRefDecelEx', this.Index, this.Axis(i), this.ref_dacc(i));
                error = error + calllib('ps90', 'PS90_SetVel', this.Index, this.Axis(i), this.vel(i));
                error = error + calllib('ps90', 'PS90_SetPosFEx', this.Index, this.Axis(i), this.pos_vel(i));
                error = error + calllib('ps90', 'PS90_SetSlowRefFEx', this.Index, this.Axis(i), this.ref_vel_slow(i));
                error = error + calllib('ps90', 'PS90_SetFastRefFEx', this.Index, this.Axis(i), this.ref_vel_fast(i));
%                 error = error + calllib('ps90', 'PS90_SetFreeVel', this.Index, this.Axis(i), this.free_vel(i));
                error = error + calllib('ps90', 'PS90_SetFreeFEx', this.Index, this.Axis(i), this.free_vel_FEx(i));
                error = error + calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.Axis(i), this.ref_switch(i));
                if error == 0           %There are no error in all axis
                    fprintf('OK\n');
                    this.MotorEnable(i);
                    this.GetPosition(i);
                else
                    this.showError (error);
                end
            end
            this.MotorEnableAll;
        end
        
        %% MotorEnable %% Enable 1 motor %%
        
        function  MotorEnable(this,axis)
            % function  MotorEnable(this,axis)
            % Arguments: object OWIS (this), axis int%
            % Returns: none %
            error = calllib('ps90','PS90_MotorInit', this.Index, axis);
            if error ~= 0
                fprintf('Error Activating Motor: %s ->', this.AxisName{axis});
                this.showError(error);
            end
        end
        
        %% MotorEnableAll %% Enable all motors
        % function  MotorEnableAll(this)
        % Arguments: object OWIS (this), axis int array%
        % Returns: none %
        
        function MotorEnableAll(this)
            for i=1:3
                this.MotorEnable(this.Axis(i));
            end
        end
        
        %% MotorDisable %% Disable 1 motor
        
        function  MotorDisable(this,axis)
            %function  MotorDisable(this,axis)
            % Arguments: object OWIS (this), axis int,%
            % Returns: none %
            error = calllib ('ps90', 'PS90_MotorOff', this.Index, axis);
            if error ~= 0
                fprintf('Error Desactivating Motor: %s ->', this.AxisName{axis});
                this.showError(error);
            end
        end
        
        %% MotorDisableAll %% Disable all motor
        
        function  MotorDisableAll(this)
            %function  MotorDisableAll(this)
            % Arguments: object OWIS (this) %
            % Returns: none %
            for i=1:3
                this.MotorDisable(this.Axis(i));
            end
        end
        
        %% MoveBy %% Relative movement %%
        
        function  MoveBy(this,axis,delta,velocity)
            % function  MoveBy(this,axis,delta,velocity)
            % function  MoveBy(this,axis,delta)  Default axis velocity
            % Arguments: object OWIS (this), axis int, delta double, velocity double%
            % Returns: none %
            
            if this.CriticalError == true
                fprintf ('\n Critital Error in %s', this.AxisName{axis});
                return;
            end
            
            if calllib ('ps90', 'PS90_GetMoveState', this.Index, axis) ~= 0
                this.MotionStop(axis);        % If axis is currently moving stop it first
                this.WaitEndMovement(axis);
            end
            
            switch nargin
                case 4
                    
                case 3
                    velocity = this.pos_vel(axis);  %If no velocity is especified default value will be used
                otherwise
                    fprintf ('Invalid number of arguments: (obj, axis, delta)\n');
            end
            
            %Limiting Axis velocity
            if velocity > this.max_velocity(axis)
                velocity = this.max_velocity(axis);
            elseif velocity < this.max_velocity_neg(axis)
                velocity = this.max_velocity_neg(axis);    
            end
            
            error = calllib('ps90','PS90_SetTargetMode', this.Index, axis, this.relative); %Relative movement
            
            if error ~= 0
                this.showError(error);
            end
            error = (calllib('ps90', 'PS90_SetPosFEx', this.Index, axis, velocity));
            if error ~= 0
                this.showError(error);
            end
            Position = this.GetPosition(axis);
            fprintf (' Moving %s from %3.3f to %3.3f mm at %.1f mm/s ->', this.AxisName{axis}, Position , Position + delta, velocity);
            error = calllib ('ps90', 'PS90_MoveEx', this.Index, axis, delta, this.units);
            this.showError(error);
        end
        
        
        %% AxisState %%
        
        function  State = AxisState(this,axis)
            %The method retrieves the current axis state.
            %function  AxisState(this,axis)
            % Arguments: object OWIS (this),int Axis%
            % Returns: array with the current state of the motor %
            
            State = calllib ('ps90', 'PS90_GetAxisState', this.Index, axis);
            switch State
                case 0
                    fprintf('Axis %s is not active ->', this.AxisName{axis});
                case 1
                    fprintf('Axis %s not initialized ->', this.AxisName{axis});
                case 2
                    fprintf('Axis %s is switched off ->', this.AxisName{axis});
                case 3
                    fprintf('Axis %s is ready', this.AxisName{axis});
            end
            error = calllib ('ps90', 'PS90_GetReadError', this.Index);
            this.showError(error);
        end
        
        function State = PS90_GetAxisActive (this, axis)
            State = calllib ('ps90', 'PS90_GetAxisActive', this.Index, axis);
            error = calllib ('ps90', 'PS90_GetReadError', this.Index);
            this.showError(error);
        end
        
        %% Home %%
        
        function  Home(this,axis)
            % function  Home(this,axis)
            % Arguments: object ALIO (this), axis int,%
            % Returns: none %
            
            if calllib ('ps90', 'PS90_GetMoveState', this.Index, axis) ~= 0
                this.MotionStop(axis);        % If axis is currently moving stop it first
            end
            
            error = calllib ('ps90', 'PS90_GoRef', this.Index, axis, 1); %Search for reference switch and release it
            if error ~= 0
                this.showError(error);
            end
            
            this.WaitForMotion(axis,-1);
            error = calllib ('ps90', 'PS90_SetPositionEx', this.Index, axis, 0);
            this.showError(error);
        end
        
        %% WaitForMotion %% wait until movement is complete%%
        
        function  WaitForMotion(this,axis,time)
            %function  WaitForMotion(this,axis,time)
            % Arguments: object OWIS (this), axis int,time inn (if -1, wait infinite)%
            % Returns: none %
            
            switch nargin
                case 3
                    
                case 4
                    time = -1;  %If no time is especified it will wait infinite
                otherwise
                    fprintf ('Invalid number of arguments: (obj, axis, delta)\n');
            end
            
            tic
            while toc >= time
                if (calllib ('ps90', 'PS90_GetMoveState', this.Index, axis) == 0)
                    return
                end
            end
            disp ('Movement finished');
        end
        
        %% FreeSwitch
        function FreeSwitch (this, axis)
            %function  FreeSwitch(this,axis)
            % Arguments: object OWIS (this), axis int%
            % Returns: none %
            fprintf ('Release axis %s -> ', this.AxisName{axis});
            this.MotorEnable(axis);
            error = calllib ('ps90', 'PS90_FreeSwitch', this.Index, axis);
            this.showError(error); 
        end
        
        function FreeSwitchALL (this)
            %function  FreeSwitch(this,axis)
            % Arguments: object OWIS (this), axis int%
            % Returns: none %
            
            for i=1:3
                this.FreeSwitch(i)
            end
        end
        
        %% FreeRun %%
        
        function  FreeRunX(this,velocity)
            %function  FreeRunX(this,velocity)
            % Arguments: object OWIS (this),double velocity%
            % Returns: none %
            
            velocity = -velocity;
            axis = this.xAxis;
            
            %Limiting Axis velocity
            if velocity > this.max_velocity(axis)
                velocity = this.max_velocity(axis);
            elseif velocity < this.max_velocity_neg(axis)
                velocity = this.max_velocity_neg(axis);    
            end
            
            if this.CriticalError == true
                fprintf ('\n Critital Error in %s', this.AxisName{axis});
                return;
            end
            fprintf ('Manual movement of %s at %f mm/s', this.AxisName{axis}, velocity);
            error = calllib ('ps90', 'PS90_SetFEx', this.Index, axis, velocity);
            if error == 0
                error = calllib ('ps90', 'PS90_GoVel', this.Index, axis);
            end
            this.showError(error);
        end
        
        function  FreeRunY(this,velocity)
            %function  FreeRunX(this,velocity)
            % Arguments: object OWIS (this),double velocity%
            % Returns: none %
            axis = this.yAxis;
            
            %Limiting Axis velocity
            if velocity > this.max_velocity(axis)
                velocity = this.max_velocity(axis);
            elseif velocity < this.max_velocity_neg(axis)
                velocity = this.max_velocity_neg(axis);    
            end
            
            if this.CriticalError == true
                fprintf ('\n Critital Error in %s', this.AxisName{axis});
                return;
            end
            fprintf ('Manual movement of %s at %f mm/s', this.AxisName{axis}, velocity);
            error = calllib ('ps90', 'PS90_SetFEx', this.Index, axis, velocity);
            if error == 0
                error = calllib ('ps90', 'PS90_GoVel', this.Index, axis);
            end
            this.showError(error);
        end
        
        function  FreeRunZ1(this,velocity)
            %function  FreeRunX(this,velocity)
            % Arguments: object OWIS (this),double velocity%
            % Returns: none %
            axis = this.z1Axis;
            
            %Limiting Axis velocity
            if velocity > this.max_velocity(axis)
                velocity = this.max_velocity(axis);
            elseif velocity < this.max_velocity_neg(axis)
                velocity = this.max_velocity_neg(axis);    
            end
%             velocity = velocity / 10;      %Reducing Z axis velocity

            if this.CriticalError == true
                fprintf ('\n Critital Error in %s', this.AxisName{axis});
                return;
            end
            fprintf ('Manual movement of %s at %f mm/s', this.AxisName{axis}, velocity);
            error = calllib ('ps90', 'PS90_SetFEx', this.Index, axis, velocity);
            if error == 0
                error = calllib ('ps90', 'PS90_GoVel', this.Index, axis);
            end
            this.showError(error);
        end
    end
end

