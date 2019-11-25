
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
    properties (Constant, Access = private)
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
        %         axis = {this.xAxis,this.yAxis,this.zAxis};      %Translating controller axis to our own axis num.
        relative = 0;
        absolute = 1;
        motor_type = [0.,0.,0.];
        limit_switch = [15,15,7];
        limit_switch_mode  = [15,15,15];
        ref_switch  = [2,2,2];
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
        ref_switch_x=2;
        ref_switch_y=2;
        ref_switch_z=2;
        
        goRefMode = [0,1,2,3,4,5,6,7];
        
        %       const char* result_window = "Result window";
    end
    
    properties (Access = public)
        Xpos = 0;
        Ypos = 0;
        Zpos = 0;
        AxisName = ['x';'y';'z'];
        Position = [ 0, 0, 0];
        %         AxisState = [ ['Off']; ['Off']; ['Off'] ];  % On, Off, Moving
        AxisState = [ 0, 0, 0]
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
            error = calllib('ps90', 'PS90_Connect', this.Index, this.Interface, this.nComPort, this.Baud, this.Handshake, this.Parity, this.dataBits, this.stopBits) ~= 0
            if  error == 0
                disp('Connected');
                this.IsConnected = true;
            else this.showError(error)
            end
        end
        
        %% Connect  %%
        function OWISobj = ps90tool( in1, in2, in3, in4 )
            
            %ps90tool This is a demo application for the PS 90 controller.
            %   OWISobj = ps90tool( COM_port, axis_no, velocity, distance ) moves the attached axis...
            %   function parameters
            %   parameter 1 - COM port
            %   parameter 2 - axis number
            %   parameter 3 - positioning velocity in Hz
            %   parameter 4 - distance for positioning in mm, distance=0 - reference run
            
            %     nComPort=int32(3);
            %     nAxis=int32(1);
            %     dPosF=30000.0;
            %     dDistance=10.0;
            
            if nargin ~= 4;     % We're receiving incorrect number of parameters
                fprintf (2, 'ps90tool(COM_port, axis_no, velocity, distance)\n');
                fprintf (2, 'e.g. ps90tool(3,1,30000,10)\n');
            end
            
            % set parameters *************
            if ischar(in1) == 0
                this.nComPort=int32(in1);
            else
                this.nComPort=int32(str2double(in1));
            end
            if ischar(in2) == 0
                this.nAxis=int32(in2);
            else
                this.nAxis=int32(str2double(in2));
            end
            if ischar(in3) == 0
                this.dPosF=int32(in3);
            else
                this.dPosF=str2double(in3);
            end
            if ischar(in4) == 0
                this.dDistance=in4;
            else
                this.dDistance=str2double(in4);
            end
            % ****************************
            
            loadlibrary('ps90','ps90.h')
            % open virtual serial interface
            calllib('ps90','PS90_Connect', 1, 0, this.nComPort, 9600, 0, 0, 8, 0);
            %   [x1,...,xN] = calllib(libname,funcname,arg1,...,argN)
            
            % define constants for calculation Inc -> mm
            % calllib('ps90','PS90_SetStageAttributes', 1, nAxis, 1.0, 200, 1.0)
            
            % initialize axis
            calllib('ps90','PS90_MotorInit', 1, this.nAxis);
            
            % set target mode (0 - relative)
            calllib('ps90','PS90_SetTargetMode', 1, this.nAxis, 0);
            
            % set velocity
            calllib('ps90','PS90_SetPosF', 1, this.nAxis, this.dPosF);
            
            % check position
            PositionA = calllib('ps90','PS90_GetPositionExEx', 1, this.nAxis);
            fprintf(1, 'Position=%.3f\n', PositionA);
            
            % start positioning
            if(this.dDistance==0.0) % go home (to start position)
                calllib('ps90','PS90_GoRef', 1, this.nAxis, 4);
            else % move to target position (+ positive direction, - negative direction)
                calllib('ps90','PS90_MoveEx', 1, this.nAxis, this.dDistance, 1);
            end
            
            % check move state of the axis
            fprintf(1, 'Axis is moving...\n');
            while calllib('ps90','PS90_GetMoveState', 1, this.nAxis) > 0
            end
            fprintf(1, 'Axis is in position.\n');
            
            % check position
            PositionB = calllib('ps90','PS90_GetPositionExEx', 1, this.nAxis);
            fprintf(1, 'Position=%.3f\n', PositionB);
            OWISobj = PositionB;
            
            % close interface
            calllib('ps90','PS90_Disconnect',1);
            
            unloadlibrary ps90
            
        end
        
        function showErrors (this)
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
            %     switch error2
            %                 case 0
            %                     disp ('Function was successful');
            %                 case -1
            %                     disp ('Function error');
            %                 case -2
            %                     disp ('Communication error');
            %                 case -3
            %                     disp ('Syntax error');
            %             end
        end
        
        %% Initialize %%
        
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
                this.Connect;
            end
            
            %                     //X Axis : 1//
            
            %        if PS90_SetMotorType(Index,xAxis, this.motor_type[0]) ~= 0
            %        error = calllib('ps90', 'PS90_SetMotorType', this.Index, xAxis, motor_type(1));
            if calllib('ps90', 'PS90_SetMotorType', this.Index, this.xAxis, this.motor_type(1)) ~= 0
                disp ("Error in PS90_SetMotorType X Axis");
            end
            if (calllib('ps90', 'PS90_SetLimitSwitch', this.Index, this.xAxis,this.limit_switch(1)) ~= 0 )
                disp('Error in PS90_SetLimitSwitch X Axis');
            end
            if (calllib('ps90', 'PS90_SetLimitSwitchMode', this.Index, this.xAxis,this.limit_switch_mode(1)) ~= 0 )
                disp('Error in PS90_SetLimitSwitchMode X Axis');
            end
            if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.xAxis, this.ref_switch(1)) ~= 0 )
                disp('Error in PS90_SetRefSwitch X Axis');
            end
            if (calllib('ps90', 'PS90_SetRefSwitchMode', this.Index, this.xAxis, this.ref_switch_mode(1)) ~= 0 )
                disp('Error in SetRefSwitchMode X Axis');
            end
            if (calllib('ps90', 'PS90_SetSampleTime', this.Index, this.xAxis, this.sample_time(1)) ~= 0 )
                disp('Error in SetSampleTime X Axis');
            end
            if (calllib('ps90', 'PS90_SetKP', this.Index, this.xAxis, this.KP(1)) ~= 0 )
                disp('Error in PS90_SetKP X Axis');
            end
            if (calllib('ps90', 'PS90_SetKI', this.Index, this.xAxis, this.KI(1)) ~= 0 )
                disp('Error in PS90_SetKI X Axis');
            end
            if (calllib('ps90', 'PS90_SetKD', this.Index, this.xAxis, this.KD(1)) ~= 0 )
                disp('Error in PS90_SetKD X Axis');
            end
            if (calllib('ps90', 'PS90_SetDTime', this.Index, this.xAxis, this.DTime(1)) ~= 0 )
                disp('Error in PS90_SetDTime X Axis');
            end
            if (calllib('ps90', 'PS90_SetILimit', this.Index, this.xAxis, this.ILimit(1)) ~= 0 )
                disp('Error in PS90_SetILimit X Axis');
            end
            if (calllib('ps90', 'PS90_SetTargetWindow', this.Index, this.xAxis, this.target_window(1)) ~= 0 )
                disp('Error in PS90_SetTargetWindow X Axis');
            end
            if (calllib('ps90', 'PS90_SetInPosMode', this.Index, this.xAxis, this.in_pos_mode(1)) ~= 0 )
                disp('Error in PS90_SetInPosMode X Axis');
            end
            if (calllib('ps90', 'PS90_SetCurrentLevel', this.Index, this.xAxis, this.current_level(1)) ~= 0 )
                disp('Error in SetCurrentLevel X Axis');
            end
            if (calllib('ps90', 'PS90_SetStageAttributes', this.Index, this.xAxis, this.pitch(1), this.increments_per_rev(1), this.gear_reduction_ratio(1)) ~= 0 )
                disp('Error in PS90_SetStageAttributes X Axis');
            end
            if (calllib('ps90', 'PS90_SetCalcResol', this.Index, this.xAxis, this.res_motor(1)) ~= 0 )
                disp('Error in PS90_SetCalcResol X Axis');
            end
            if (calllib('ps90', 'PS90_SetMsysResol', this.Index, this.xAxis, this.lin_res(1)) ~= 0 )
                disp('Error in PS90_SetMsysResol X Axis');
            end
            if (calllib('ps90', 'PS90_SetTargetMode', this.Index, this.xAxis, this.ini_target_mode(1)) ~= 0 )
                disp('Error in PS90_SetTargetMode X Axis');
            end
            if (calllib('ps90', 'PS90_SetAccelEx', this.Index, this.xAxis, this.acc(1)) ~= 0 )
                disp('Error in PS90_SetAccelEx X Axis');
            end
            if (calllib('ps90', 'PS90_SetDecelEx', this.Index, this.xAxis, this.dacc(1)) ~= 0 )
                disp('Error in PS90_SetDecelEx X Axis');
            end
            if (calllib('ps90', 'PS90_SetJerk', this.Index, this.xAxis, this.jacc(1)) ~= 0 )
                disp('Error in PS90_SetJerk X Axis');
            end
            if (calllib('ps90', 'PS90_SetRefDecelEx', this.Index, this.xAxis, this.ref_dacc(1)) ~= 0 )
                disp('Error in PS90_SetRefDecelEx X Axis');
            end
            if (calllib('ps90', 'PS90_SetVel', this.Index, this.xAxis, this.vel(1)) ~= 0 )
                disp('Error in PS90_SetVel X Axis');
            end
            if (calllib('ps90', 'PS90_SetPosFEx', this.Index, this.xAxis, this.pos_vel(1)) ~= 0 )
                disp('Error in PS90_SetPosFEx X Axis');
            end
            if (calllib('ps90', 'PS90_SetSlowRefFEx', this.Index, this.xAxis, this.ref_vel_slow(1)) ~= 0 )
                disp('Error in PS90_SetSlowRefFEx X Axis');
            end
            if (calllib('ps90', 'PS90_SetFastRefFEx', this.Index, this.xAxis, this.ref_vel_fast(1)) ~= 0 )
                disp('Error in PS90_SetFastRefFEx X Axis');
            end
            if (calllib('ps90', 'PS90_SetFreeVel', this.Index, this.xAxis, this.free_vel(1)) ~= 0 )
                disp('Error in PS90_SetFreeVel X Axis');
            end
            if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.xAxis, this.ref_switch_x) ~= 0 )
                disp('Error in PS90_SetRefSwitch X Axis');
            end
            
            this.Xpos = calllib('ps90', 'PS90_GetPositionExEx', this.Index, this.xAxis);
            if (calllib('ps90', 'PS90_GetReadError', this.Index) ~= 0 )
                disp('Error in PS90_GetPositionExEx X Axis');
            end
            disp('X_possition: ');
            disp(this.Xpos);
            
            %         //Y Axis : 2//
            
            if (calllib('ps90', 'PS90_SetMotorType', this.Index, this.yAxis, this.motor_type(2)) ~= 0 )
                disp('Error in PS90_SetMotorType Y Axis');
            end
            if (calllib('ps90', 'PS90_SetLimitSwitch', this.Index, this.yAxis,this.limit_switch(2)) ~= 0 )
                disp('Error in PS90_SetLimitSwitch Y Axis');
            end
            if (calllib('ps90', 'PS90_SetLimitSwitchMode', this.Index, this.yAxis,this.limit_switch_mode(2)) ~= 0 )
                disp('Error in PS90_SetLimitSwitchMode Y Axis');
            end
            if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.yAxis, this.ref_switch(2)) ~= 0 )
                disp('Error in PS90_SetRefSwitch Y Axis');
            end
            if (calllib('ps90', 'PS90_SetRefSwitchMode', this.Index, this.yAxis, this.ref_switch_mode(2)) ~= 0 )
                disp('Error in SetRefSwitchMode Y Axis');
            end
            if (calllib('ps90', 'PS90_SetSampleTime', this.Index, this.yAxis, this.sample_time(2)) ~= 0 )
                disp('Error in SetSampleTime Y Axis');
            end
            if (calllib('ps90', 'PS90_SetKP', this.Index, this.yAxis, this.KP(2)) ~= 0 )
                disp('Error in PS90_SetKP Y Axis');
            end
            if (calllib('ps90', 'PS90_SetKI', this.Index, this.yAxis, this.KI(2)) ~= 0 )
                disp('Error in PS90_SetKI Y Axis');
            end
            if (calllib('ps90', 'PS90_SetKD', this.Index, this.yAxis, this.KD(2)) ~= 0 )
                disp('Error in PS90_SetKD Y Axis');
            end
            if (calllib('ps90', 'PS90_SetDTime', this.Index, this.yAxis, this.DTime(2)) ~= 0 )
                disp('Error in PS90_SetDTime Y Axis');
            end
            if (calllib('ps90', 'PS90_SetILimit', this.Index, this.yAxis, this.ILimit(2)) ~= 0 )
                disp('Error in PS90_SetILimit Y Axis');
            end
            if (calllib('ps90', 'PS90_SetTargetWindow', this.Index, this.yAxis, this.target_window(2)) ~= 0 )
                disp('Error in PS90_SetTargetWindow Y Axis');
            end
            if (calllib('ps90', 'PS90_SetInPosMode', this.Index, this.yAxis, this.in_pos_mode(2)) ~= 0 )
                disp('Error in PS90_SetInPosMode Y Axis');
            end
            if (calllib('ps90', 'PS90_SetCurrentLevel', this.Index, this.yAxis, this.current_level(2)) ~= 0 )
                disp('Error in SetCurrentLevel Y Axis');
            end
            if (calllib('ps90', 'PS90_SetStageAttributes', this.Index, this.yAxis, this.pitch(2), this.increments_per_rev(2), this.gear_reduction_ratio(2)) ~= 0 )
                disp('Error in PS90_SetStageAttributes Y Axis');
            end
            if (calllib('ps90', 'PS90_SetCalcResol', this.Index, this.yAxis, this.res_motor(2)) ~= 0 )
                disp('Error in PS90_SetCalcResol Y Axis');
            end
            if (calllib('ps90', 'PS90_SetMsysResol', this.Index, this.yAxis, this.lin_res(2)) ~= 0 )
                disp('Error in PS90_SetMsysResol Y Axis');
            end
            if (calllib('ps90', 'PS90_SetTargetMode', this.Index, this.yAxis, this.ini_target_mode(2)) ~= 0 )
                disp('Error in PS90_SetTargetMode Y Axis');
            end
            if (calllib('ps90', 'PS90_SetAccelEx', this.Index, this.yAxis, this.acc(2)) ~= 0 )
                disp('Error in PS90_SetAccelEx Y Axis');
            end
            if (calllib('ps90', 'PS90_SetDecelEx', this.Index, this.yAxis, this.dacc(2)) ~= 0 )
                disp('Error in PS90_SetDecelEx Y Axis');
            end
            if (calllib('ps90', 'PS90_SetJerk', this.Index, this.yAxis, this.jacc(2)) ~= 0 )
                disp('Error in PS90_SetJerk Y Axis');
            end
            if (calllib('ps90', 'PS90_SetRefDecelEx', this.Index, this.yAxis, this.ref_dacc(2)) ~= 0 )
                disp('Error in PS90_SetRefDecelEx Y Axis');
            end
            if (calllib('ps90', 'PS90_SetVel', this.Index, this.yAxis, this.vel(2)) ~= 0 )
                disp('Error in PS90_SetVel Y Axis');
            end
            if (calllib('ps90', 'PS90_SetPosFEx', this.Index, this.yAxis, this.pos_vel(2)) ~= 0 )
                disp('Error in PS90_SetPosFEx Y Axis');
            end
            if (calllib('ps90', 'PS90_SetSlowRefFEx', this.Index, this.yAxis, this.ref_vel_slow(2)) ~= 0 )
                disp('Error in PS90_SetSlowRefFEx Y Axis');
            end
            if (calllib('ps90', 'PS90_SetFastRefFEx', this.Index, this.yAxis, this.ref_vel_fast(2)) ~= 0 )
                disp('Error in PS90_SetFastRefFEx Y Axis');
            end
            if (calllib('ps90', 'PS90_SetFreeVel', this.Index, this.yAxis, this.free_vel(2)) ~= 0 )
                disp('Error in PS90_SetFreeVel Y Axis');
            end
            if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.yAxis, this.ref_switch_y) ~= 0 )
                disp('Error in PS90_SetRefSwitch Y Axis');
            end
            
            this.Ypos = calllib('ps90', 'PS90_GetPositionExEx', this.Index, this.yAxis);
            if (calllib('ps90', 'PS90_GetReadError', this.Index) ~= 0 )
                disp('Error in PS90_GetPositionExEx Y Axis');
            end
            disp('Y_possition: ');
            disp(this.Ypos);
            
            %         //Z Axis : 3//
            
            if (calllib('ps90', 'PS90_SetMotorType', this.Index, this.zAxis, this.motor_type(3)) ~= 0 )
                disp('Error in PS90_SetMotorType Z Axis');
            end
            if (calllib('ps90', 'PS90_SetLimitSwitch', this.Index, this.zAxis,this.limit_switch(3)) ~= 0 )
                disp('Error in PS90_SetLimitSwitch Z Axis');
            end
            if (calllib('ps90', 'PS90_SetLimitSwitchMode', this.Index, this.zAxis,this.limit_switch_mode(3)) ~= 0 )
                disp('Error in PS90_SetLimitSwitchMode Z Axis');
            end
            if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.zAxis, this.ref_switch(3)) ~= 0 )
                disp('Error in PS90_SetRefSwitch Z Axis');
            end
            if (calllib('ps90', 'PS90_SetRefSwitchMode', this.Index, this.zAxis, this.ref_switch_mode(3)) ~= 0 )
                disp('Error in SetRefSwitchMode Z Axis');
            end
            if (calllib('ps90', 'PS90_SetSampleTime', this.Index, this.zAxis, this.sample_time(3)) ~= 0 )
                disp('Error in SetSampleTime Z Axis');
            end
            if (calllib('ps90', 'PS90_SetKP', this.Index, this.zAxis, this.KP(3)) ~= 0 )
                disp('Error in PS90_SetKP Z Axis');
            end
            if (calllib('ps90', 'PS90_SetKI', this.Index, this.zAxis, this.KI(3)) ~= 0 )
                disp('Error in PS90_SetKI Z Axis');
            end
            if (calllib('ps90', 'PS90_SetKD', this.Index, this.zAxis, this.KD(3)) ~= 0 )
                disp('Error in PS90_SetKD Z Axis');
            end
            if (calllib('ps90', 'PS90_SetDTime', this.Index, this.zAxis, this.DTime(3)) ~= 0 )
                disp('Error in PS90_SetDTime Z Axis');
            end
            if (calllib('ps90', 'PS90_SetILimit', this.Index, this.zAxis, this.ILimit(3)) ~= 0 )
                disp('Error in PS90_SetILimit Z Axis');
            end
            if (calllib('ps90', 'PS90_SetTargetWindow', this.Index, this.zAxis, this.target_window(3)) ~= 0 )
                disp('Error in PS90_SetTargetWindow Z Axis');
            end
            if (calllib('ps90', 'PS90_SetInPosMode', this.Index, this.zAxis, this.in_pos_mode(3)) ~= 0 )
                disp('Error in PS90_SetInPosMode Z Axis');
            end
            if (calllib('ps90', 'PS90_SetCurrentLevel', this.Index, this.zAxis, this.current_level(3)) ~= 0 )
                disp('Error in SetCurrentLevel Z Axis');
            end
            if (calllib('ps90', 'PS90_SetStageAttributes', this.Index, this.zAxis, this.pitch(3), this.increments_per_rev(3), this.gear_reduction_ratio(3)) ~= 0 )
                disp('Error in PS90_SetStageAttributes Z Axis');
            end
            if (calllib('ps90', 'PS90_SetCalcResol', this.Index, this.zAxis, this.res_motor(3)) ~= 0 )
                disp('Error in PS90_SetCalcResol Z Axis');
            end
            if (calllib('ps90', 'PS90_SetMsysResol', this.Index, this.zAxis, this.lin_res(3)) ~= 0 )
                disp('Error in PS90_SetMsysResol Z Axis');
            end
            if (calllib('ps90', 'PS90_SetTargetMode', this.Index, this.zAxis, this.ini_target_mode(3)) ~= 0 )
                disp('Error in PS90_SetTargetMode Z Axis');
            end
            if (calllib('ps90', 'PS90_SetAccelEx', this.Index, this.zAxis, this.acc(3)) ~= 0 )
                disp('Error in PS90_SetAccelEx Z Axis');
            end
            if (calllib('ps90', 'PS90_SetDecelEx', this.Index, this.zAxis, this.dacc(3)) ~= 0 )
                disp('Error in PS90_SetDecelEx Z Axis');
            end
            if (calllib('ps90', 'PS90_SetJerk', this.Index, this.zAxis, this.jacc(3)) ~= 0 )
                disp('Error in PS90_SetJerk Z Axis');
            end
            if (calllib('ps90', 'PS90_SetRefDecelEx', this.Index, this.zAxis, this.ref_dacc(3)) ~= 0 )
                disp('Error in PS90_SetRefDecelEx Z Axis');
            end
            if (calllib('ps90', 'PS90_SetVel', this.Index, this.zAxis, this.vel(3)) ~= 0 )
                disp('Error in PS90_SetVel Z Axis');
            end
            if (calllib('ps90', 'PS90_SetPosFEx', this.Index, this.zAxis, this.pos_vel(3)) ~= 0 )
                disp('Error in PS90_SetPosFEx Z Axis');
            end
            if (calllib('ps90', 'PS90_SetSlowRefFEx', this.Index, this.zAxis, this.ref_vel_slow(3)) ~= 0 )
                disp('Error in PS90_SetSlowRefFEx Z Axis');
            end
            if (calllib('ps90', 'PS90_SetFastRefFEx', this.Index, this.zAxis, this.ref_vel_fast(3)) ~= 0 )
                disp('Error in PS90_SetFastRefFEx Z Axis');
            end
            if (calllib('ps90', 'PS90_SetFreeVel', this.Index, this.zAxis, this.free_vel(3) ~= 0 ))
                disp('Error in PS90_SetFreeVel Z Axis');
            end
            if (calllib('ps90', 'PS90_SetRefSwitch', this.Index, this.zAxis, this.ref_switch_z) ~= 0 )
                disp('Error in PS90_SetRefSwitch Z Axis');
            end
            
            this.Zpos = calllib ('ps90', 'PS90_GetPositionExEx', this.Index, this.zAxis);
            if (calllib('ps90', 'PS90_GetReadError', this.Index) ~= 0 )
                disp('Error in PS90_GetPositionExEx Z Axis');
            else
                disp('Z_possition: ');
                disp(this.Zpos);
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
        
        function showError (this, error)
            switch error
                case 0
                    disp ('Function was successful');
                case -1
                    disp ('Function error');
                case -2
                    disp ('Communication error');
                case -3
                    disp ('Syntax error');
            end
        end
        
        %% Disconnect  %%
        
        %         function  this = Disconnect(this)
        %         % function  this = Disconnect(this)
        %         % Arguments: object STAGES %
        %         % Returns: none %
        %
        %         Disconnect(this.OWISobj)
        %         Connect(this.OWISobj)
        %
        %             switch this.GantryType
        %                 case 0
        %                 A3200Disconnect(this.OWISObj);
        %                 this.IsConnected=0;
        %                 disp('Stages disconnected');
        %                 case 1
        %                 CloseComm(this.GantryObj);
        %                 this.IsConnected=0;
        %                 disp('Stages disconnected');
        %             end
        %         end
        %
        %
        %% MoveTo %% Absolute movements %%
        function  MoveTo(this,axis,target,velocity)
            % function  MoveTo(this,axis,target,velocity)
            % Arguments: object ALIO (this), axis int, target double, velocity double%
            % Returns: none %
            
            calllib('ps90','PS90_MotorInit', cosa.Index, cosa.yAxis);
            calllib ('ps90', 'PS90_MoveEx', cosa.Index, cosa.xAxis, -30, 1)
            xPos = calllib ('ps90', 'PS90_GetPositionEx', cosa.Index, cosa.xAxis);
            
            
            if this.IsConnected == 0
                disp('Not connected');
                return
            end
            switch axis
                case 0
                    SetVelocity(this.xAxis,velocity);
                    ToPoint(this.Absolute,this.xAxis,target);
                case 1
                    SetVelocity(this.yAxis,velocity);
                    ToPoint(this.Absolute,this.yAxis,target);
                case 4
                    SetVelocity(this.z1Axis,velocity);
                    ToPoint(this.Absolute,this.z1Axis,target);
                case 5
                    SetVelocity(this.z2Axis,velocity);
                    ToPoint(this.Absolute,this.z2Axis,target);
                case 6
                    SetVelocity(this.uAxis,velocity);
                    ToPoint(this.Absolute,this.uAxis,target);
            end
        end
        
        %% MoveBy %% Relative movement %%
        
        function  MoveBy(this,axis,delta,velocity)
            % function  MoveBy(this,axis,delta,velocity)
            % Arguments: object ALIO (this), axis int, delta double, velocity double%
            % Returns: none %
            
            this.TargetMode(axis) = this.relative;
            
            
            %         fprintf('Current %s position: %6.4f\n', this.AxisName, this.Position);
            %         fprintf('Current X position: %6.4f\n', this.Xpos);
            %         fprintf('Current Y position: %6.4f\n', this.Ypos);
            %         fprintf('Current Z position: %6.4f\n', this.Zpos);
            
            for i=1:3
                fprintf('Initial %s position: %3.3fmm', this.AxisName(i), this.Position(i));
                calllib('ps90','PS90_SetPosMode', this.Index, axis, this.PosMode(i));
                if this.AxisState(i) == 'Off'
                    disp ('Activating motor');
                    error = calllib('ps90','PS90_MotorInit', this.Index, axis);
                end
            end
            
            if this.AxisState(axis) == 0
                fprintf(' %s motor not activated\n', this.AxisName(axis));
                error = calllib('ps90','PS90_MotorInit', this.Index, axis);
                if error ~= 0
                    fprintf('Error activating %s motor: %d\n', this.AxisName(axis), error);
                else
                    fprintf(' %s motor activated succesfully\n', this.AxisName(axis));
                end
                this.Position(axis) = calllib ('ps90', 'PS90_GetPositionEx', this.Index, axis);
                fprintf('Current %s position: %3.3f\n', this.AxisName(axis), this.Position(axis));
                
                error = calllib('ps90','PS90_SetPosMode', this.Index, axis, this.PosMode(axis));       %Trapezoidal movement
                if error ~= 0
                    fprintf('Error in %s : %d\n', this.AxisName, error);
                end
                error = calllib('ps90','PS90_SetTargetMode', this.Index, axis, this.TargetMode(axis)); %Relative movement
                if error ~= 0
                    fprintf('Error in %s : %d\n', this.AxisName, error);
                end
                error = calllib ('ps90', 'PS90_MoveEx', this.Index, axis, delta, this.units);
            end
        end
    end
end

