
classdef OWIS_STAGES
    %OWIS_STAGES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        %         bool properties
        IsConnected = false;
        X_stage_init = false;
        Y_stage_init = false;
        Z_stage_init = false;
        X_stage_on = false;
        Y_stage_on = false;
        Z_stage_on = false;
        %         long properties
        move_state_X=0;
        move_state_Y=0;
        move_state_Z=0;
    end
    %         Connection properties
    
    properties (Constant, Access = public)
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
    
    %         General properties for our OWIS controller
    
    properties (Constant, Access = public)
        Index = 1;    %// PS-90 INDEX    %search for reference switch and release switch
        xAxis = 1.;
        yAxis = 2.;
        zAxis = 3.;
        Axis = [1,2,3];
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
        acc  = [20,20,10];
        dacc  = [20,20,10];
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
        free_vel  = [29802,29802,47683];
        
        minstp=1;
        mindec=2;
        min=3;
        maxdec=4;
        maxstp=8;
        max=12;
        %         ref_switch_x=2;
        %         ref_switch_y=2;
        %         ref_switch_z=2;
        
        goRefMode = [0,1,2,3,4,5,6,7];
        
        %       const char* result_window = "Result window";
    end
    
    properties (Access = public)
        Xpos = 0;
        Ypos = 0;
        Zpos = 0;
        AxisName = ['X_axis';'Y_axis';'Z_axis'];
        Position = [ 0, 0, 0];
        temp_vel = [ 0, 0, 0];
        %         AxisState = [ ['Off']; ['Off']; ['Off'] ];  % On, Off, Moving
        %         AxisState = [ 0, 0, 0]
        PosMode = [ 0, 0, 0];               % 0-> Trapezoidal profile;  1-> S-curve
        TargetMode = [ 0, 0, 0];            % 0-> Relative positioning;  1-> Absolute positioning
        units = 1;                          % 0-> step increments;  1-> selected units (mm)
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
            if  error == 0
                disp('Connected');
                this.IsConnected = true;
            else
                this.ConnectError(error)
            end
        end
        
        %% Showing errors  %%
        
        function ConnectError(error)
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
            disp ('Acumulated errors in the controller');
            disp(error);
            
            error2 = (calllib('ps90','PS90_GetReadError' , this.Index));
            if error2 ~= 0
                disp ('Reading Error:' );
            end
            this.showError (error2);
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
            if this.X_stage_on ~= 0
                error = calllib ('ps90', 'PS90_MotorOff', this.Index, this.xAxis);
                if error == 0
                    this.X_stage_on=false;
                    disp ('X motor disconnected');
                else
                    disp ('Error in PS90_MotorOff X Axis ');
                    this.showError (error);
                end
            end
            if this.X_stage_on ~= 0
                error = calllib ('ps90', 'PS90_MotorOff', this.Index, this.yAxis);
                if error == 0
                    this.Y_stage_on=false;
                    disp ('X motor disconnected');
                else
                    disp ('Error in PS90_MotorOff Y Axis ');
                    this.showError (error);
                end
            end
            if this.Z_stage_on ~= 0
                error = calllib ('ps90', 'PS90_MotorOff', this.Index, this.zAxis);
                if error == 0
                    this.Z_stage_on=false;
                    disp ('X motor disconnected');
                else
                    disp ('Error in PS90_MotorOff Z Axis ');
                    this.showError (error);
                end
            end
            error = calllib ('ps90', 'PS90_Disconnect', this.Index);
            this.IsConnected  = 0;
            this.showError (error);
        end
        
        
        %% MotionStop %%
        function  MotionStop(this,axis)
            %function  MotionAbort(this,axis)
            % stop motion with full decceleration profile
            % Arguments: object OWIS (this),int Axis%
            % Returns: none %
            
            fprintf(' Stopping %s movement -> ', this.AxisName(axis));
            error = (calllib('ps90', 'PS90_Stop', this.Index, axis));
            this.showError(error);
        end
        
        
        %% MotionStopAll %% All Axis %%
        function  MotionStopAll(this)
            %function  MotionStopAll(this)
            % stop motion with full decceleration profile in ALL axis
            % Arguments: object OWIS (this)%
            % Returns: none %
            
            for i=1:3
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
        
        %% MoveTo %% Absolute movements %%
        
        function  MoveTo(this,axis,target,velocity)
            % function  MoveTo(this,axis,target,velocity)
            % Arguments: object OWIS (this), axis int, target double, velocity double%
            % Returns: none %
            
            if calllib ('ps90', 'PS90_GetMoveState', this.Index, axis) ~= 0
                this.MotionStop(axis);          % If axis is currently moving stop it first
            end
            
            this.TargetMode(axis) = this.absolute;
            error = (calllib('ps90', 'PS90_SetPosFEx', this.Index, this.xAxis, velocity) ~= 0 );
            if error ~= 0
                this.showError(error);
            end
            error = calllib('ps90','PS90_SetTargetMode', this.Index, axis, this.TargetMode(axis)); %Absolute movement
            if error ~= 0
                this.showError(error);
            end           
            this.Position(axis) = this.GetPosition(axis);
            fprintf (' Moving %s from %3.3f to %3.3f mm ', this.AxisName(axis), this.Position(axis) , target);
            error = calllib ('ps90', 'PS90_SetTargetEx', this.Index, axis, target);
            if error ~= 0
                this.showError(error);
            end 
            error = calllib ('ps90', 'PS90_GoTarget', this.Index, axis);
            this.showError(error);
        end
        %% Getposition %%
        
        function  value = GetPosition(this,axis)
            % function  value = GetPosition(this,axis)
            % Arguments: object STAGES (this),axis int ()%
            % Returns: double %
            value = calllib ('ps90', 'PS90_GetPositionEx', this.Index, axis);
            error = (calllib('ps90','PS90_GetReadError' , this.Index));
            if error ~= 0
                fprintf('Error reading %s position: %d\n', this.AxisName(axis), error);
                showError (error);
                return
            else
%                 fprintf('Current %s position: %3.3f\n', this.AxisName(axis), value);
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
                fprintf('Setting %s --> ', this.AxisName(i));
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
                error = error + calllib('ps90', 'PS90_SetFreeVel', this.Index, this.Axis(i), this.free_vel(i));
                error = error + calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.Axis(i), this.ref_switch(i));
                if error == 0           %There are no error in all axis
                    fprintf('OK\n');
                    this.Position(i) = this.GetPosition(i);
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
                fprintf('Error Activating Motor: %s \n', this.AxisName(i));
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
                fprintf('Error Desactivating Motor: %s \n', this.AxisName(i));
                this.showError(error);
            end
        end
        
        %% MotorDisableAll %% Disable all motor
        
        function  MotorDisableAll(this)
            %function  MotorDisableAll(this)
            % Arguments: object OWIS (this), axis int,%
            % Returns: none %
            for i=1:3
                this.MotorDisable(this,this.Axis(i));
            end
        end
        
        %% MoveBy %% Relative movement %%
        
        function  MoveBy(this,axis,delta,velocity)
            % function  MoveBy(this,axis,delta,velocity)
            % Arguments: object OWIS (this), axis int, delta double, velocity double%
            % Returns: none %
            
            if calllib ('ps90', 'PS90_GetMoveState', this.Index, axis) ~= 0
                this.MotionStop(axis);        % If axis is currently moving stop it first
            end
             
            this.TargetMode(axis) = this.relative;
            error = (calllib('ps90', 'PS90_SetPosFEx', this.Index, this.xAxis, velocity) ~= 0 );
            if error ~= 0
                this.showError(error);
            end
            error = calllib('ps90','PS90_SetTargetMode', this.Index, axis, this.TargetMode(axis)); %Relative movement
            if error ~= 0
                this.showError(error);
            end
            this.Position(axis) = this.GetPosition(axis);
            fprintf (' Moving %s from %3.3f to %3.3f mm ', this.AxisName(axis), this.Position(axis) , this.Position(axis) + delta);
            error = calllib ('ps90', 'PS90_MoveEx', this.Index, axis, delta, this.units);
            this.showError(error);
            
            
            %         fprintf('Current %s position: %3.3f\n', this.AxisName, this.Position);
            
            %             if this.AxisState(axis) == 0
            %                 fprintf(' %s motor not activated\n', this.AxisName(axis));
            %                 error = calllib('ps90','PS90_MotorInit', this.Index, axis);
            %                 if error ~= 0
            %                     fprintf('Error activating %s motor: %d\n', this.AxisName(axis), error);
            %                 else
            %                     fprintf(' %s motor activated succesfully\n', this.AxisName(axis));
            %                 end
            %                 this.Position(axis) = calllib ('ps90', 'PS90_GetPositionEx', this.Index, axis);
            %                 fprintf('Current %s position: %3.3f\n', this.AxisName(axis), this.Position(axis));
            %
            %                 error = calllib('ps90','PS90_SetPosMode', this.Index, axis, this.PosMode(axis));       %Trapezoidal movement
            %                 if error ~= 0
            %                     fprintf('Error in %s : %d\n', this.AxisName, error);
            %                 end
            %                 error = calllib('ps90','PS90_SetTargetMode', this.Index, axis, this.TargetMode(axis)); %Relative movement
            %                 if error ~= 0
            %                     fprintf('Error in %s : %d\n', this.AxisName, error);
            %                 end
            %                 error = calllib ('ps90', 'PS90_MoveEx', this.Index, axis, delta, this.units);
            %             end
        end
        
        function  State = AxisState(this,axis)
            %The method retrieves the current axis state.
            %function  AxisState(this,axis)
            % Arguments: object ALIO (this),int Axis%
            % Returns: array with the current state of the motor %
            
            State = calllib ('ps90', 'PS90_GetAxisState', this.Index, axis);
            switch State
                case 0
                    fprintf('Axis %s is not active', this.AxisName(axis));
                case 1
                    fprintf('Axis %s not initialized', this.AxisName(axis));
                case 2
                    fprintf('Axis %s is switched off', this.AxisName(axis));
                case 3
                    fprintf('Axis %s is ready', this.AxisName(axis));
            end
            error = calllib ('ps90', 'PS90_GetReadError', this.Index);
            this.showError(error);
        end
        
        function State = PS90_GetAxisActive (this, axis)
            State = calllib ('ps90', 'PS90_GetAxisActive', this.Index, axis);
            error = calllib ('ps90', 'PS90_GetReadError', this.Index);
            this.showError(error);
        end
    end
end

